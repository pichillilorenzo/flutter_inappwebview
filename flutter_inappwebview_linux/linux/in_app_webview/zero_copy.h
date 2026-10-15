#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_ZERO_COPY_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_ZERO_COPY_H_

#include <glib.h>

namespace flutter_inappwebview_plugin {

// This is deliberately presence-based to match DISABLE_GL. It is read while a
// platform view is created and changing it afterwards is unsupported.
inline bool IsZeroCopyDisabled() {
  return g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_ZERO_COPY") != nullptr;
}

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_ZERO_COPY_H_
