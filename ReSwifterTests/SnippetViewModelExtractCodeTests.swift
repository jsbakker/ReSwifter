//
//  SnippetViewModelExtractCodeTests.swift
//  ReSwifterTests
//
//  Created by Jeffrey Bakker on 2026-04-11.
//

import Testing
@testable import ReSwifter

@MainActor
struct SnippetViewModelExtractCodeTests {

    var sut: SnippetViewModel

    init() {
        sut = SnippetViewModel()
    }

    @Test
    func extractCode_noCodeBlock_returnsOriginal() {
        let input = "hello world"
        #expect(sut.extractCode(from: input) == "hello world")
    }

    @Test
    func extractCode_emptyString_returnsEmpty() {
        #expect(sut.extractCode(from: "") == "")
    }

    @Test
    func extractCode_swiftCodeBlock_extractsBody() {
        let input = "```swift\nlet x = 1\n```"
        #expect(sut.extractCode(from: input) == "let x = 1\n")
    }

    @Test
    func extractCode_untaggedCodeBlock_extractsBody() {
        let input = "```\nsome code\n```"
        #expect(sut.extractCode(from: input) == "some code\n")
    }

    @Test
    func extractCode_codeBlockWithSurroundingText() {
        let input = "Before\n```\ncode\n```\nAfter"
        #expect(sut.extractCode(from: input) == "code\n")
    }

    @Test
    func extractCode_multipleCodeBlocks_extractsFirst() {
        let input = "```\nfirst\n```\n```\nsecond\n```"
        #expect(sut.extractCode(from: input) == "first\n")
    }

    @Test
    func extractCode_incompleteCodeBlock_returnsOriginal() {
        let input = "```swift\nno closing"
        #expect(sut.extractCode(from: input) == input)
    }

    @Test
    func extractCode_multilineCode_extractsAll() {
        let input = "```\nline1\nline2\nline3\n```"
        #expect(sut.extractCode(from: input) == "line1\nline2\nline3\n")
    }
}
