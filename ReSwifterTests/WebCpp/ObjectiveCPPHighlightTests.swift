//
//  ObjectiveCPPHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that ObjectiveCPP syntax highlighting rules produce correct output.
struct ObjectiveCPPHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "mm")
    }

    // MARK: Numbers

    @Test func integersAreHighlighted() {
        let html = highlight("42")
        #expect(html.contains("<font CLASS=integer>42</font>"))
    }

    @Test func floatsAreHighlighted() {
        let html = highlight("3.14")
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
    }

    // MARK: Strings

    @Test func doubleQuotedStringsAreHighlighted() {
        let html = highlight("\"hello\"")
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    @Test func singleQuotedStringsAreHighlighted() {
        let html = highlight("'hello'")
        #expect(html.contains("<font CLASS=sinquot>"))
    }

    // MARK: Symbols

    @Test func symbolsAreHighlighted() {
        let html = highlight("x + y")
        #expect(html.contains("<font CLASS=symbols>+</font>"))
    }

    // MARK: Preprocessor

    @Test func preprocessorDirectivesAreHighlighted() {
        let html = highlight("#define FOO")
        #expect(html.contains("<font CLASS=preproc>"))
    }

    // MARK: - Preprocessor Token Tests

    @Test func preprocMacroNameIsHighlighted() {
        let html = highlight("#define MACRO_NAME")
        #expect(html.contains("<font CLASS=preproc>#define</font>"))
        #expect(html.contains("<font CLASS=preproc>MACRO_NAME</font>"))
    }

    @Test func preprocMacroWithFloatValue() {
        let html = highlight("#define NUMBER 0.076")
        #expect(html.contains("<font CLASS=preproc>#define</font>"))
        #expect(html.contains("<font CLASS=preproc>NUMBER</font>"))
        #expect(html.contains("<font CLASS=floatpt>0.076</font>"))
    }

    @Test func preprocMacroBeforeEqualsIsHighlighted() {
        let html = highlight("#define NUMBER = 0.076")
        #expect(html.contains("<font CLASS=preproc>#define</font>"))
        #expect(html.contains("<font CLASS=preproc>NUMBER</font>"))
        #expect(!html.contains("<font CLASS=preproc>=</font>"))
    }

    @Test func preprocMacroWithFloatAndComment() {
        let html = highlight("#define LITERAL 0.076 // comment")
        #expect(html.contains("<font CLASS=preproc>#define</font>"))
        #expect(html.contains("<font CLASS=preproc>LITERAL</font>"))
        #expect(html.contains("<font CLASS=floatpt>0.076</font>"))
        #expect(html.contains("<font CLASS=comment>// comment"))
    }

    @Test func preprocDoubleQuoteIncludeIsHighlighted() {
        let html = highlight("#include \"myheader.h\"")
        #expect(html.contains("<font CLASS=preproc>#include</font>"))
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    @Test func preprocAngleBracketIncludeIsHighlighted() {
        let html = highlight("#include <another_header.h>")
        #expect(html.contains("<font CLASS=preproc>#include</font>"))
        #expect(html.contains("<font CLASS=dblquot>&lt;another_header.h&gt;</font>"))
    }

    @Test func preprocIfdefGuardIsHighlighted() {
        let html = highlight("#ifdef GUARD")
        #expect(html.contains("<font CLASS=preproc>#ifdef</font>"))
        #expect(html.contains("<font CLASS=preproc>GUARD</font>"))
    }

    @Test func preprocEndifAloneHasNoSecondToken() {
        let html = highlight("#endif")
        #expect(html.contains("<font CLASS=preproc>#endif</font>"))
        let count = html.components(separatedBy: "<font CLASS=preproc>").count - 1
        #expect(count == 1)
    }

    @Test func preprocEndifWithCommentHasNoSecondPreprocToken() {
        let html = highlight("#endif // comment")
        #expect(html.contains("<font CLASS=preproc>#endif</font>"))
        #expect(html.contains("<font CLASS=comment>// comment"))
        let count = html.components(separatedBy: "<font CLASS=preproc>").count - 1
        #expect(count == 1)
    }

    @Test func preprocIfOrOperatorHighlightsBothIdentifiers() {
        let html = highlight("#if defined(__APPLE__) || defined(__linux__)")
        #expect(html.contains("<font CLASS=preproc>#if</font>"))
        let count = html.components(separatedBy: "<font CLASS=preproc>defined</font>").count - 1
        #expect(count == 2)
    }

    @Test func preprocIfAndOperatorHighlightsBothIdentifiers() {
        let html = highlight("#if defined(X) && defined(Y)")
        #expect(html.contains("<font CLASS=preproc>#if</font>"))
        let count = html.components(separatedBy: "<font CLASS=preproc>defined</font>").count - 1
        #expect(count == 2)
    }

    @Test func preprocIfMultipleOperatorsHighlightAllIdentifiers() {
        let html = highlight("#if defined(A) || defined(B) || defined(C)")
        let count = html.components(separatedBy: "<font CLASS=preproc>defined</font>").count - 1
        #expect(count == 3)
    }

    // MARK: - Indented Preprocessor Tests

    @Test func preprocWithLeadingSpacesIsHighlighted() {
        let html = highlight("    #define LOCAL_VAL 10")
        #expect(html.contains("<font CLASS=preproc>#define</font>"))
        #expect(html.contains("<font CLASS=preproc>LOCAL_VAL</font>"))
    }

    @Test func preprocWithLeadingSpacesIfdefIsHighlighted() {
        let html = highlight("    #ifdef PLATFORM")
        #expect(html.contains("<font CLASS=preproc>#ifdef</font>"))
        #expect(html.contains("<font CLASS=preproc>PLATFORM</font>"))
    }

    @Test func preprocWithLeadingSpacesAngleBracketIncludeIsHighlighted() {
        let html = highlight("    #include <stdlib.h>")
        #expect(html.contains("<font CLASS=preproc>#include</font>"))
        #expect(html.contains("<font CLASS=dblquot>&lt;stdlib.h&gt;</font>"))
    }

    // MARK: Comments

    @Test func blockCommentsAreHighlighted() {
        let html = highlight("/* a comment */")
        #expect(html.contains("<font CLASS=comment>/* a comment */</font>"))
    }

    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("// comment")
        #expect(html.contains("<font CLASS=comment>// comment</font>"))
    }

    // MARK: Raw Strings

    @Test func rawStringsAreHighlighted() {
        let html = highlight("R\"(raw string)\"")
        #expect(html.contains("<font CLASS=dblquot>"))
    }

    // MARK: Labels

    @Test func labelsAreHighlighted() {
        let html = highlight("label:")
        #expect(html.contains("<font CLASS=preproc>label:</font>"))
    }

    // MARK: - Underscore Numbers

    @Test func underscoreNumbersAreNotFullyHighlighted() {
        let html = highlight("1_000")
        #expect(!html.contains("<font CLASS=integer>1_000</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        /* Block comment */
        #import <Foundation/Foundation.h>
        // Line comment
        class CppHelper {
        public:
            bool flag = true;
            int x = 42;
            double pi = 3.14;
            void run() {
                auto s = "hello";
                char c = 'x';
                auto raw = R"(raw string)";
                x = x + 1;
        label:
                NSLog(@"%d", x);
            }
        };
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>class</font>"))
        #expect(html.contains("<font CLASS=keytype>bool</font>"))
        #expect(html.contains("<font CLASS=integer>42</font>"))
        #expect(html.contains("<font CLASS=floatpt>3.14</font>"))
        #expect(html.contains("<font CLASS=dblquot>")) // double-quoted string highlighted
        #expect(html.contains("<font CLASS=sinquot>")) // single-quoted char highlighted
        #expect(html.contains("<font CLASS=symbols>+</font>"))
        #expect(html.contains("<font CLASS=preproc>#import</font>"))
        #expect(html.contains("<font CLASS=comment>/* Block comment */</font>"))
        #expect(html.contains("<font CLASS=comment>// Line comment</font>"))
        #expect(html.contains("<font CLASS=preproc>label:</font>"))
    }
}
