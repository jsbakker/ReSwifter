//
//  ChildLanguageTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that child language blocks are highlighted with the correct child
/// language rules while the parent language highlighting works before and after.
struct ChildLanguageTests {

    // MARK: - C++ with inline assembly

    @Test func cppInlineAsmHighlightsAssemblyKeywords() {
        let source = """
        int x = 5;
        asm {
            mov eax, 1
        }
        """
        let html = HighlightTestHelper.highlight(source, language: "cpp")
        // Assembly keyword "mov" should be highlighted inside the asm block
        #expect(html.contains("<font CLASS=keyword>mov</font>"))
        // Assembly register "eax" should be highlighted as a type
        #expect(html.contains("<font CLASS=keytype>eax</font>"))
    }

    @Test func cppInlineAsmPreservesParentHighlighting() {
        let source = """
        int x = 5;
        asm {
            mov eax, 1
        }
        int y = 10;
        """
        let html = HighlightTestHelper.highlight(source, language: "cpp")
        // C++ type "int" should be highlighted before the asm block
        #expect(html.contains("<font CLASS=keytype>int</font> x"))
        // C++ type "int" should also be highlighted after the asm block
        #expect(html.contains("<font CLASS=keytype>int</font> y"))
    }

    // MARK: - HTML with inline CSS

    @Test func htmlInlineCssHighlightsCssRules() {
        let source = """
        <html>
        <style>
        body { color: red; }
        </style>
        </html>
        """
        let html = HighlightTestHelper.highlight(source, language: "html")
        // CSS property "color" should be highlighted as a type inside the style block
        #expect(html.contains("<font CLASS=keytype>color</font>"))
    }

    // MARK: - HTML with inline JavaScript

    @Test func htmlInlineJsHighlightsJsKeywords() {
        let source = """
        <html>
        <script>
        const x = 42;
        </script>
        </html>
        """
        let html = HighlightTestHelper.highlight(source, language: "html")
        // JS keyword "const" should be highlighted inside the script block
        #expect(html.contains("<font CLASS=keyword>const</font>"))
    }

    // MARK: - HTML with both CSS and JavaScript

    @Test func htmlWithBothCssAndJsHighlightsAllThreeLanguages() {
        let source = """
        <html>
        <head>
        <style>
        body { color: red; }
        </style>
        <script>
        const x = 42;
        </script>
        </head>
        <body>
        <p>Hello</p>
        </body>
        </html>
        """
        let html = HighlightTestHelper.highlight(source, language: "html")
        // HTML tags should be highlighted before, between, and after child blocks
        #expect(html.contains("<font CLASS=preproc>"))
        // CSS property inside the style block
        #expect(html.contains("<font CLASS=keytype>color</font>"))
        // JS keyword inside the script block
        #expect(html.contains("<font CLASS=keyword>const</font>"))
    }
}
