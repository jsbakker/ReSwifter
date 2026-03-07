//
//  ReSwifterService.swift
//  ReSwifterService
//
//  Created by Jeffrey Bakker on 2026-03-06.
//

import Foundation

/// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
//class ReSwifterService: NSObject, ReSwifterServiceProtocol {
//    
//    /// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
//    @objc func performCalculation(firstNumber: Int, secondNumber: Int, with reply: @escaping (Int) -> Void) {
//        let response = firstNumber + secondNumber
//        reply(response)
//    }
//}

import ReSwifterInterface

class ReSwifterService: NSObject, ReSwifterServiceProtocol {

    private var incomingToAppMessage: String?
    private var outgoingFromAppMessage: String?

    @objc func extensionPostString(_ message: String) {
        incomingToAppMessage = message
    }
    
    @objc func applicationGetString(completion: @escaping (String) -> Void) {
        guard let incomingToAppMessage else {
            return
        }
        completion(incomingToAppMessage)
    }
    
    @objc func applicationPostString(_ message: String) {
        outgoingFromAppMessage = message
    }
    
    @objc func extensionGetString(completion: @escaping (String) -> Void) {
        guard let outgoingFromAppMessage else {
            return
        }
        completion(outgoingFromAppMessage)
    }
}

class ReSwifterServiceDelegate: NSObject, NSXPCListenerDelegate {

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: ReSwifterServiceProtocol.self)
        newConnection.exportedObject = ReSwifterService()
        newConnection.resume()
        return true
    }
}
