#include "render_process_gone_detail.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

RenderProcessGoneDetail::RenderProcessGoneDetail(WebKitWebProcessTerminationReason reason) {
  // Map WPE WebKit termination reasons to didCrash:
  // - WEBKIT_WEB_PROCESS_CRASHED: The web process crashed -> didCrash = true
  // - WEBKIT_WEB_PROCESS_EXCEEDED_MEMORY_LIMIT: Killed by system due to memory -> didCrash = false
  // - WEBKIT_WEB_PROCESS_TERMINATED_BY_API: Terminated via API call -> didCrash = false
  switch (reason) {
    case WEBKIT_WEB_PROCESS_CRASHED:
      did_crash_ = true;
      break;
    case WEBKIT_WEB_PROCESS_EXCEEDED_MEMORY_LIMIT:
    case WEBKIT_WEB_PROCESS_TERMINATED_BY_API:
    default:
      did_crash_ = false;
      break;
  }
}

FlValue* RenderProcessGoneDetail::toFlValue() const {
  return to_fl_map({
      {"didCrash", make_fl_value(did_crash_)},
      // rendererPriorityAtExit - WPE WebKit doesn't provide this, so it's always null
      {"rendererPriorityAtExit", make_fl_value(nullptr)},
  });
}

}  // namespace flutter_inappwebview_plugin
