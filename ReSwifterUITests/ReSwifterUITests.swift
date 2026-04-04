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
    }
}
