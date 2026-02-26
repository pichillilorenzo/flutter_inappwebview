#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_RENDER_PROCESS_GONE_DETAIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_RENDER_PROCESS_GONE_DETAIL_H_

#include <flutter_linux/flutter_linux.h>
#include <wpe/webkit.h>

#include <optional>

namespace flutter_inappwebview_plugin {

/**
 * RenderProcessGoneDetail - Provides details about why the web process terminated.
 *
 * Maps to Dart's RenderProcessGoneDetail class in platform_interface.
 * Used by the onRenderProcessGone event.
 */
class RenderProcessGoneDetail {
 public:
  /**
   * Construct from WPE WebKit termination reason.
   */
  explicit RenderProcessGoneDetail(WebKitWebProcessTerminationReason reason);

  /**
   * Whether the render process crashed (as opposed to being killed by the system).
   */
  bool didCrash() const { return did_crash_; }

  /**
   * Convert to FlValue for sending to Dart.
   */
  FlValue* toFlValue() const;

 private:
  bool did_crash_ = false;
  // Note: WPE WebKit doesn't provide renderer priority information like Android does,
  // so rendererPriorityAtExit is always null for Linux.
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_RENDER_PROCESS_GONE_DETAIL_H_
