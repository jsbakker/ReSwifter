//
//  ObjectiveCHighlightTests.swift
//  ReSwifterTests
//

import Testing
import WebCpp

/// Tests that ObjectiveC syntax highlighting rules produce correct output.
struct ObjectiveCHighlightTests {

    private func highlight(_ source: String) -> String {
        HighlightTestHelper.highlight(source, language: "m")
    }

    // MARK: Keywords

    @Test func keywordsAreHighlighted() {
        let html = highlight("__block")
        #expect(html.contains("<font CLASS=keyword>__block</font>"))
    }

    // MARK: Types

    @Test func typesAreHighlighted() {
        let html = highlight("BOOL")
        #expect(html.contains("<font CLASS=keytype>BOOL</font>"))
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

    // MARK: Comments

    @Test func blockCommentsAreHighlighted() {
        let html = highlight("/* a comment */")
        #expect(html.contains("<font CLASS=comment>/* a comment */</font>"))
    }

    @Test func inlineCommentsAreHighlighted() {
        let html = highlight("// comment")
        #expect(html.contains("<font CLASS=comment>// comment</font>"))
    }

    // MARK: Labels

    @Test func labelsAreHighlighted() {
        let html = highlight("label:")
        #expect(html.contains("<font CLASS=preproc>label:</font>"))
    }

    // MARK: - Comprehensive Snippet

    @Test func comprehensiveSnippetHighlightsAllRules() {
        let source = """
        /* Block comment */
        #import <Foundation/Foundation.h>
        // Line comment
        @interface Example : NSObject
        @property BOOL flag;
        @end
        @implementation Example
        - (void)run {
            self.flag = YES;
            CGFloat pi = 3.14;
            NSInteger x = 42;
            NSString *s = @"hello";
            char c = 'x';
            x = x + 1;
        label:
            NSLog(@"%ld", (long)x);
        }
        @end
        """
        let html = highlight(source)

        #expect(html.contains("<font CLASS=keyword>self</font>"))
        #expect(html.contains("<font CLASS=keytype>BOOL</font>"))
        #expect(html.contains("<font CLASS=keytype>CGFloat</font>"))
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
