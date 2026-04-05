import XCTest
import AppKit

final class ReSwifterUITests: XCTestCase {

    var app: XCUIApplication!

    let sampleMultilineText = """
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
    """

    let sampleObjCText = """
    #import <Foundation/Foundation.h>

    @interface Greeter : NSObject
    - (void)greet:(NSString *)name;
    @end

    @implementation Greeter
    - (void)greet:(NSString *)name {
        NSLog(@"Hello, %@!", name);
    }
    @end
    """

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["-useInMemoryStore"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5), "App did not launch successfully.")
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    // MARK: - Helpers

    /// Returns the main window, waiting for it to appear.
    private var mainWindow: XCUIElement {
        app.windows.firstMatch
    }

    /// Finds a descendant of the main window by accessibilityIdentifier, regardless of element type.
    private func element(id: String) -> XCUIElement {
        mainWindow.descendants(matching: .any).matching(identifier: id).firstMatch
    }

    // MARK: - Tests

    func test0_EmptyListMessageIsDisplayed() throws {
        // Given: App launched with an empty in-memory store
        // Then: The empty list message view should be visible

        XCTAssertTrue(mainWindow.waitForExistence(timeout: 5), "Main window should appear.")

        let emptyListMessage = element(id: "emptyListMessage")
        XCTAssertTrue(emptyListMessage.waitForExistence(timeout: 5), "Empty list message should be displayed.")
    }

    func test1_PasteSnippetCreatesNewItem() throws {
        // Given: App launched with an empty store
        // When:  Swift code is copied to the clipboard and pasted via Command+Shift+V
        // Then:  A new row appears showing "Generating summary..." with a spinner,
        //        the spinner disappears once generation finishes, and the summary text changes.

        XCTAssertTrue(mainWindow.waitForExistence(timeout: 5), "Main window should appear.")

        // 1. Confirm empty state before paste
        let emptyListMessage = element(id: "emptyListMessage")
        XCTAssertTrue(emptyListMessage.waitForExistence(timeout: 5), "Empty list message should be visible before paste.")

        // 2. Put sample Swift code on the clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(sampleMultilineText, forType: .string)

        // 3. Trigger "Add Snippet From Clipboard" via Command+Shift+V
        app.typeKey("V", modifierFlags: [.command, .shift])

        // 4. Wait for the new snippet row to appear
        let rowSummary = element(id: "snippetRowSummaryText")
        XCTAssertTrue(rowSummary.waitForExistence(timeout: 10), "Snippet row should appear in the list after paste.")

        // 5. The row briefly shows "Generating summary..." with a spinner while generation is
        //    in flight. If Apple Intelligence is unavailable the task completes before XCUITest
        //    can observe the transient state, so only wait on the spinner if it is still present.
        let spinner = element(id: "snippetRowSpinner")
        if spinner.waitForExistence(timeout: 2) {
            expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: spinner)
            waitForExpectations(timeout: 30)
        }

        // 6. Verify the summary text has changed from the default placeholder
        expectation(for: NSPredicate(format: "label != 'Generating summary...'"), evaluatedWith: rowSummary)
        waitForExpectations(timeout: 30)
        XCTAssertNotEqual(rowSummary.label, "Generating summary...", "Summary text should have updated once generation finished.")

        // 7. Verify the Language picker defaults to "Swift"
        let languagePicker = mainWindow.popUpButtons["languagePicker"]
        XCTAssertTrue(languagePicker.waitForExistence(timeout: 5), "Language picker should be visible in the detail pane.")
        XCTAssertEqual(languagePicker.value as? String, "Swift", "Language picker should default to Swift.")

        // 8. Verify the editor contains the pasted text
        let editor = mainWindow.textViews.firstMatch
        XCTAssertTrue(editor.waitForExistence(timeout: 5), "Highlighted editor should be visible.")
        XCTAssertEqual(editor.value as? String, sampleMultilineText, "Editor should contain the pasted snippet text.")
    }

    func test2_ObjCFolderSetsLanguagePicker() throws {
        // Given: App launched with an empty store
        // When:  An "Objective-C" folder is created and selected, then an ObjC snippet is pasted
        // Then:  The language picker shows "Objective-C" because the folder name matches the language

        XCTAssertTrue(mainWindow.waitForExistence(timeout: 5), "Main window should appear.")

        // 1. Open the File menu and invoke "New Snippets Folder..."
        app.menuBarItems["File"].click()
        app.menuItems["New Snippets Folder..."].click()

        // 2. Type the folder name and confirm.
        //    SwiftUI .alert() on macOS presents as a sheet attached to the window.
        //    Click the text field first to ensure it is focused before typing.
        let sheet = mainWindow.sheets.firstMatch
        XCTAssertTrue(sheet.waitForExistence(timeout: 5), "New Folder sheet should appear.")
        let folderNameField = sheet.textFields.firstMatch
        folderNameField.click()
        folderNameField.typeText("Objective-C")
        sheet.buttons["Create"].click()

        // 3. Confirm the folder selection has propagated before pasting.
        //    createFolder() sets selectedFolderId synchronously, but the @Query arrays in
        //    SnippetCommandMenu refresh asynchronously. Opening the folder toolbar menu and
        //    verifying "Objective-C" is listed there ensures all @Query observations have
        //    refreshed before addFromClipboard runs — otherwise the folders array is stale
        //    and the snippet gets no folder, defaulting to Swift.
        let folderMenuButton = element(id: "folderMenuButton")
        XCTAssertTrue(folderMenuButton.waitForExistence(timeout: 5), "Folder menu button should be visible in the toolbar.")
        folderMenuButton.click()
        let objcMenuItem = app.menuItems["Objective-C"]
        XCTAssertTrue(objcMenuItem.waitForExistence(timeout: 3), "Objective-C folder should appear as selected in the folder menu.")
        app.typeKey(.escape, modifierFlags: [])

        // 4. Put Objective-C code on the clipboard
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(sampleObjCText, forType: .string)

        // 5. Trigger "Add Snippet From Clipboard" via the toolbar button.
        //    The toolbar button uses the same ModelContext as ContentView and
        //    SnippetDetailView (the window's context). The Snippets menu and keyboard
        //    shortcut route through SnippetCommandMenu which has a separate ModelContext
        //    — the snippet's language change may not propagate to the window context
        //    before SnippetDetailView reads it.
        let addFromClipboardButton = element(id: "addFromClipboardButton")
        addFromClipboardButton.click()

        // 6. Wait for the new snippet row to appear
        let rowSummary = element(id: "snippetRowSummaryText")
        XCTAssertTrue(rowSummary.waitForExistence(timeout: 10), "Snippet row should appear in the list after paste.")

        // 7. Wait for any in-flight AI summary work to finish
        let spinner = element(id: "snippetRowSpinner")
        if spinner.waitForExistence(timeout: 2) {
            expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: spinner)
            waitForExpectations(timeout: 30)
        }

        // 8. Verify the language picker shows "Objective-C"
        //    The app matches the selected folder name against WebCppLanguage.displayName values,
        //    so a folder named "Objective-C" causes new snippets to default to that language.
        let languagePicker = mainWindow.popUpButtons["languagePicker"]
        XCTAssertTrue(languagePicker.waitForExistence(timeout: 5), "Language picker should be visible in the detail pane.")
        XCTAssertEqual(languagePicker.value as? String, "Objective-C", "Language picker should show Objective-C for snippets pasted into the Objective-C folder.")
    }

    func test3_StaleFolderSelectionFallsBackToAll() throws {
        // Given: App launched with an empty in-memory store right after test2
        //        persisted a selectedFolderId for a folder that only existed
        //        in test2's in-memory store
        // Then:  The app should default to "All" (no folder selected) and
        //        show the empty list message

        XCTAssertTrue(mainWindow.waitForExistence(timeout: 5), "Main window should appear.")

        // 1. Verify the empty list message is visible (no stale filter hiding items)
        let emptyListMessage = element(id: "emptyListMessage")
        XCTAssertTrue(emptyListMessage.waitForExistence(timeout: 5), "Empty list message should be displayed — a stale folder selection must not hide the empty state.")

        // 2. Verify the folder menu button shows "All"
        let folderMenuButton = element(id: "folderMenuButton")
        XCTAssertTrue(folderMenuButton.waitForExistence(timeout: 5), "Folder menu button should be visible.")
        folderMenuButton.click()
        let allMenuItem = app.menuItems["All"]
        XCTAssertTrue(allMenuItem.waitForExistence(timeout: 3), "'All' should appear in the folder menu.")
        app.typeKey(.escape, modifierFlags: [])
    }
}
