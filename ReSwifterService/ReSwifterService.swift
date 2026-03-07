//
//  ReSwifterService.swift
//  ReSwifterService
//
//  Created by Jeffrey Bakker on 2026-03-06.
//
//  Middleman XPC service that brokers communication between the
//  Xcode Source Editor Extension and the host app (ReSwifter.app).
//
//  Both the extension and the host app connect to this service via
//  NSXPCConnection(serviceName:). The service holds pending reply
//  blocks so that neither side needs to poll.
//

import Foundation
import ReSwifterInterface

/// Shared state that persists across connections within this XPC
/// service process. Because both the extension and the host app
/// get their own NSXPCConnection (and therefore their own
/// ReSwifterService instance), we need shared storage for the
/// pending work and reply blocks.
final class ReSwifterServiceBroker {
    static let shared = ReSwifterServiceBroker()

    private let queue = DispatchQueue(label: "com.JeffreyBakker.ReSwifterService.broker")

    /// Reply block from the extension, waiting for the host app's result.
    private var extensionReply: ((String?, String?) -> Void)?

    /// Reply block from the host app, waiting for work from the extension.
    private var appWaitReply: ((String) -> Void)?

    /// Text submitted by the extension that hasn't been picked up yet.
    private var pendingText: String?

    private init() {}

    // MARK: - Called by extension's connection

    /// Extension submits text for processing.
    func submitWork(_ text: String, reply: @escaping (String?, String?) -> Void) {
        queue.async {
            // Store the extension's reply for later
            self.extensionReply = reply

            if let appReply = self.appWaitReply {
                // Host app is already waiting — deliver immediately
                self.appWaitReply = nil
                appReply(text)
            } else {
                // Host app hasn't called waitForWork yet — queue it
                self.pendingText = text
            }
        }
    }

    // MARK: - Called by host app's connection

    /// Host app registers to receive work. The reply is called
    /// when work becomes available (may be immediate if queued).
    func registerAppWait(reply: @escaping (String) -> Void) {
        queue.async {
            if let text = self.pendingText {
                // Work is already queued — deliver immediately
                self.pendingText = nil
                reply(text)
            } else {
                // No work yet — hold the reply until extension submits
                self.appWaitReply = reply
            }
        }
    }

    /// Host app delivers the processed result back to the extension.
    func deliverResult(_ result: String?, error: String?) {
        queue.async {
            if let extReply = self.extensionReply {
                self.extensionReply = nil
                extReply(result, error)
            }
        }
    }
}

/// Per-connection exported object. Each connection (from extension or
/// host app) gets its own instance, but they all delegate to the
/// shared ReSwifterServiceBroker.
class ReSwifterService: NSObject, ReSwifterServiceProtocol {

    // MARK: - Called by the Extension

    func processText(_ text: String, withReply reply: @escaping (String?, String?) -> Void) {
        ReSwifterServiceBroker.shared.submitWork(text, reply: reply)
    }

    // MARK: - Called by the Host App

    func waitForWork(withReply reply: @escaping (String) -> Void) {
        ReSwifterServiceBroker.shared.registerAppWait(reply: reply)
    }

    func deliverResult(_ result: String?, error: String?) {
        ReSwifterServiceBroker.shared.deliverResult(result, error: error)
    }
}
