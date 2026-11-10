#include <cassert>
#include <cstdint>
#include <memory>
#include <string>
#include "../in_app_webview/deferred_post_url_script.h"

using flutter_inappwebview_plugin::DeferredPostUrlScript;

struct TestView {
  std::shared_ptr<int> alive = std::make_shared<int>(0);
  uint64_t navigation = 0;
  int evaluations = 0;
  ~TestView() { alive.reset(); }
};

// Mirrors the production callback ordering: expired tokens must be checked
// before touching the view pointer. ASan would detect a dereference after free.
struct DeferredCall {
  TestView* view;
  DeferredPostUrlScript script;
  bool fire() {
    if (!script.ownerAlive()) return false;
    if (!script.matchesGeneration(view->navigation)) return false;
    ++view->evaluations;
    return true;
  }
};

int main() {
  auto* first = new TestView();
  DeferredCall valid{first, {first->alive, first->navigation, "post()"}};
  assert(valid.fire());
  assert(first->evaluations == 1);

  DeferredCall replaced{first, {first->alive, first->navigation, "obsolete()"}};
  ++first->navigation; // new loadUrl() request overtook the pending script.
  assert(!replaced.fire());
  assert(first->evaluations == 1);
  delete first;

  // Critical UAF regression: no access to the freed TestView.
  assert(!valid.fire());
  assert(!replaced.fire());

  auto* next = new TestView();
  DeferredCall nextCall{next, {next->alive, next->navigation, "new()"}};
  assert(nextCall.fire());
  assert(next->evaluations == 1);
  assert(!valid.fire()); // old view's callback must not touch its replacement.
  delete next;

  auto token = std::make_shared<int>(0);
  DeferredPostUrlScript script{token, 3, "postWithData()"};
  assert(script.ownerAlive());
  assert(script.matchesGeneration(3));
  assert(!script.matchesGeneration(4));
  token.reset();
  assert(!script.ownerAlive());
}
