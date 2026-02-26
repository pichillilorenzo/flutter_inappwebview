#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_CHANNEL_DELEGATE_H_

#include <flutter_linux/flutter_linux.h>

#include <string>

#include "../types/channel_delegate.h"

namespace flutter_inappwebview_plugin {

class InAppBrowser;

/// Channel delegate for InAppBrowser instance communication
///
/// Handles method calls from Dart and sends events back to the Dart side.
/// Each InAppBrowser instance has its own channel delegate with a unique channel name.
class InAppBrowserChannelDelegate : public ChannelDelegate {
 public:
  /// Create a channel delegate for a specific browser instance
  /// @param browser The browser instance this delegate belongs to
  /// @param messenger The Flutter binary messenger
  /// @param channelName The unique channel name for this browser
  InAppBrowserChannelDelegate(InAppBrowser* browser, FlBinaryMessenger* messenger,
                              const std::string& channelName);
  ~InAppBrowserChannelDelegate() override;

  /// Handle method calls from Flutter
  void HandleMethodCall(FlMethodCall* method_call) override;

  /// Notify Dart that the browser window has been created
  void onBrowserCreated() const;

  /// Notify Dart that a menu item was clicked
  /// @param menuItemId The ID of the clicked menu item
  void onMenuItemClicked(int32_t menuItemId) const;

  /// Notify Dart that the browser window is about to close
  void onExit() const;

 private:
  InAppBrowser* browser_ = nullptr;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_BROWSER_CHANNEL_DELEGATE_H_
