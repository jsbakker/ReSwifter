//
//  SnippetViewModelExtractCodeTests.swift
//  ReSwifterTests
//
//  Created by Jeffrey Bakker on 2026-04-11.
//

import XCTest
@testable import ReSwifter

@MainActor
final class SnippetViewModelExtractCodeTests: XCTestCase {

    var sut: SnippetViewModel!

    override func setUp() {
        super.setUp()
        sut = SnippetViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_extractCode_noCodeBlock_returnsOriginal() {
        let input = "hello world"
        XCTAssertEqual(sut.extractCode(from: input), "hello world")
    }

    func test_extractCode_emptyString_returnsEmpty() {
        XCTAssertEqual(sut.extractCode(from: ""), "")
    }

    func test_extractCode_swiftCodeBlock_extractsBody() {
        let input = "```swift\nlet x = 1\n```"
        XCTAssertEqual(sut.extractCode(from: input), "let x = 1\n")
    }

    func test_extractCode_untaggedCodeBlock_extractsBody() {
        let input = "```\nsome code\n```"
        XCTAssertEqual(sut.extractCode(from: input), "some code\n")
    }

    func test_extractCode_codeBlockWithSurroundingText() {
        let input = "Before\n```\ncode\n```\nAfter"
        XCTAssertEqual(sut.extractCode(from: input), "code\n")
    }

    func test_extractCode_multipleCodeBlocks_extractsFirst() {
        let input = "```\nfirst\n```\n```\nsecond\n```"
        XCTAssertEqual(sut.extractCode(from: input), "first\n")
    }

    func test_extractCode_incompleteCodeBlock_returnsOriginal() {
        let input = "```swift\nno closing"
        XCTAssertEqual(sut.extractCode(from: input), input)
    }

    func test_extractCode_multilineCode_extractsAll() {
        let input = "```\nline1\nline2\nline3\n```"
        XCTAssertEqual(sut.extractCode(from: input), "line1\nline2\nline3\n")
    }
}
