//
//  ExtensionXPCService.swift
//  ReSwifter
//
//  Created by Jeffrey Bakker on 2026-03-06.
//

import Foundation
import ReSwifterInterface

class ExtensionXPCService {

    var rsConnection: NSXPCConnection?

    func connect() {
        if rsConnection != nil {
            print("Already connected to service.")
            return
        }

        rsConnection = NSXPCConnection(serviceName: "com.JeffreyBakker.ReSwifter.Service")
        rsConnection?.remoteObjectInterface = NSXPCInterface(with: ReSwifterServiceProtocol.self)
        rsConnection?.resume()
    }

    func receiveMessage() {
        if let proxy = rsConnection?.remoteObjectProxy as? ReSwifterServiceProtocol {
            proxy.applicationGetString(completion: {value in
                print("Application Received value: \(value)")
            })
        } else {
            print("Application failed to get message.")
        }
    }
}
