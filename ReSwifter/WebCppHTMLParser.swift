//
//  WebCppHTMLParser.swift
//  ReSwifter
//
//  Parses WebCpp's HTML output into plain text with syntax token ranges,
//  without using WebKit or NSAttributedString(html:).
//

import Foundation

struct WebCppTokenRange {
    let range: NSRange
    let tokenClass: String   // e.g. "keyword", "comment", "dblquot"
}

struct WebCppParseResult {
    let plainText: String
    let tokenRanges: [WebCppTokenRange]
}

/// Parses the HTML output from WebCpp into plain text with syntax token ranges.
///
/// WebCpp wraps tokens in `<font CLASS=keyword>text</font>` tags inside a `<pre>` block.
/// Normal (unhighlighted) text appears between those tags without any wrapping.
/// This function strips all HTML and returns the plain text plus an `NSRange` for
/// each colored token, suitable for applying directly to an `NSTextStorage`.
func parseWebCppHTML(_ html: String) -> WebCppParseResult {

    // ── 1. Locate the <pre> block ──────────────────────────────────────────
    guard let preStart = html.range(of: "<pre>"),
          let preEnd   = html.range(of: "</pre>") else {
        // Malformed output: strip tags and return as plain text
        let plain = html.replacingOccurrences(of: "<[^>]+>",
                                               with: "",
                                               options: .regularExpression)
        return WebCppParseResult(plainText: plain, tokenRanges: [])
    }

    let content = String(html[preStart.upperBound..<preEnd.lowerBound])

    // ── 2. Scan character-by-character ─────────────────────────────────────
    var plainText  = ""
    var utf16Count = 0         // running UTF-16 length of plainText
    var tokenRanges: [WebCppTokenRange] = []
    var currentClass: String? = nil
    var tokenStartUTF16 = 0

    var idx = content.startIndex

    while idx < content.endIndex {
        let ch = content[idx]

        // ── HTML tag ──────────────────────────────────────────────────────
        if ch == "<" {
            let afterLt = content.index(after: idx)
            guard afterLt < content.endIndex,
                  let closeAngle = content[afterLt...].firstIndex(of: ">") else {
                appendChar(ch, to: &plainText, count: &utf16Count)
                idx = content.index(after: idx)
                continue
            }

            let tagBody = String(content[afterLt..<closeAngle])
            let tagLower = tagBody.trimmingCharacters(in: .whitespaces).lowercased()

            if tagLower.hasPrefix("font") {
                if let cls = extractFontClass(from: tagBody) {
                    tokenStartUTF16 = utf16Count
                    currentClass = cls
                }
            } else if tagLower == "/font" {
                if let cls = currentClass {
                    let length = utf16Count - tokenStartUTF16
                    if length > 0 {
                        tokenRanges.append(WebCppTokenRange(
                            range: NSRange(location: tokenStartUTF16, length: length),
                            tokenClass: cls))
                    }
                    currentClass = nil
                }
            }
            // All other tags (<div>, <a>, <br>, etc.) — just skip.
            idx = content.index(after: closeAngle)
            continue
        }

        // ── HTML entity ───────────────────────────────────────────────────
        if ch == "&" {
            let afterAmp = content.index(after: idx)
            if afterAmp < content.endIndex,
               let semi = content[afterAmp...].firstIndex(of: ";") {
                let entity = String(content[afterAmp..<semi])
                let decoded = decodeHTMLEntity(entity)
                appendString(decoded, to: &plainText, count: &utf16Count)
                idx = content.index(after: semi)
                continue
            }
        }

        // ── Literal character ─────────────────────────────────────────────
        appendChar(ch, to: &plainText, count: &utf16Count)
        idx = content.index(after: idx)
    }

    // ── 3. Trim WebCpp's leading/trailing newlines ─────────────────────────
    // WebCpp emits exactly <pre>\n\n…\n\n</pre> (engine.cpp begHtml/endHtml).
    // Strip only those fixed 2 newlines on each side — never more.
    // Using trimmingCharacters(in: .newlines) would also consume any blank
    // lines the user intentionally placed at the start/end of their snippet,
    // shifting every subsequent token range and producing wrong/absent colours.
    var leadingUTF16 = 0
    var trimmed      = plainText
    var n            = 0
    while n < 2, let first = trimmed.first, first.isNewline {
        leadingUTF16 += first.utf16.count
        trimmed.removeFirst()
        n += 1
    }
    n = 0
    while n < 2, let last = trimmed.last, last.isNewline {
        trimmed.removeLast()
        n += 1
    }
    let trimmedText  = trimmed
    let trimmedUTF16 = trimmedText.utf16.count

    let adjustedRanges = tokenRanges.compactMap { tr -> WebCppTokenRange? in
        let loc = tr.range.location - leadingUTF16
        guard loc >= 0, loc + tr.range.length <= trimmedUTF16 else { return nil }
        return WebCppTokenRange(range: NSRange(location: loc, length: tr.range.length),
                                tokenClass: tr.tokenClass)
    }

    return WebCppParseResult(plainText: trimmedText, tokenRanges: adjustedRanges)
}

