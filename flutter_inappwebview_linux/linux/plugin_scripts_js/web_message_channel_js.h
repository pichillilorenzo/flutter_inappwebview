#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_CHANNEL_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_CHANNEL_JS_H_

#include <string>

#include "javascript_bridge_js.h"

namespace flutter_inappwebview_plugin {

/**
 * JavaScript support for WebMessageChannel.
 *
 * Provides the variable name for storing MessageChannels in JavaScript
 * and JavaScript snippets for creating and managing WebMessageChannels.
 * Matches iOS WebMessageChannelJS.swift for consistency.
 */
class WebMessageChannelJS {
 public:
  /**
   * Returns the JavaScript variable name for storing WebMessageChannels.
   * Example: "window.flutter_inappwebview._webMessageChannels"
   */
  static std::string WEB_MESSAGE_CHANNELS_VARIABLE_NAME() {
    return "window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() +
           "._webMessageChannels";
  }

  /**
   * JavaScript to create a new MessageChannel and store it.
   *
   * @param channelId The unique identifier for the channel
   * @return JavaScript code that creates the channel and returns its info
   */
  static std::string createWebMessageChannelJs(const std::string& channelId) {
    return
        "(function() {\n"
        "    var channel = new MessageChannel();\n"
        "    " + WEB_MESSAGE_CHANNELS_VARIABLE_NAME() + "['" + channelId + "'] = channel;\n"
        "    return {'id': '" + channelId + "'};\n"
        "})();";
  }

  /**
   * JavaScript to set the onmessage callback for a port.
   *
   * @param channelId The channel identifier
   * @param portIndex The port index (0 or 1)
   * @return JavaScript code that sets up the callback
   */
  static std::string setWebMessageCallbackJs(const std::string& channelId, int portIndex) {
    std::string portName = portIndex == 0 ? "port1" : "port2";
    return
        "(function() {\n"
        "    var webMessageChannel = " + WEB_MESSAGE_CHANNELS_VARIABLE_NAME() + "['" + channelId + "'];\n"
        "    if (webMessageChannel != null) {\n"
        "        webMessageChannel." + portName + ".onmessage = function(event) {\n"
        "            " + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + ".callHandler('onWebMessagePortMessageReceived', {\n"
        "                'webMessageChannelId': '" + channelId + "',\n"
        "                'index': " + std::to_string(portIndex) + ",\n"
        "                'message': {\n"
        "                    'data': window.ArrayBuffer != null && event.data instanceof ArrayBuffer\n"
        "                        ? Array.from(new Uint8Array(event.data))\n"
        "                        : (event.data != null ? event.data.toString() : null),\n"
        "                    'type': window.ArrayBuffer != null && event.data instanceof ArrayBuffer ? 1 : 0\n"
        "                }\n"
        "            });\n"
        "        };\n"
        "        webMessageChannel." + portName + ".start();\n"
        "    }\n"
        "})();";
  }

  /**
   * JavaScript to post a message on a port.
   *
   * @param channelId The channel identifier
   * @param portIndex The port index (0 or 1)
   * @param messageDataJs The message data as JavaScript expression
   * @return JavaScript code that posts the message
   */
  static std::string postMessageJs(const std::string& channelId, int portIndex,
                                   const std::string& messageDataJs) {
    std::string portName = portIndex == 0 ? "port1" : "port2";
    return
        "(function() {\n"
        "    var webMessageChannel = " + WEB_MESSAGE_CHANNELS_VARIABLE_NAME() + "['" + channelId + "'];\n"
        "    if (webMessageChannel != null) {\n"
        "        webMessageChannel." + portName + ".postMessage(" + messageDataJs + ");\n"
        "    }\n"
        "})();";
  }

  /**
   * JavaScript to close a port.
   *
   * @param channelId The channel identifier
   * @param portIndex The port index (0 or 1)
   * @return JavaScript code that closes the port
   */
  static std::string closePortJs(const std::string& channelId, int portIndex) {
    std::string portName = portIndex == 0 ? "port1" : "port2";
    return
        "(function() {\n"
        "    var webMessageChannel = " + WEB_MESSAGE_CHANNELS_VARIABLE_NAME() + "['" + channelId + "'];\n"
        "    if (webMessageChannel != null) {\n"
        "        webMessageChannel." + portName + ".close();\n"
        "    }\n"
        "})();";
  }

  /**
   * JavaScript to dispose of a channel (clean up both ports and remove from storage).
   *
   * @param channelId The channel identifier
   * @return JavaScript code that disposes the channel
   */
  static std::string disposeChannelJs(const std::string& channelId) {
    return
        "(function() {\n"
        "    var webMessageChannel = " + WEB_MESSAGE_CHANNELS_VARIABLE_NAME() + "['" + channelId + "'];\n"
        "    if (webMessageChannel != null) {\n"
        "        try { webMessageChannel.port1.close(); } catch(e) {}\n"
        "        try { webMessageChannel.port2.close(); } catch(e) {}\n"
        "        delete " + WEB_MESSAGE_CHANNELS_VARIABLE_NAME() + "['" + channelId + "'];\n"
        "    }\n"
        "})();";
  }

  /**
   * JavaScript to post a WebMessage to the window, optionally with ports.
   *
   * @param messageDataJs The message data as JavaScript expression
   * @param targetOrigin The target origin string
   * @param portsJs Optional JavaScript expression for ports array (empty string if no ports)
   * @return JavaScript code that posts the message
   */
  static std::string postWebMessageJs(const std::string& messageDataJs,
                                      const std::string& targetOrigin,
                                      const std::string& portsJs) {
    std::string portsArg = portsJs.empty() ? "undefined" : portsJs;
    return
        "(function() {\n"
        "    window.postMessage(" + messageDataJs + ", '" + targetOrigin + "', " + portsArg + ");\n"
        "})();";
  }
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_CHANNEL_JS_H_
