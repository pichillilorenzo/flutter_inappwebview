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

        // Diagnostic microbenchmark: no performance assertions on shared CI runners.
        let cycles = 10000
        let origin = "https://plugins.otzaria.org"
        let start1 = DispatchTime.now().uptimeNanoseconds
        for _ in 0..<cycles {
            assert(origin.range(of: pattern, options: .regularExpression) != nil)
        }
        let slow = DispatchTime.now().uptimeNanoseconds - start1
        let start2 = DispatchTime.now().uptimeNanoseconds
        for _ in 0..<cycles {
            assert(a.allows(origin: origin, patterns: [pattern]))
        }
        let cached = DispatchTime.now().uptimeNanoseconds - start2
        print("PASS. origin regex evaluations: legacy=\(slow / 1000)us, cached=\(cached / 1000)us")
    }
}
