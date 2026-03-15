//
//  SyntaxHighlightWebView.swift
//  ReSwifter
//
//  Displays syntax-highlighted source code using WebCpp and a native WKWebView.
//

import Foundation
import SwiftUI
import WebKit

struct SyntaxHighlightWebView: NSViewRepresentable {
    let sourceCode: String

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        loadHighlightedHTML(into: webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        loadHighlightedHTML(into: webView)
    }

    private func loadHighlightedHTML(into webView: WKWebView) {
        guard !sourceCode.isEmpty else {
            webView.loadHTMLString("", baseURL: nil)
            return
        }

        // Extract just the code from a fenced code block if the snippet contains markdown.
        let code = extractCodeBlock(from: sourceCode)

        let html = WebCppDriver.highlightString(code, filename: "snippet.cpp") ?? fallbackHTML(for: code)
        webView.loadHTMLString(html, baseURL: nil)
    }

    /// Pulls the contents of the first ``` fenced code block, or returns the original text as-is.
    private func extractCodeBlock(from text: String) -> String {
        let pattern = "```[^\\n]*\\n([\\s\\S]*?)```"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let codeRange = Range(match.range(at: 1), in: text) else {
            return text
        }
        return String(text[codeRange])
    }

    private func fallbackHTML(for text: String) -> String {
        let escaped = text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
        return "<html><body><pre>\(escaped)</pre></body></html>"
    }
}
