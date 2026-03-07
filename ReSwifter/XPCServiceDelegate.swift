//
//  XPCServiceDelegate.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-05.
//
//  Listens for text-processing requests from the Xcode Source Editor
//  Extension via NSDistributedNotificationCenter.
//
//  IPC flow:
//  1. Extension writes the request text to the shared UserDefaults
//     (App Group) under a known key, then posts a distributed
//     notification to signal the host app.
//  2. This listener receives the notification, reads the text from
//     UserDefaults, processes it, writes the result back, and posts
//     a response notification.
//  3. The extension observes the response notification and reads the
//     result from UserDefaults.
//
//  Usage:
//  - Create an instance and call `startListening()` at app launch.
//
//  Requirements:
//  - Both targets must belong to the same App Group
//    (group.com.JeffreyBakker.ReSwifter).
//

import Foundation
import os.log

class XPCServiceDelegate: NSObject {

    /// Shared App Group suite name. Must match the extension.
    static let appGroupID = "group.com.JeffreyBakker.ReSwifter"

    /// Distributed notification posted by the extension to request processing.
    static let requestNotification = Notification.Name("com.JeffreyBakker.ReSwifter.processRequest")

    /// Distributed notification posted by the host app when the result is ready.
    static let responseNotification = Notification.Name("com.JeffreyBakker.ReSwifter.processResponse")

    /// UserDefaults keys used to pass data between extension and host app.
    static let requestTextKey = "ReSwifter_RequestText"
    static let requestIDKey = "ReSwifter_RequestID"
    static let responseTextKey = "ReSwifter_ResponseText"
    static let responseErrorKey = "ReSwifter_ResponseError"
    static let responseIDKey = "ReSwifter_ResponseID"

    private let log = OSLog(subsystem: "com.JeffreyBakker.ReSwifter", category: "IPCListener")

    private var sharedDefaults: UserDefaults?

    /// Starts listening for distributed notifications from the extension.
    func startListening() {
        sharedDefaults = UserDefaults(suiteName: XPCServiceDelegate.appGroupID)

        if sharedDefaults == nil {
            os_log("Failed to open shared UserDefaults for suite: %{public}@", log: log, type: .fault, XPCServiceDelegate.appGroupID)
            return
        }

        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleProcessRequest(_:)),
            name: XPCServiceDelegate.requestNotification,
            object: nil
        )

        os_log("IPC listener started (DistributedNotification + UserDefaults)", log: log, type: .info)
    }

    /// Stops listening and cleans up.
    func stopListening() {
        DistributedNotificationCenter.default().removeObserver(self)
        os_log("IPC listener stopped", log: log, type: .info)
    }

    // MARK: - Handle Incoming Request

    @objc private func handleProcessRequest(_ notification: Notification) {
        guard let defaults = sharedDefaults else {
            os_log("Shared UserDefaults not available", log: log, type: .error)
            return
        }

        guard let requestID = defaults.string(forKey: XPCServiceDelegate.requestIDKey) else {
            os_log("No request ID found in shared defaults", log: log, type: .error)
            return
        }

        guard let text = defaults.string(forKey: XPCServiceDelegate.requestTextKey) else {
            os_log("No request text found in shared defaults", log: log, type: .error)
            postResponse(nil, error: "No request text found", requestID: requestID)
            return
        }

        os_log("Received processRequest (id: %{public}@) with %{public}d characters", log: log, type: .info, requestID, text.count)

        // Process the text
        processText(text) { [weak self] result, error in
            if let error = error {
                self?.postResponse(nil, error: error.localizedDescription, requestID: requestID)
            } else {
                self?.postResponse(result, error: nil, requestID: requestID)
            }
        }
    }

    /// Writes the response to shared UserDefaults and posts the response notification.
    private func postResponse(_ text: String?, error: String?, requestID: String) {
        guard let defaults = sharedDefaults else { return }

        defaults.set(requestID, forKey: XPCServiceDelegate.responseIDKey)
        defaults.set(text, forKey: XPCServiceDelegate.responseTextKey)
        defaults.set(error, forKey: XPCServiceDelegate.responseErrorKey)
        defaults.synchronize()

        DistributedNotificationCenter.default().postNotificationName(
            XPCServiceDelegate.responseNotification,
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )

        os_log("Posted response for request %{public}@", log: log, type: .info, requestID)
    }

    // MARK: - Text Processing

    /// Processes the text. Replace this with your actual logic.
    private func processText(_ text: String, completion: @escaping (String?, Error?) -> Void) {
        // TODO: Replace this placeholder with your actual text processing logic.
        let result = text
        completion(result, nil)
    }
}
