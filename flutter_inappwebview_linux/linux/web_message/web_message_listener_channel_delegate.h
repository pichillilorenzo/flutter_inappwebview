#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_LISTENER_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_LISTENER_CHANNEL_DELEGATE_H_

#include <flutter_linux/flutter_linux.h>

#include <cstdint>
#include <string>

#include "../types/channel_delegate.h"

namespace flutter_inappwebview_plugin {

class WebMessageListener;

/**
 * Channel delegate for WebMessageListener.
 *
 * Handles method calls from Dart (like postMessage for replies)
 * and invokes callbacks to Dart (like onPostMessage when JS posts a message).
 *
 * This follows the federated plugin pattern matching iOS/Android:
 * - Dedicated MethodChannel per WebMessageListener instance
 * - Channel name: com.pichillilorenzo/flutter_inappwebview_web_message_listener_{id}_{jsObjectName}
 */
class WebMessageListenerChannelDelegate : public ChannelDelegate {
 public:
  WebMessageListenerChannelDelegate(WebMessageListener* webMessageListener,
                                    FlBinaryMessenger* messenger,
                                    const std::string& channelName);
  ~WebMessageListenerChannelDelegate() override;

  /**
   * Handle method calls from Dart.
   * Currently handles:
   * - postMessage: Send a reply message from native to JavaScript
   */
  void HandleMethodCall(FlMethodCall* method_call) override;

  /**
   * Invoke onPostMessage callback on the Dart side.
   * Called when JavaScript posts a message through the WebMessageListener.
   *
   * @param messageData The message data (may be null)
   * @param messageType 0 for string, 1 for arrayBuffer
   * @param sourceOrigin The origin URL that sent the message (may be null)
   * @param isMainFrame Whether the message came from the main frame
   */
  void onPostMessage(const std::string* messageData,
                     int64_t messageType,
                     const std::string* sourceOrigin,
                     bool isMainFrame) const;

  void dispose();

 private:
  WebMessageListener* webMessageListener_;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_LISTENER_CHANNEL_DELEGATE_H_
