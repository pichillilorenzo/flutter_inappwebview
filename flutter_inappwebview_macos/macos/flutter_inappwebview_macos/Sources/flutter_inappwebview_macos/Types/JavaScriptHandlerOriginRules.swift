import Foundation

/// One matcher per WebView. Compile only when the origin allowlist changes.
/// Preserve Foundation's substring-regex semantics used by the original
/// String.range(of:options:.regularExpression) bridge implementation.
final class JavaScriptHandlerOriginRules {
    private var cachedPatterns: [String]?
    private var compiled: [NSRegularExpression]?
    private var configured = false

    private func hasSamePatterns(_ patterns: [String]?) -> Bool {
        switch (cachedPatterns, patterns) {
        case (nil, nil):
            return true
        case let (cached?, current?):
            guard cached.count == current.count else { return false }
            return cached.withUnsafeBufferPointer { cachedBuffer in
                current.withUnsafeBufferPointer { currentBuffer in
                    // Unchanged settings retain the same COW storage. Both
                    // pointers stay valid only within these nested closures.
                    if cachedBuffer.baseAddress == currentBuffer.baseAddress { return true }
                    // Swift String equality folds canonically equivalent Unicode,
                    // but [A-\u{212A}] and [A-K] have different regex meanings.
                    return zip(cachedBuffer, currentBuffer).allSatisfy {
                        $0.0.utf8.elementsEqual($0.1.utf8)
                    }
                }
            }
        default:
            return false
        }
    }

    func allows(origin: String?, patterns: [String]?) -> Bool {
        if !configured || !hasSamePatterns(patterns) {
            cachedPatterns = patterns
            configured = true
            compiled = patterns?.compactMap { try? NSRegularExpression(pattern: $0) }
        }
        guard let expressions = compiled else { return true } // nil = unrestricted
        guard let origin = origin else { return false } // explicit patterns need an origin
        let range = NSRange(origin.startIndex..<origin.endIndex, in: origin)
        return expressions.contains {
            $0.firstMatch(in: origin, options: [], range: range) != nil
        }
    }
}
