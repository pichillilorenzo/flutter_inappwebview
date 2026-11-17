#include <cassert>
#include <chrono>
#include <iostream>
#include <optional>
#include <regex>
#include <string>
#include <vector>
#include "../in_app_webview/javascript_origin_rules.h"

using flutter_inappwebview_plugin::JavaScriptOriginRules;
int main() {
  JavaScriptOriginRules matcher;
  assert(matcher.allows("https://unknown.invalid")); // Null list preserves default allow.
  matcher.configure(std::vector<std::string>{});
  assert(!matcher.allows("https://unknown.invalid")); // Empty list denies.

  const std::vector<std::string> patterns = {
    R"(https://([a-z0-9-]+\.)?otzaria\.org)",
    R"(https://trusted\.example)"
  };
  matcher.configure(patterns);
  assert(matcher.ruleCount() == 2);
  assert(matcher.allows("https://plugins.otzaria.org"));
  assert(matcher.allows("https://otzaria.org"));
  assert(matcher.allows("https://trusted.example"));
  assert(!matcher.allows("http://plugins.otzaria.org"));
  assert(!matcher.allows("https://attacker.otzaria.org.evil"));

  JavaScriptOriginRules peer;
  peer.configure(std::vector<std::string>{R"(https://other\.example)"});
  matcher.configure(std::vector<std::string>{"["}); // Malformed pattern safely denies.
  assert(matcher.ruleCount() == 0);
  assert(!matcher.allows("https://plugins.otzaria.org"));
  assert(peer.allows("https://other.example"));
  matcher.configure(std::vector<std::string>{"[", R"(https://good\.example)"});
  assert(matcher.ruleCount() == 1);
  assert(matcher.allows("https://good.example"));
  matcher.configure(std::nullopt);
  assert(matcher.allows("https://any.example"));

  // Throughput comparison is diagnostic only; no timing assertions in CI.
  matcher.configure(patterns);
  constexpr int iterations = 10000;
  const std::string origin = "https://plugins.otzaria.org";
  int matched = 0;
  auto start = std::chrono::steady_clock::now();
  for (int i = 0; i < iterations; ++i)
    for (const auto& p : patterns)
      if (std::regex_match(origin, std::regex(p))) { ++matched; break; }
  auto uncached = std::chrono::steady_clock::now() - start;
  start = std::chrono::steady_clock::now();
  for (int i = 0; i < iterations; ++i)
    matched += matcher.allows(origin) ? 1 : 0;
  auto cached = std::chrono::steady_clock::now() - start;
  assert(matched == 2 * iterations);
  std::cout << "Regex compile-every-call: "
            << std::chrono::duration_cast<std::chrono::microseconds>(uncached).count()
            << "us, cached: "
            << std::chrono::duration_cast<std::chrono::microseconds>(cached).count()
            << "us (" << iterations << " calls each)\n";
}
