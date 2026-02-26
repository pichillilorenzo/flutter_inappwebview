#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_LISTENER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_LISTENER_H_

#include <flutter_linux/flutter_linux.h>

#include <memory>
#include <set>
#include <string>

namespace flutter_inappwebview_plugin {

class InAppWebView;
class WebMessageListenerChannelDelegate;

/**
 * Native C++ representation of a WebMessageListener.
 *
 * Each WebMessageListener has its own MethodChannel for communication
 * with the Dart side. This follows the federated plugin pattern where
 * callbacks are routed through a dedicated channel (not the main WebView channel).
 *
 * Channel name pattern:
 *   com.pichillilorenzo/flutter_inappwebview_web_message_listener_{id}_{jsObjectName}
 *
 * This matches the iOS/Android architecture where:
 * - WebMessageListener is a native class with its own channelDelegate
 * - onPostMessage callbacks go directly to Dart via the dedicated channel
 * - postMessage (reply) is handled via the dedicated channel
 */
class WebMessageListener {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME_PREFIX =
      "com.pichillilorenzo/flutter_inappwebview_web_message_listener_";

  /**
   * Create a WebMessageListener from a Flutter map value.
   *
   * Expected map structure:
   * - id: String - unique identifier for this listener
   * - jsObjectName: String - name of the JS object injected into pages
   * - allowedOriginRules: List<String> - origin rules for allowed sources
   */
  static std::unique_ptr<WebMessageListener> fromFlValue(
      FlBinaryMessenger* messenger,
      FlValue* map,
      InAppWebView* webView);

  WebMessageListener(FlBinaryMessenger* messenger,
                     const std::string& id,
                     const std::string& jsObjectName,
                     const std::set<std::string>& allowedOriginRules,
                     InAppWebView* webView);
  ~WebMessageListener();

  const std::string& id() const { return id_; }
  const std::string& jsObjectName() const { return jsObjectName_; }
  const std::set<std::string>& allowedOriginRules() const { return allowedOriginRules_; }
  WebMessageListenerChannelDelegate* channelDelegate() const { return channelDelegate_.get(); }

  /**
   * Check if the given origin is allowed by the origin rules.
   *
   * @param scheme URL scheme (e.g., "https")
   * @param host Hostname (e.g., "example.com")
   * @param port Port number (0 for default)
   * @return true if the origin is allowed
   */
  bool isOriginAllowed(const std::string& scheme,
                       const std::string& host,
                       int port) const;

  /**
   * Called when JavaScript posts a message through this listener.
   * Routes the callback to Dart via the dedicated channel.
   *
   * @param messageData The message data (string or array buffer as JSON)
   * @param messageType 0 for string, 1 for arrayBuffer
   * @param sourceOrigin The origin URL that sent the message
   * @param isMainFrame Whether the message came from the main frame
   */
  void onPostMessage(const std::string* messageData,
                     int64_t messageType,
                     const std::string& sourceOrigin,
                     bool isMainFrame);

  /**
   * Dispose of this WebMessageListener, releasing resources.
   */
  void dispose();

  // Allow channel delegate to access webView_
  friend class WebMessageListenerChannelDelegate;

  // Public accessor for webView (needed by channel delegate)
  InAppWebView* webView() const { return webView_; }

 private:
  std::string id_;
  std::string jsObjectName_;
  std::set<std::string> allowedOriginRules_;
  InAppWebView* webView_;  // Weak reference - InAppWebView owns WebMessageListeners
  std::unique_ptr<WebMessageListenerChannelDelegate> channelDelegate_;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_LISTENER_H_
