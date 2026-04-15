//
//  ExtensionIPCServiceTests.swift
//  ReSwifterTests
//
//  Created by Jeffrey Bakker on 2026-04-14.
//

import Combine
import XCTest
@testable import ReSwifter

@MainActor
final class ExtensionIPCServiceTests: XCTestCase {

    var sut: ExtensionIPCService!
    var testDefaults: UserDefaults!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() async throws {
        testDefaults = UserDefaults(suiteName: "com.JeffreyBakker.ReSwifter.Tests")!
        clearTestDefaults()
        sut = ExtensionIPCService(userDefaults: testDefaults)
    }

    override func tearDown() async throws {
        sut?.stopListening()
        sut = nil
        clearTestDefaults()
        testDefaults = nil
        cancellables.removeAll()
    }

    // MARK: - Tests

    func test_receivesRequest_publishesTextAndSetsPendingFlag() async throws {
        simulateExtensionRequest(text: "let x = 42")
        await waitForPendingRequest()

        XCTAssertEqual(sut.receivedText, "let x = 42")
        XCTAssertTrue(sut.hasPendingRequest)
    }

    func test_sendResponse_writesTextAndIDToDefaults_clearsPendingState() async throws {
        let requestID = simulateExtensionRequest(text: "original code")
        await waitForPendingRequest()

        sut.sendResponse("edited code")

        XCTAssertEqual(testDefaults.string(forKey: ExtensionIPCService.responseTextKey), "edited code")
        XCTAssertEqual(testDefaults.string(forKey: ExtensionIPCService.responseIDKey), requestID)
        XCTAssertNil(testDefaults.string(forKey: ExtensionIPCService.responseErrorKey))
        XCTAssertFalse(sut.hasPendingRequest)
        XCTAssertNil(sut.receivedText)
    }

    func test_cancelResponse_writesErrorAndClearsPendingState() async throws {
        let requestID = simulateExtensionRequest(text: "some code")
        await waitForPendingRequest()

        sut.cancelResponse()

        XCTAssertNil(testDefaults.string(forKey: ExtensionIPCService.responseTextKey))
        XCTAssertNotNil(testDefaults.string(forKey: ExtensionIPCService.responseErrorKey))
        XCTAssertEqual(testDefaults.string(forKey: ExtensionIPCService.responseIDKey), requestID)
        XCTAssertFalse(sut.hasPendingRequest)
        XCTAssertNil(sut.receivedText)
    }

    func test_missingRequestID_doesNotSetPendingState() async throws {
        testDefaults.set("some code", forKey: ExtensionIPCService.requestTextKey)
        postRequestNotification()

        try await Task.sleep(for: .milliseconds(200))

        XCTAssertFalse(sut.hasPendingRequest)
        XCTAssertNil(sut.receivedText)
    }

    func test_missingRequestText_postsErrorResponse() async throws {
        let requestID = UUID().uuidString
        testDefaults.set(requestID, forKey: ExtensionIPCService.requestIDKey)
        postRequestNotification()

        try await Task.sleep(for: .milliseconds(200))

        XCTAssertFalse(sut.hasPendingRequest)
        XCTAssertNotNil(testDefaults.string(forKey: ExtensionIPCService.responseErrorKey))
        XCTAssertEqual(testDefaults.string(forKey: ExtensionIPCService.responseIDKey), requestID)
    }

    // MARK: - Helpers

    private func clearTestDefaults() {
        for key in [ExtensionIPCService.requestTextKey, ExtensionIPCService.requestIDKey,
                    ExtensionIPCService.responseTextKey, ExtensionIPCService.responseErrorKey,
                    ExtensionIPCService.responseIDKey] {
            testDefaults.removeObject(forKey: key)
        }
    }

    @discardableResult
    private func simulateExtensionRequest(text: String) -> String {
        let requestID = UUID().uuidString
        testDefaults.set(text, forKey: ExtensionIPCService.requestTextKey)
        testDefaults.set(requestID, forKey: ExtensionIPCService.requestIDKey)
        postRequestNotification()
        return requestID
    }

    private func postRequestNotification() {
        DistributedNotificationCenter.default().postNotificationName(
            ExtensionIPCService.requestNotification,
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )
    }

    private func waitForPendingRequest() async {
        let exp = expectation(description: "hasPendingRequest becomes true")
        sut.$hasPendingRequest
            .filter { $0 }
            .first()
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)
        await fulfillment(of: [exp], timeout: 2)
    }
}
