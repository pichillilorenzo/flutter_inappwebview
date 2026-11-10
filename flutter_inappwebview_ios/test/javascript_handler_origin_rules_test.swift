import Foundation
import Dispatch

@main
struct JavaScriptHandlerOriginRulesTests {
    static func main() {
        let a = JavaScriptHandlerOriginRules()
        let b = JavaScriptHandlerOriginRules()

        assert(a.allows(origin: nil, patterns: nil))
        assert(a.allows(origin: "https://anything.invalid", patterns: nil))
        assert(!a.allows(origin: "https://anything.invalid", patterns: []))
        assert(!a.allows(origin: nil, patterns: [".*"]))

        let pattern = #"https://plugins\.otzaria\.org"#
        assert(a.allows(origin: "https://plugins.otzaria.org", patterns: [pattern]))
        assert(!a.allows(origin: "https://unrelated.example", patterns: [pattern]))
        // Native String.range(of:options:.regularExpression) matches substrings.
        assert(a.allows(origin: "https://plugins.otzaria.org:443", patterns: [pattern]))
        assert(!a.allows(origin: "https://unrelated.example", patterns: [pattern]))

        // Switching policies must invalidate cached expressions immediately.
        let changed = #"https://docs\.otzaria\.org"#
        assert(!a.allows(origin: "https://plugins.otzaria.org", patterns: [changed]))
        assert(a.allows(origin: "https://docs.otzaria.org", patterns: [changed]))
        assert(!a.allows(origin: "https://docs.otzaria.org", patterns: ["["]))
        assert(a.allows(origin: "https://docs.otzaria.org", patterns: ["[", changed]))
        assert(b.allows(origin: "https://plugins.otzaria.org", patterns: [pattern]))
        assert(a.allows(origin: "https://everywhere.invalid", patterns: nil))

        // Canonically equivalent strings can describe different regex ranges.
        // Policy updates must follow the exact pattern, in both directions.
        let broad = "^https://[A-\u{212A}]+\\.example$" // Kelvin sign, not ASCII K.
        let narrow = #"^https://[A-K]+\.example$"#
        let unicodeOrigin = "https://evil.example"
        assert(broad == narrow)
        assert(!broad.utf8.elementsEqual(narrow.utf8))
        assert(unicodeOrigin.range(of: broad, options: .regularExpression) != nil)
        assert(unicodeOrigin.range(of: narrow, options: .regularExpression) == nil)
        for (index, updatedPattern) in [broad, narrow, broad, narrow].enumerated() {
            let expected = unicodeOrigin.range(of: updatedPattern, options: .regularExpression) != nil
            let actual = a.allows(origin: unicodeOrigin, patterns: [updatedPattern])
            let freshRegex = try! NSRegularExpression(pattern: updatedPattern)
            let freshResult = freshRegex.firstMatch(in: unicodeOrigin, options: [],
                range: NSRange(unicodeOrigin.startIndex..<unicodeOrigin.endIndex, in: unicodeOrigin)) != nil
            let legacyAfter = unicodeOrigin.range(of: updatedPattern, options: .regularExpression) != nil
            assert(actual == expected, "Unicode policy \(index): utf8=\(Array(updatedPattern.utf8)), cached=\(actual), legacyBefore=\(expected), fresh=\(freshResult), legacyAfter=\(legacyAfter), freshPatternUTF8=\(Array(freshRegex.pattern.utf8))")
        }
        var mutablePatterns = [broad]
        assert(a.allows(origin: unicodeOrigin, patterns: mutablePatterns))
        mutablePatterns[0] = narrow // Mutating shared array storage must invalidate too.
        assert(!a.allows(origin: unicodeOrigin, patterns: mutablePatterns))

        // Diagnostic microbenchmark: no performance assertions on shared CI runners.
        let cycles = 10000
        let origin = "https://plugins.otzaria.org"
        let patterns = [pattern]
        let start1 = DispatchTime.now().uptimeNanoseconds
        for _ in 0..<cycles {
            assert(origin.range(of: pattern, options: .regularExpression) != nil)
        }
        let slow = DispatchTime.now().uptimeNanoseconds - start1
        let start2 = DispatchTime.now().uptimeNanoseconds
        for _ in 0..<cycles {
            assert(a.allows(origin: origin, patterns: patterns))
        }
        let cached = DispatchTime.now().uptimeNanoseconds - start2
        print("PASS. origin regex evaluations: legacy=\(slow / 1000)us, cached=\(cached / 1000)us")

        // A fixed large policy must not require scanning its unchanged patterns
        // on every message, especially when the first expression matches.
        let manyPatterns = patterns + (0..<127).map { "^https://unused\($0)\\.example$" }
        assert(a.allows(origin: origin, patterns: manyPatterns)) // Compile before timing.
        let start3 = DispatchTime.now().uptimeNanoseconds
        for _ in 0..<cycles {
            assert(manyPatterns.contains { origin.range(of: $0, options: .regularExpression) != nil })
        }
        let manyLegacy = DispatchTime.now().uptimeNanoseconds - start3
        let start4 = DispatchTime.now().uptimeNanoseconds
        for _ in 0..<cycles {
            assert(a.allows(origin: origin, patterns: manyPatterns))
        }
        let manyCached = DispatchTime.now().uptimeNanoseconds - start4
        print("PASS. 128-rule first match: legacy=\(manyLegacy / 1000)us, cached=\(manyCached / 1000)us")
    }
}
