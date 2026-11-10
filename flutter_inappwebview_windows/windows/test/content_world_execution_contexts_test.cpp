#include <cassert>
#include <string>
#include "../in_app_webview/content_world_execution_contexts.h"

using flutter_inappwebview_plugin::ContentWorldExecutionContexts;

int main() {
  ContentWorldExecutionContexts contexts;
  assert(!contexts.get("page"));
  contexts.put("page", 3);
  contexts.put("isolated", 4);
  assert(contexts.get("page").value() == 3);
  assert(contexts.get("isolated").value() == 4);

  // A destroyed isolated world must not leave a stale CDP cache entry.
  contexts.eraseId(4);
  assert(!contexts.get("isolated"));
  assert(contexts.get("page").value() == 3);
  contexts.put("isolated", 7);
  assert(contexts.get("isolated").value() == 7);
  contexts.eraseId(4);  // Late notice for the original context.
  assert(contexts.get("isolated").value() == 7);

  // Full renderer replacement invalidates every execution context.
  contexts.clear();
  assert(contexts.count() == 0);
  assert(!contexts.get("page"));
  contexts.put("page", 12);
  contexts.put("alias", 12);
  contexts.eraseId(12);
  assert(contexts.count() == 0);
}
