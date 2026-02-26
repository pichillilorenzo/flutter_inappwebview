#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_CHANNEL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_CHANNEL_H_

#include <memory>
#include <string>

#include <flutter/encodable_value.h>

#include "../types/channel_delegate.h"

namespace flutter_inappwebview_plugin {

class InAppWebView;

/**
 * Native C++ representation of a WebMessageChannel.
 *
 * Each WebMessageChannel has its own MethodChannel for communication
 * with the Dart side. This allows the Dart side to call port-specific
 * methods like setWebMessageCallback, postMessage, and close.
 */
class WebMessageChannel : public ChannelDelegate {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME_PREFIX =
      "com.pichillilorenzo/flutter_inappwebview_web_message_channel_";

  WebMessageChannel(flutter::BinaryMessenger* messenger,
                    const std::string& channelId,
                    InAppWebView* webView);
  ~WebMessageChannel() override;

  const std::string& id() const { return id_; }

  /**
   * Dispose of this WebMessageChannel, releasing resources and unregistering
   * the method call handler.
   */
  void dispose();

  /**
   * Send a message to the Dart side on a specific port.
   *
   * @param portIndex The port index (0 or 1)
   * @param message The message data (may be null)
   * @param messageType 0 for string, 1 for arrayBuffer
   */
  void onMessage(int portIndex, const std::string* message, int64_t messageType);

  // ChannelDelegate override
  void HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) override;

 private:
  std::string id_;
  InAppWebView* webView_;  // Weak reference - InAppWebView owns WebMessageChannels
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_CHANNEL_H_
