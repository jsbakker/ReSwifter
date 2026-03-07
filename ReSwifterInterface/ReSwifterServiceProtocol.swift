//
//  ReSwifterServiceProtocol.swift
//  ReSwifterInterface
//
//  Created by Jeffrey Bakker on 2026-03-06.
//

import Foundation

@objc public protocol ReSwifterServiceProtocol {
    // From extension to application
    @objc func extensionPostString(_ message: String)
    @objc func applicationGetString(completion: @escaping (String) -> Void)

    // From application to extension
    @objc func applicationPostString(_ message: String)
    @objc func extensionGetString(completion: @escaping (String) -> Void)
}

@objc public protocol ReSwifterServiceHandShakeProtocol {
    @objc func registerRsExtensionEndpoint(_ endpoint: NSXPCListenerEndpoint, completion: @escaping (Bool) -> Void)
    @objc func registerRsApplicationEndpoint(_ endpoint: NSXPCListenerEndpoint, completion: @escaping (Bool) -> Void)
}
