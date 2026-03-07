//
//  ExtensionXPCService.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-06.
//
//  Host app side: listens for text-processing requests from the
//  Xcode Source Editor Extension via DistributedNotificationCenter
//  + shared UserDefaults (App Group).
//
//  Flow:
//  1. Extension writes request text + ID to shared UserDefaults
//     and posts a distributed notification.
//  2. This listener receives the notification, reads the text,
//     and publishes it for the UI to display.
//  3. The user reviews the text in the UI and presses Send.
//  4. The app writes the result back and posts a response
//     notification.
//  5. Extension reads the result from shared UserDefaults.
//

import Combine
import Foundation
import os.log
import os.log

@MainActor
class ExtensionXPCService: ObservableObject {

    static let appGroupID = "group.com.JeffreyBakker.ReSwifter"
    static let requestNotification = Notification.Name("com.JeffreyBakker.ReSwifter.processRequest")
    static let responseNotification = Notification.Name("com.JeffreyBakker.ReSwifter.processResponse")

    static let requestTextKey = "ReSwifter_RequestText"
    static let requestIDKey = "ReSwifter_RequestID"
    static let responseTextKey = "ReSwifter_ResponseText"
    static let responseErrorKey = "ReSwifter_ResponseError"
    static let responseIDKey = "ReSwifter_ResponseID"

    private let log = OSLog(subsystem: "com.JeffreyBakker.ReSwifter", category: "IPCListener")

    private var sharedDefaults: UserDefaults?
    private var notificationObserver: NSObjectProtocol?

    /// The text received from the extension, displayed in the UI.
    @Published var receivedText: String?

    /// The request ID for the pending request.
    private var pendingRequestID: String?

    /// Whether a request is pending and waiting for the user to act.
    @Published var hasPendingRequest: Bool = false

    init() {
        startListening()
    }

    /// Starts listening for distributed notifications from the extension.
    func startListening() {
        sharedDefaults = UserDefaults(suiteName: ExtensionXPCService.appGroupID)

        if sharedDefaults == nil {
            os_log("Failed to open shared UserDefaults for suite: %{public}@",
                   log: log, type: .fault, ExtensionXPCService.appGroupID)
            return
        }

        notificationObserver = DistributedNotificationCenter.default().addObserver(
            forName: ExtensionXPCService.requestNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleProcessRequest()
            }
        }

        os_log("IPC listener started (DistributedNotification + UserDefaults)", log: log, type: .info)
    }

    /// Stops listening.
    func stopListening() {
        if let observer = notificationObserver {
            DistributedNotificationCenter.default().removeObserver(observer)
            notificationObserver = nil
        }
        os_log("IPC listener stopped", log: log, type: .info)
    }

    // MARK: - Handle Request

    private func handleProcessRequest() {
        guard let defaults = sharedDefaults else {
            os_log("Shared UserDefaults not available", log: log, type: .error)
            return
        }

        // Re-read from disk to pick up the extension's writes
        defaults.synchronize()

        guard let requestID = defaults.string(forKey: ExtensionXPCService.requestIDKey) else {
            os_log("No request ID found", log: log, type: .error)
            return
        }

        guard let text = defaults.string(forKey: ExtensionXPCService.requestTextKey) else {
            os_log("No request text found", log: log, type: .error)
            postResponse(nil, error: "No request text found", requestID: requestID)
            return
        }

        os_log("Received request %{public}@ (%{public}d chars)",
               log: log, type: .info, requestID, text.count)

        // Store the pending request and publish text to the UI
        pendingRequestID = requestID
        receivedText = text
        hasPendingRequest = true
    }

    // MARK: - User Actions

    /// Called from the UI when the user presses Send.
    /// Sends the (possibly edited) text back to the extension.
    func sendResponse(_ text: String) {
        guard let requestID = pendingRequestID else {
            os_log("sendResponse called but no pending request", log: log, type: .error)
            return
        }

        postResponse(text, error: nil, requestID: requestID)
        clearPendingRequest()
    }

    /// Called from the UI to cancel / reject the request.
    func cancelResponse() {
        guard let requestID = pendingRequestID else { return }

        postResponse(nil, error: "Request cancelled by user", requestID: requestID)
        clearPendingRequest()
    }

    private func clearPendingRequest() {
        pendingRequestID = nil
        receivedText = nil
        hasPendingRequest = false
    }

    // MARK: - Post Response

    private func postResponse(_ text: String?, error: String?, requestID: String) {
        guard let defaults = sharedDefaults else { return }

        defaults.set(requestID, forKey: ExtensionXPCService.responseIDKey)
        defaults.set(text, forKey: ExtensionXPCService.responseTextKey)
        defaults.set(error, forKey: ExtensionXPCService.responseErrorKey)
        defaults.synchronize()

        DistributedNotificationCenter.default().postNotificationName(
            ExtensionXPCService.responseNotification,
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )

        os_log("Posted response for request %{public}@", log: log, type: .info, requestID)
    }
}
