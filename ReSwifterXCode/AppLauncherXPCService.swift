//
//  AppLauncherXPCService.swift
//  ReSwifterXCode
//
//  Created by Jeffrey Bakker on 2026-03-05.
//
//  Extension-side client that communicates with the host app
//  (ReSwifter.app) via DistributedNotificationCenter + shared
//  UserDefaults (App Group).
//
//  Flow:
//  1. Launch the host app (so it starts listening).
//  2. Write request text + unique ID to shared UserDefaults.
//  3. Post a distributed notification to signal the host app.
//  4. Listen for the response notification.
//  5. Read the result from shared UserDefaults.
//

import Foundation
import AppKit
import os.log

/// Mutable state shared between the response observer and timeout closures.
private class ResponseState {
    var observer: NSObjectProtocol?
    var didReceive = false

    func removeObserver() {
        if let observer = observer {
            DistributedNotificationCenter.default().removeObserver(observer)
            self.observer = nil
        }
    }
}

class AppLauncherXPCService {

    private let appGroupID = "group.com.JeffreyBakker.ReSwifter"
    private let requestNotificationName = Notification.Name("com.JeffreyBakker.ReSwifter.processRequest")
    private let responseNotificationName = Notification.Name("com.JeffreyBakker.ReSwifter.processResponse")

    private let requestTextKey = "ReSwifter_RequestText"
    private let requestIDKey = "ReSwifter_RequestID"
    private let responseTextKey = "ReSwifter_ResponseText"
    private let responseErrorKey = "ReSwifter_ResponseError"
    private let responseIDKey = "ReSwifter_ResponseID"

    private let hostAppBundleID = "com.JeffreyBakker.ReSwifter"

    private let log = OSLog(subsystem: "com.JeffreyBakker.ReSwifterXCode", category: "IPCService")

    /// Timeout for waiting for a response from the host app.
    /// Set high to allow time for user interaction in the host app UI.
    private let responseTimeout: TimeInterval = 120.0

    // MARK: - Launch Host App

    /// Launches the host app if it is not already running.
    func launchHostApp(completion: @escaping (Bool, Error?) -> Void) {
        let running = NSRunningApplication.runningApplications(
            withBundleIdentifier: hostAppBundleID
        )
        if !running.isEmpty {
            os_log("Host app already running", log: log, type: .debug)
            completion(true, nil)
            return
        }

        guard let appURL = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: hostAppBundleID
        ) else {
            let error = NSError(
                domain: "ReSwifterIPCService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not find host app with bundle ID: \(hostAppBundleID)"]
            )
            os_log("Host app not found: %{public}@", log: log, type: .error, hostAppBundleID)
            completion(false, error)
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = false

        NSWorkspace.shared.openApplication(at: appURL, configuration: config) { app, error in
            if let error = error {
                os_log("Failed to launch host app: %{public}@", log: self.log, type: .error, error.localizedDescription)
                completion(false, error)
            } else {
                os_log("Host app launched: %{public}@", log: self.log, type: .info, app?.bundleIdentifier ?? "unknown")
                completion(true, nil)
            }
        }
    }

    // MARK: - Process Text

    /// Launches the host app, then sends text for processing.
    /// The reply is called when the host app delivers its result
    /// (or on timeout).
    func launchAndProcess(_ text: String, reply: @escaping (String?, Error?) -> Void) {
        let wasAlreadyRunning = !NSRunningApplication.runningApplications(
            withBundleIdentifier: hostAppBundleID
        ).isEmpty

        launchHostApp { [weak self] success, error in
            guard let self = self, success else {
                reply(nil, error)
                return
            }

            // If the app was just launched, give it time to start its listener
            let delay: TimeInterval = wasAlreadyRunning ? 0.0 : 2.0

            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) {
                self.sendRequest(text, reply: reply)
            }
        }
    }

    // MARK: - Private

    private func sendRequest(_ text: String, reply: @escaping (String?, Error?) -> Void) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            let error = NSError(
                domain: "ReSwifterIPCService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to open shared UserDefaults for suite: \(appGroupID)"]
            )
            os_log("Failed to open shared UserDefaults", log: log, type: .error)
            reply(nil, error)
            return
        }

        let requestID = UUID().uuidString

        // Write request data
        defaults.set(text, forKey: requestTextKey)
        defaults.set(requestID, forKey: requestIDKey)
        defaults.synchronize()

        os_log("Sending request %{public}@ (%{public}d chars)", log: log, type: .info, requestID, text.count)

        // Mutable state shared between closures
        let state = ResponseState()

        state.observer = DistributedNotificationCenter.default().addObserver(
            forName: responseNotificationName,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, !state.didReceive else { return }

            // Re-read from disk
            defaults.synchronize()

            guard let responseID = defaults.string(forKey: self.responseIDKey),
                  responseID == requestID else {
                return // Not our response
            }

            state.didReceive = true
            state.removeObserver()

            if let errorMessage = defaults.string(forKey: self.responseErrorKey) {
                let error = NSError(
                    domain: "ReSwifterIPCService",
                    code: 3,
                    userInfo: [NSLocalizedDescriptionKey: errorMessage]
                )
                os_log("Received error: %{public}@", log: self.log, type: .error, errorMessage)
                reply(nil, error)
            } else {
                let result = defaults.string(forKey: self.responseTextKey)
                os_log("Received response for %{public}@", log: self.log, type: .info, requestID)
                reply(result, nil)
            }
        }

        // Post the request notification
        DistributedNotificationCenter.default().postNotificationName(
            requestNotificationName,
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )

        // Timeout
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + responseTimeout) {
            guard !state.didReceive else { return }
            state.didReceive = true
            state.removeObserver()

            let error = NSError(
                domain: "ReSwifterIPCService",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "Timed out waiting for response from host app"]
            )
            os_log("Request %{public}@ timed out", log: self.log, type: .error, requestID)
            reply(nil, error)
        }
    }
}
