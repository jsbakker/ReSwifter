//
//  AppLauncherXPCService.swift
//  ReSwifterXCode
//
//  Created by Jeffrey Bakker on 2026-03-05.
//
//  Communicates with the host app (ReSwifter.app) via
//  NSDistributedNotificationCenter + shared UserDefaults (App Group).
//
//  IPC flow:
//  1. Write the request text + a unique request ID to shared UserDefaults.
//  2. Post a distributed notification to signal the host app.
//  3. Observe the response notification from the host app.
//  4. Read the result from shared UserDefaults and call the reply handler.
//
//  Requirements:
//  - Both targets must belong to the same App Group
//    (group.com.JeffreyBakker.ReSwifter).
//

import Foundation
import AppKit
import os.log

import ReSwifterInterface

class AppLauncherXPCService {

    /// Must match XPCServiceDelegate values in the host app.
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

    /// Timeout in seconds for waiting for a response from the host app.
    private let responseTimeout: TimeInterval = 10.0

    var rsConnection: NSXPCConnection?

    // MARK: - Launch Host App

    /// Launches the host app (ReSwifter.app) if it is not already running.
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

    func connectToReSwifterService() {
        rsConnection = NSXPCConnection(serviceName: "com.JeffreyBakker.ReSwifter.Service")
        rsConnection?.remoteObjectInterface = NSXPCInterface(with: ReSwifterServiceProtocol.self)
        rsConnection?.resume()
    }

    func sendStringToReSwifter(_ string: String) {
        (rsConnection?.remoteObjectProxy as? ReSwifterServiceProtocol)?.extensionPostString(string)
    }

    // MARK: - Send Request

    /// Sends text to the host app for processing via distributed notification + shared UserDefaults.
    /// Automatically launches the host app if needed.
    func launchAndProcess(_ text: String, reply: @escaping (String?, Error?) -> Void) {
        launchHostApp { [weak self] success, error in
            guard let self = self, success else {
                reply(nil, error)
                return
            }

            // Give the host app a moment to start its listener if just launched
            let delay: TimeInterval = NSRunningApplication.runningApplications(
                withBundleIdentifier: self.hostAppBundleID
            ).isEmpty ? 1.5 : 0.0

            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) {
                self.sendRequest(text, reply: reply)
            }
        }
    }

    /// Writes the request to shared UserDefaults and posts the notification.
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

        // Write request data to shared UserDefaults
        defaults.set(text, forKey: requestTextKey)
        defaults.set(requestID, forKey: requestIDKey)
        defaults.synchronize()

        os_log("Sending request %{public}@ (%{public}d chars)", log: log, type: .info, requestID, text.count)

        // Set up response listener before posting the request
        var responseObserver: NSObjectProtocol?
        var didReceiveResponse = false

        responseObserver = DistributedNotificationCenter.default().addObserver(
            forName: responseNotificationName,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, !didReceiveResponse else { return }

            // Read the response from shared UserDefaults
            defaults.synchronize()
            guard let responseID = defaults.string(forKey: self.responseIDKey),
                  responseID == requestID else {
                // Not our response, ignore
                return
            }

            didReceiveResponse = true

            if let observer = responseObserver {
                DistributedNotificationCenter.default().removeObserver(observer)
            }

            if let errorMessage = defaults.string(forKey: self.responseErrorKey) {
                let error = NSError(
                    domain: "ReSwifterIPCService",
                    code: 3,
                    userInfo: [NSLocalizedDescriptionKey: errorMessage]
                )
                os_log("Received error response: %{public}@", log: self.log, type: .error, errorMessage)
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

        // Set up a timeout
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + responseTimeout) {
            guard !didReceiveResponse else { return }
            didReceiveResponse = true

            if let observer = responseObserver {
                DistributedNotificationCenter.default().removeObserver(observer)
            }

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
