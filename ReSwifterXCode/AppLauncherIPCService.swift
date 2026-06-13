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

/// Tracks in-flight response state for a single sendRequest call.
/// Marked @unchecked Sendable because all access is serialized on the main actor.
private final class ResponseTracker: @unchecked Sendable {
    var didResume = false
    var observer: NSObjectProtocol?
    var timeoutTask: Task<Void, Never>?

    func removeObserver() {
        if let obs = observer {
            DistributedNotificationCenter.default().removeObserver(obs)
            observer = nil
        }
    }
}

@MainActor
class AppLauncherIPCService {

    nonisolated private let appGroupID = "group.com.JeffreyBakker.ReSwifter"
    nonisolated private let requestNotificationName = Notification.Name("com.JeffreyBakker.ReSwifter.processRequest")
    nonisolated private let responseNotificationName = Notification.Name("com.JeffreyBakker.ReSwifter.processResponse")

    nonisolated private let requestTextKey = "ReSwifter_RequestText"
    nonisolated private let requestIDKey = "ReSwifter_RequestID"
    nonisolated private let responseTextKey = "ReSwifter_ResponseText"
    nonisolated private let responseErrorKey = "ReSwifter_ResponseError"
    nonisolated private let responseIDKey = "ReSwifter_ResponseID"

    nonisolated private let hostAppBundleID = "com.JeffreyBakker.ReSwifter"

    nonisolated private let log = OSLog(subsystem: "com.JeffreyBakker.ReSwifterXCode", category: "IPCService")

    /// Timeout for waiting for a response from the host app.
    /// Set high to allow time for user interaction in the host app UI.
    private let responseTimeout: TimeInterval = 900

    // MARK: - Launch Host App

    /// Launches the host app if it is not already running.
    /// Always brings the host app to the foreground.
    func launchHostApp() async throws {
        let running = NSRunningApplication.runningApplications(withBundleIdentifier: hostAppBundleID)
        if let app = running.first {
            os_log("Host app already running, activating", log: log, type: .debug)
            app.activate(options: .activateAllWindows)
            return
        }

        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: hostAppBundleID) else {
            os_log("Host app not found: %{public}@", log: log, type: .error, hostAppBundleID)
            throw NSError(
                domain: "ReSwifterIPCService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not find host app with bundle ID: \(hostAppBundleID)"]
            )
        }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = true

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            NSWorkspace.shared.openApplication(at: appURL, configuration: config) { [weak self] app, error in
                guard let self else { return }
                if let error {
                    os_log("Failed to launch host app: %{public}@", log: self.log, type: .error, error.localizedDescription)
                    continuation.resume(throwing: error)
                } else {
                    os_log("Host app launched: %{public}@", log: self.log, type: .info, app?.bundleIdentifier ?? "unknown")
                    continuation.resume()
                }
            }
        }
    }

    // MARK: - Process Text

    /// Launches the host app, then sends text for processing.
    /// Returns when the host app delivers its result (or throws on timeout/error).
    func launchAndProcess(_ text: String) async throws -> String? {
        let wasAlreadyRunning = !NSRunningApplication.runningApplications(
            withBundleIdentifier: hostAppBundleID
        ).isEmpty

        try await launchHostApp()

        // If the app was just launched, give it time to start its listener
        if !wasAlreadyRunning {
            try await Task.sleep(for: .seconds(2))
        }

        return try await sendRequest(text)
    }

    // MARK: - Private

    private func sendRequest(_ text: String) async throws -> String? {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            os_log("Failed to open shared UserDefaults", log: log, type: .error)
            throw NSError(
                domain: "ReSwifterIPCService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Failed to open shared UserDefaults for suite: \(appGroupID)"]
            )
        }

        let requestID = UUID().uuidString
        defaults.set(text, forKey: requestTextKey)
        defaults.set(requestID, forKey: requestIDKey)

        os_log("Sending request %{public}@ (%{public}d chars)", log: log, type: .info, requestID, text.count)

        // Yield activation so the host app can come to the foreground
        NSApplication.shared.yieldActivation(toApplicationWithBundleIdentifier: hostAppBundleID)

        DistributedNotificationCenter.default().postNotificationName(
            requestNotificationName,
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )

        return try await withCheckedThrowingContinuation { continuation in
            let tracker = ResponseTracker()

            tracker.timeoutTask = Task { @MainActor in
                try? await Task.sleep(for: .seconds(self.responseTimeout))
                guard !tracker.didResume else { return }
                tracker.didResume = true
                tracker.removeObserver()
                os_log("Request %{public}@ timed out", log: self.log, type: .error, requestID)
                continuation.resume(throwing: NSError(
                    domain: "ReSwifterIPCService",
                    code: 4,
                    userInfo: [NSLocalizedDescriptionKey: "Timed out waiting for response from host app"]
                ))
            }

            tracker.observer = DistributedNotificationCenter.default().addObserver(
                forName: responseNotificationName,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self, !tracker.didResume else { return }
                guard let defaults = UserDefaults(suiteName: self.appGroupID) else { return }

                guard let responseID = defaults.string(forKey: self.responseIDKey),
                      responseID == requestID else {
                    return // Not our response
                }

                tracker.didResume = true
                tracker.timeoutTask?.cancel()
                tracker.removeObserver()

                if let errorMessage = defaults.string(forKey: self.responseErrorKey) {
                    os_log("Received error: %{public}@", log: self.log, type: .error, errorMessage)
                    continuation.resume(throwing: NSError(
                        domain: "ReSwifterIPCService",
                        code: 3,
                        userInfo: [NSLocalizedDescriptionKey: errorMessage]
                    ))
                } else {
                    let result = defaults.string(forKey: self.responseTextKey)
                    os_log("Received response for %{public}@", log: self.log, type: .info, requestID)
                    continuation.resume(returning: result)
                }
            }
        }
    }
}