/// Re-maps token ranges from the parser's reconstructed plain text onto the
/// original source text.
///
/// WebCpp's engine may insert extra characters (e.g. a trailing space on every
/// preprocessor line — see `parsePreProc` in engine.cpp) that appear in the
/// HTML output but are not present in the original source.  Without correction,
/// each such insertion shifts every subsequent range by one UTF-16 code unit,
/// producing visibly wrong colours.
///
/// This function performs a simple O(n) forward alignment: it walks both texts
/// in lockstep, advancing past any extra characters in the parsed text, and
/// builds a position map used to translate ranges.
func rebaseTokenRanges(_ result: WebCppParseResult,
                        to originalText: String) -> WebCppParseResult {

    let pUnits = Array(result.plainText.utf16)
    let oUnits = Array(originalText.utf16)

    // posMap[i] = the UTF-16 offset in `originalText` that corresponds to
    //             UTF-16 offset `i` in `result.plainText`.
    var posMap = [Int](repeating: 0, count: pUnits.count + 1)

    var pi = 0          // index into pUnits (parsed)
    var oi = 0          // index into oUnits (original)

    while pi < pUnits.count && oi < oUnits.count {
        if pUnits[pi] == oUnits[oi] {
            posMap[pi] = oi
            pi += 1
            oi += 1
        } else {
            // Extra code unit in the parsed text — skip it.
            posMap[pi] = oi
            pi += 1
        }
    }
    // Any remaining parsed positions (all past the end of original)
    while pi < pUnits.count {
        posMap[pi] = oi
        pi += 1
    }
    posMap[pUnits.count] = oi          // sentinel for end-of-range lookups

    let remapped = result.tokenRanges.compactMap { token -> WebCppTokenRange? in
        let start = token.range.location
        let end   = start + token.range.length
        guard start < posMap.count, end < posMap.count else { return nil }

        let newStart  = posMap[start]
        let newEnd    = posMap[end]
        let newLength = newEnd - newStart
        guard newLength > 0, newStart + newLength <= oUnits.count else { return nil }
        return WebCppTokenRange(
            range: NSRange(location: newStart, length: newLength),
            tokenClass: token.tokenClass)
    }

    return WebCppParseResult(plainText: originalText, tokenRanges: remapped)
}

// MARK: - Helpers

private func appendChar(_ ch: Character, to text: inout String, count: inout Int) {
    text.append(ch)
    count += ch.utf16.count
}

private func appendString(_ s: String, to text: inout String, count: inout Int) {
    text.append(contentsOf: s)
    count += s.utf16.count
}

/// Extracts the CSS class value from a `<font …>` tag body string.
/// Handles both `CLASS=keyword` (WebCpp style) and `class="keyword"`.
private func extractFontClass(from tagBody: String) -> String? {
    // Regex: optional whitespace around =, optional quotes around value
    let pattern = #"(?i)\bclass\s*=\s*[\"']?(\w+)[\"']?"#
    guard let regex = try? NSRegularExpression(pattern: pattern),
          let match = regex.firstMatch(in: tagBody,
                                       range: NSRange(tagBody.startIndex..., in: tagBody)),
          let range = Range(match.range(at: 1), in: tagBody) else {
        return nil
    }
    return String(tagBody[range]).lowercased()
}

/// Decodes a named or numeric HTML entity (without the surrounding `&` and `;`).
private func decodeHTMLEntity(_ entity: String) -> String {
    switch entity.lowercased() {
    case "lt":   return "<"
    case "gt":   return ">"
    case "amp":  return "&"
    case "quot": return "\""
    case "apos": return "'"
    case "nbsp": return "\u{00A0}"
    default:
        if (entity.hasPrefix("#x") || entity.hasPrefix("#X")),
           let code   = UInt32(entity.dropFirst(2), radix: 16),
           let scalar = Unicode.Scalar(code) {
            return String(Character(scalar))
        }
        if entity.hasPrefix("#"),
           let code   = UInt32(entity.dropFirst()),
           let scalar = Unicode.Scalar(code) {
            return String(Character(scalar))
        }
        return "&\(entity);"   // Unknown entity — pass through unchanged
    }
}
