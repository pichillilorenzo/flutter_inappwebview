#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_LINUX_JAVASCRIPT_ORIGIN_POLICY_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_LINUX_JAVASCRIPT_ORIGIN_POLICY_H_

#include <algorithm>
#include <optional>
#include <regex>
#include <string>
#include <utility>
#include <vector>

namespace flutter_inappwebview_plugin {

// The public Dart contract accepts regex patterns, not URL substrings.
// Cache compiled expressions on settings updates to avoid recompiling on RPCs.
class JavaScriptOriginPolicy {
 public:
  void configure(const std::optional<std::vector<std::string>>& patterns) {
    if (!patterns) {
      compiled_.reset(); // A null policy allows any origin.
      return;
    }
    std::vector<std::regex> next;
    next.reserve(patterns->size());
    for (const auto& rule : *patterns) {
      try {
        next.emplace_back(rule, std::regex::ECMAScript);
      } catch (const std::regex_error&) {
        // An invalid pattern may not bypass the origin gate or crash WPE.
      }
    }
    compiled_ = std::move(next); // Empty explicitly denies all.
  }

  bool allows(const std::string& origin) const {
    if (!compiled_) return true;
    return std::any_of(compiled_->begin(), compiled_->end(),
                       [&origin](const std::regex& rule) {
                         return std::regex_match(origin, rule);
                       });
  }

  size_t validRuleCount() const { return compiled_ ? compiled_->size() : 0; }

 private:
  std::optional<std::vector<std::regex>> compiled_;
};
} // namespace flutter_inappwebview_plugin

#endif
