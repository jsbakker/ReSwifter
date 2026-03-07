//
//  AppLauncherMachService.swift
//  ReSwifterXCode
//
//  Created by Jeffrey Bakker on 2026-03-05.
//
//  Approach: NSXPCConnection with a Mach service name.
//
//  This class launches the host app (ReSwifter.app) and connects to it
//  via NSXPCConnection using init(machServiceName:options:). The host app
//  registers itself as a Mach service listener using NSXPCListener.
//
//  Requirements:
//  - The host app must create an NSXPCListener for the Mach service name
//    and vend an object conforming to ReSwifterXPCProtocol.
//  - The host app must advertise the Mach service name in a launchd plist
//    (e.g. ~/Library/LaunchAgents/com.JeffreyBakker.ReSwifter.xpc.plist) or
//    use NSXPCListener(machServiceName:) at runtime.
//  - The App Sandbox entitlement must be configured to allow Mach lookup
//    for this service name, or sandboxing must be disabled.
//

import Foundation
import AppKit
import os.log

class AppLauncherMachService {

    /// The Mach service name the host app advertises.
    /// Must match the name used by the NSXPCListener in the host app.
    private let machServiceName = "com.JeffreyBakker.ReSwifter.xpc"

    /// The bundle identifier of the host app to launch.
    private let hostAppBundleID = "com.JeffreyBakker.ReSwifter"

    private var connection: NSXPCConnection?

    private let log = OSLog(subsystem: "com.JeffreyBakker.ReSwifterXCode", category: "MachService")

    // MARK: - Launch Host App

    /// Launches the host app (ReSwifter.app) if it is not already running.
    public func launchHostApp(completion: @escaping (Bool, Error?) -> Void) {
        // Check if already running
        let running = NSRunningApplication.runningApplications(
            withBundleIdentifier: hostAppBundleID
        )
        if !running.isEmpty {
            os_log("Host app already running", log: log, type: .debug)
            completion(true, nil)
            return
        }

        // Locate the host app via its bundle ID
        guard let appURL = NSWorkspace.shared.urlForApplication(
            withBundleIdentifier: hostAppBundleID
        ) else {
            let error = NSError(
                domain: "ReSwifterMachService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Could not find host app with bundle ID: \(hostAppBundleID)"]
            )
            os_log("Host app not found: %{public}@", log: log, type: .error, hostAppBundleID)
            completion(false, error)
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = false  // launch in background

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

    // MARK: - XPC Connection

    /// Establishes an NSXPCConnection to the host app via its Mach service name.
    /// The host app must already be running and have registered the listener.
    func connect() {
        let conn = NSXPCConnection(machServiceName: machServiceName)
        conn.remoteObjectInterface = NSXPCInterface(with: ReSwifterXPCProtocol.self)

        conn.interruptionHandler = { [weak self] in
            os_log("Mach XPC connection interrupted", log: self?.log ?? .default, type: .error)
        }
        conn.invalidationHandler = { [weak self] in
            os_log("Mach XPC connection invalidated", log: self?.log ?? .default, type: .error)
            self?.connection = nil
        }

        conn.activate()
        connection = conn
        os_log("Mach XPC connection established to: %{public}@", log: log, type: .info, machServiceName)
    }

    /// Disconnects the current XPC connection.
    func disconnect() {
        connection?.invalidate()
        connection = nil
    }

    // MARK: - Remote Calls

    /// Sends text to the host app for processing via the Mach XPC service.
    func processText(_ text: String, reply: @escaping (String?, Error?) -> Void) {
        guard let connection = connection else {
            let error = NSError(
                domain: "ReSwifterMachService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "No active XPC connection. Call connect() first."]
            )
            reply(nil, error)
            return
        }

        let proxy = connection.remoteObjectProxyWithErrorHandler { error in
            os_log("Mach XPC remote object error: %{public}@", type: .error, error.localizedDescription)
            reply(nil, error)
        } as! ReSwifterXPCProtocol

        proxy.processText(text, withReply: reply)
    }

    // MARK: - Convenience

    /// Launches the host app (if needed), connects via Mach service, and sends text.
    func launchAndProcess(_ text: String, reply: @escaping (String?, Error?) -> Void) {
        launchHostApp { [weak self] success, error in
            guard let self = self, success else {
                reply(nil, error)
                return
            }
            // Brief delay to allow the host app to register its Mach service listener
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.connect()
                self.processText(text, reply: reply)
            }
        }
    }
}
