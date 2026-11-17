#include <cassert>
#include <memory>
#include <vector>
#include "../in_app_webview/pending_webkit_javascript_calls.h"

using flutter_inappwebview_plugin::PendingWebKitJavaScriptCalls;

int main() {
  auto closing = std::make_shared<PendingWebKitJavaScriptCalls>();
  auto surviving = std::make_shared<PendingWebKitJavaScriptCalls>();
  std::vector<int> completed;

  auto success = closing->add([&] { completed.push_back(-1); });
  assert(closing->finish(success));
  assert(!closing->finish(success));
  closing->cancelAll();
  assert(completed.empty());

  auto pending = closing->add([&] { completed.push_back(1); });
  auto peer = surviving->add([&] { completed.push_back(2); });
  closing->cancelAll();
  assert(closing->count() == 0 && surviving->count() == 1);
  assert(!closing->finish(pending));
  assert(surviving->finish(peer));
  assert((completed == std::vector<int>{1}));

  closing->add([&] {
    closing->add([&] { completed.push_back(3); });
  });
  closing->cancelAll();
  assert(closing->count() == 1);
  closing->cancelAll();
  assert((completed == std::vector<int>{1, 3}));
  closing->cancelAll();
}
