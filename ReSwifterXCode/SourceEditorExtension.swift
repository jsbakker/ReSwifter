//
//  SourceEditorExtension.swift
//  ReSwifterXCode
//
//  Created by Jeffrey Bakker on 2026-02-27.
//

import Foundation
import XcodeKit
import os.log

class SourceEditorExtension: NSObject, XCSourceEditorExtension {

    func extensionDidFinishLaunching() {
        // If your extension needs to do any work at launch, implement this optional method.
        os_log("Extension ready", type: .debug)
    }

    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        let namespace = Bundle(for: type(of: self)).bundleIdentifier!
        let resiwfter = ReSwifterCommand.className()
        return [[.identifierKey: "\(namespace)\(resiwfter)",
                 .classNameKey: resiwfter,
                 .nameKey: NSLocalizedString("ReSwifter", comment: "ReSwifter menu item")]]
    }
}
