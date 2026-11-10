#include <cassert>
#include <memory>
#include <string>
#include <vector>
#include "../in_app_webview/pending_script_requests.h"

using flutter_inappwebview_plugin::PendingScriptRequests;

int main() {
  auto a = std::make_shared<PendingScriptRequests>();
  auto b = std::make_shared<PendingScriptRequests>();
  std::vector<std::string> events;
  auto normal = a->add([&](std::string s) { events.push_back(s); }, "null");
  assert(a->count() == 1);
  assert(a->complete(normal, "7"));
  assert(!a->complete(normal, "late"));
  assert(a->count() == 0 && events == std::vector<std::string>{"7"});

  auto pending = a->add([&](std::string s) { events.push_back(s); }, "null");
  auto peer = b->add([&](std::string s) { events.push_back(s); }, "success");
  a->cancelAll();
  assert(!a->complete(pending, "late"));
  assert(b->complete(peer, "peer"));
  assert((events == std::vector<std::string>{"7", "null", "peer"}));

  auto old = a->add([&](std::string) {
    a->add([&](std::string s) { events.push_back(s); }, "null");
  }, "null");
  a->cancelAll();
  assert(!a->contains(old));
  assert(a->count() == 1);
  a->cancelAll();
  assert(events.back() == "null");
  a->cancelAll();

  auto absent = a->add(nullptr, "null");
  assert(a->complete(absent, "ignored"));
  assert(a->count() == 0);
}
