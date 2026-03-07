//
//  ReSwifterXPCProtocol.swift
//  ReSwifterXCode
//
//  Created by Jeffrey Bakker on 2026-03-05.
//

import Foundation

/// The XPC protocol that the host app (ReSwifter.app) exposes.
/// Both the extension and the host app must share this protocol definition.
@objc protocol ReSwifterXPCProtocol {
    /// Sends source text to the host app for processing and receives transformed text back.
    func processText(_ text: String, withReply reply: @escaping (String?, Error?) -> Void)
}
