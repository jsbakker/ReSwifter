//
//  ReSwifterServiceProtocol.swift
//  ReSwifterInterface
//
//  Created by Jeffrey Bakker on 2026-03-06.
//
//  Shared protocols used by the extension, the host app, and the
//  middleman XPC service (ReSwifterService).
//
//  IPC flow (no polling, no bidirectional endpoint exchange):
//
//  1. The host app connects to the middleman and calls
//     `waitForWork(reply:)`. The middleman holds the reply block.
//
//  2. The extension connects to the middleman and calls
//     `processText(_:withReply:)`. The middleman stores the
//     extension's reply block, then immediately delivers the text
//     to the host app via the held `waitForWork` reply block.
//
//  3. The host app processes the text, then calls
//     `deliverResult(_:error:)` on the middleman. The middleman
//     calls the extension's stored reply block with the result.
//
//  Both sides use completion handlers as the notification mechanism,
//  so there is no polling.
//

import Foundation

/// Protocol exposed by the middleman XPC service.
/// Both the extension and the host app connect to this.
@objc public protocol ReSwifterServiceProtocol {

    // MARK: - Called by the Extension

    /// Sends text to the host app for processing.
    /// The reply is called when the host app delivers its result.
    func processText(_ text: String, withReply reply: @escaping (String?, String?) -> Void)

    // MARK: - Called by the Host App

    /// Blocks (via held reply) until the extension submits work.
    /// The reply delivers the text that needs processing.
    func waitForWork(withReply reply: @escaping (String) -> Void)

    /// Delivers the processed result (or error) back to the extension.
    func deliverResult(_ result: String?, error: String?)
}
