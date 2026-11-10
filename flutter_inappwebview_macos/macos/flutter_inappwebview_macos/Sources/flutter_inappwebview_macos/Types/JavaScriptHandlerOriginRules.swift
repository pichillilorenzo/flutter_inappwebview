import Foundation

/// One matcher per WebView. Compile only when the origin allowlist changes.
/// Preserve Foundation's substring-regex semantics used by the original
/// String.range(of:options:.regularExpression) bridge implementation.
final class JavaScriptHandlerOriginRules {
    private var cachedPatterns: [String]?
    private var compiled: [NSRegularExpression]?
    private var configured = false

    func allows(origin: String?, patterns: [String]?) -> Bool {
        if !configured || cachedPatterns != patterns {
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
