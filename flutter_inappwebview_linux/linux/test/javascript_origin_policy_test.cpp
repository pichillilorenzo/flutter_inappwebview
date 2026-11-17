#include <cassert>
#include <optional>
#include <string>
#include <vector>
#include "../in_app_webview/javascript_origin_policy.h"

using flutter_inappwebview_plugin::JavaScriptOriginPolicy;

int main() {
  JavaScriptOriginPolicy owner;
  assert(owner.allows("https://arbitrary.test"));  // null means unrestricted.
  owner.configure(std::vector<std::string>{});
  assert(!owner.allows("https://arbitrary.test")); // empty means deny all.

  owner.configure(std::vector<std::string>{R"(https://trusted\.example)"});
  assert(owner.allows("https://trusted.example"));
  assert(!owner.allows("https://trusted.example.evil"));
  assert(!owner.allows("https://evil.trusted.example"));
  assert(!owner.allows("http://trusted.example"));
  assert(!owner.allows("https://untrusted.example"));

  owner.configure(std::vector<std::string>{R"(https://([a-z-]+\.)?trusted\.example)"});
  assert(owner.allows("https://docs.trusted.example"));
  assert(owner.allows("https://trusted.example"));

  // A literal substring is not a valid full-origin allowlist rule.
  owner.configure(std::vector<std::string>{"trusted.example"});
  assert(!owner.allows("https://trusted.example"));

  owner.configure(std::vector<std::string>{"["}); // invalid regexp fails closed.
  assert(!owner.allows("https://trusted.example"));
  assert(owner.validRuleCount() == 0);
  owner.configure(std::vector<std::string>{"[", R"(https://allowed\.example)"});
  assert(owner.validRuleCount() == 1);
  assert(owner.allows("https://allowed.example"));
  assert(!owner.allows("https://trusted.example"));

  JavaScriptOriginPolicy surviving;
  surviving.configure(std::vector<std::string>{R"(https://surviving\.example)"});
  owner.configure(std::nullopt);
  assert(owner.allows("https://anywhere.invalid"));
  assert(surviving.allows("https://surviving.example"));
  assert(!surviving.allows("https://anywhere.invalid"));
}
