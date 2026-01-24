#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_LISTENER_JS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_LISTENER_JS_H_

#include <string>

#include "javascript_bridge_js.h"

namespace flutter_inappwebview_plugin {

/**
 * JavaScript source for WebMessageListener support.
 *
 * This creates the FlutterInAppWebViewWebMessageListener class that web pages
 * can use to communicate with the native side via postMessage.
 *
 * Usage in JavaScript:
 *   myListener.postMessage("Hello from web!");
 *   myListener.addEventListener("message", (event) => { ... });
 */
class WebMessageListenerJS {
 public:
  /**
   * JavaScript source code for the FlutterInAppWebViewWebMessageListener class.
   */
  static std::string WEB_MESSAGE_LISTENER_JS_SOURCE() {
    return R"JS(
function FlutterInAppWebViewWebMessageListener(jsObjectName) {
    this.jsObjectName = jsObjectName;
    this.listeners = [];
    this.onmessage = null;
}
FlutterInAppWebViewWebMessageListener.prototype.postMessage = function(data) {
    var message = {
        "data": window.ArrayBuffer != null && data instanceof ArrayBuffer ? Array.from(new Uint8Array(data)) : (data != null ? data.toString() : null),
        "type": window.ArrayBuffer != null && data instanceof ArrayBuffer ? 1 : 0
    };
    window.)JS" +
           JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + R"JS(.callHandler('onWebMessageListenerPostMessageReceived', {
        jsObjectName: this.jsObjectName,
        message: message,
        sourceOrigin: window.location.origin,
        isMainFrame: window.top === window
    });
};
FlutterInAppWebViewWebMessageListener.prototype.addEventListener = function(type, listener) {
    if (listener == null) {
        return;
    }
    this.listeners.push(listener);
};
FlutterInAppWebViewWebMessageListener.prototype.removeEventListener = function(type, listener) {
    if (listener == null) {
        return;
    }
    var index = this.listeners.indexOf(listener);
    if (index >= 0) {
        this.listeners.splice(index, 1);
    }
};
)JS";
  }

  /**
   * JavaScript to check if origin is allowed based on origin rules.
   *
   * Origin rules format:
   * - "*" matches all origins
   * - "https://example.com" matches exact origin
   * - "https: // *.example.com" matches subdomains (note: no space in actual use)
   */
  static std::string IS_ORIGIN_ALLOWED_JS_SOURCE() {
    // Note: Using string concatenation to avoid compiler warning about
    // regex patterns like /[0-9]+/g being interpreted as C comments.
    return
        "var _normalizeIPv6 = function(ip_string) {\n"
        "    var ipv4 = ip_string.match(/(.*)([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+$)/);\n"
        "    if (ipv4) {\n"
        "        ip_string = ipv4[1];\n"
        "        ipv4 = ipv4[2].match(/[0-9]+/" "g);\n"  // Split to avoid /* comment warning
        "        for (var i = 0;i < 4;i ++) {\n"
        "            var byte = parseInt(ipv4[i],10);\n"
        "            ipv4[i] = ('0' + byte.toString(16)).substr(-2);\n"
        "        }\n"
        "        ip_string += ipv4[0] + ipv4[1] + ':' + ipv4[2] + ipv4[3];\n"
        "    }\n"
        "    ip_string = ip_string.replace(/^:|:$/" "g, '');\n"  // Split to avoid /* comment warning
        "    var ipv6 = ip_string.split(':');\n"
        "    for (var i = 0; i < ipv6.length; i ++) {\n"
        "        var hex = ipv6[i];\n"
        "        if (hex != '') {\n"
        "            ipv6[i] = ('0000' + hex).substr(-4);\n"
        "        }\n"
        "        else {\n"
        "            hex = [];\n"
        "            for (var j = ipv6.length; j <= 8; j ++) {\n"
        "                hex.push('0000');\n"
        "            }\n"
        "            ipv6[i] = hex.join(':');\n"
        "        }\n"
        "    }\n"
        "    return ipv6.join(':');\n"
        "};\n"
        "\n"
        "var _isOriginAllowed = function(allowedOriginRules, scheme, host, port) {\n"
        "    for (var rule of allowedOriginRules) {\n"
        "        if (rule === '*') {\n"
        "            return true;\n"
        "        }\n"
        "        if (scheme == null || scheme === '') {\n"
        "            continue;\n"
        "        }\n"
        "        if ((scheme == null || scheme === '') && (host == null || host === '') && (port === 0 || port === '' || port == null)) {\n"
        "            continue;\n"
        "        }\n"
        "        var rulePort = rule.port == null || rule.port === 0 ? (rule.scheme == 'https' ? 443 : 80) : rule.port;\n"
        "        var currentPort = port === 0 || port === '' || port == null ? (scheme == 'https' ? 443 : 80) : port;\n"
        "        var IPv6 = null;\n"
        "        if (rule.host != null && rule.host[0] === '[') {\n"
        "            try {\n"
        "                IPv6 = _normalizeIPv6(rule.host.substring(1, rule.host.length - 1));\n"
        "            } catch(e) {}\n"
        "        }\n"
        "        var hostIPv6 = null;\n"
        "        try {\n"
        "            hostIPv6 = _normalizeIPv6(host);\n"
        "        } catch(e) {}\n"
        "\n"
        "        var schemeAllowed = scheme == rule.scheme;\n"
        "        \n"
        "        var hostAllowed = rule.host == null ||\n"
        "            rule.host === '' ||\n"
        "            host === rule.host ||\n"
        "            (rule.host[0] === '*' && host != null && host.indexOf(rule.host.split('*')[1]) >= 0) ||\n"
        "            (hostIPv6 != null && IPv6 != null && hostIPv6 === IPv6);\n"
        "\n"
        "        var portAllowed = rulePort === currentPort;\n"
        "\n"
        "        if (schemeAllowed && hostAllowed && portAllowed) {\n"
        "            return true;\n"
        "        }\n"
        "    }\n"
        "    return false;\n"
        "};\n";
  }

  /**
   * Creates the JavaScript to inject a web message listener with the given name and origin rules.
   *
   * @param jsObjectName The name of the JavaScript object to inject (e.g., "myListener")
   * @param allowedOriginRulesJs JSON array string of allowed origin rules
   */
  static std::string createWebMessageListenerInjectionJs(
      const std::string& jsObjectName,
      const std::string& allowedOriginRulesJs) {
    std::string jsObjectNameEscaped = jsObjectName;
    // Escape single quotes in jsObjectName
    size_t pos = 0;
    while ((pos = jsObjectNameEscaped.find("'", pos)) != std::string::npos) {
      jsObjectNameEscaped.replace(pos, 1, "\\'");
      pos += 2;
    }

    return "(function() {\n" + IS_ORIGIN_ALLOWED_JS_SOURCE() + "\n" +
           WEB_MESSAGE_LISTENER_JS_SOURCE() +
           "\nvar allowedOriginRules = " + allowedOriginRulesJs +
           ";\n"
           "var isPageBlank = window.location.href === 'about:blank';\n"
           "var scheme = !isPageBlank ? window.location.protocol.replace(':', '') : null;\n"
           "var host = !isPageBlank ? window.location.hostname : null;\n"
           "var port = !isPageBlank ? window.location.port : null;\n"
           "if (_isOriginAllowed(allowedOriginRules, scheme, host, port)) {\n"
           "    window['" +
           jsObjectNameEscaped +
           "'] = new FlutterInAppWebViewWebMessageListener('" +
           jsObjectNameEscaped +
           "');\n"
           "}\n"
           "})();";
  }
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_WEB_MESSAGE_LISTENER_JS_H_
