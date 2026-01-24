#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_HEADLESS_WEBVIEW_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_HEADLESS_WEBVIEW_CHANNEL_DELEGATE_H_

#include <flutter_linux/flutter_linux.h>

#include <memory>
#include <string>

#include "../types/channel_delegate.h"

namespace flutter_inappwebview_plugin {

class HeadlessInAppWebView;

/**
 * Channel delegate for HeadlessInAppWebView.
 * Handles method calls specific to headless webview operations (dispose, setSize, getSize).
 * This mirrors the iOS HeadlessWebViewChannelDelegate pattern.
 */
class HeadlessWebViewChannelDelegate : public ChannelDelegate {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME_PREFIX =
      "com.pichillilorenzo/flutter_headless_inappwebview_";

  HeadlessWebViewChannelDelegate(HeadlessInAppWebView* headlessWebView,
                                  FlBinaryMessenger* messenger,
                                  const std::string& id);
  ~HeadlessWebViewChannelDelegate() override;

  void HandleMethodCall(FlMethodCall* method_call) override;

  // === Events to send to Dart ===

  /**
   * Notify Dart that the headless webview has been created.
   */
  void onWebViewCreated() const;

 private:
  HeadlessInAppWebView* headlessWebView_ = nullptr;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_HEADLESS_WEBVIEW_CHANNEL_DELEGATE_H_
