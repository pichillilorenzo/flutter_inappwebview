#include "web_message_listener_channel_delegate.h"

#include <cstring>

#include "../in_app_webview/in_app_webview.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "web_message_listener.h"

namespace flutter_inappwebview_plugin {

namespace {
// Helper to compare method names
bool string_equals(const gchar* a, const char* b) {
  return strcmp(a, b) == 0;
}
}  // namespace

WebMessageListenerChannelDelegate::WebMessageListenerChannelDelegate(
    WebMessageListener* webMessageListener,
    FlBinaryMessenger* messenger,
    const std::string& channelName)
    : ChannelDelegate(messenger, channelName),
      webMessageListener_(webMessageListener) {
}

WebMessageListenerChannelDelegate::~WebMessageListenerChannelDelegate() {
  debugLog("dealloc WebMessageListenerChannelDelegate");
  webMessageListener_ = nullptr;
}

void WebMessageListenerChannelDelegate::HandleMethodCall(FlMethodCall* method_call) {
  if (webMessageListener_ == nullptr) {
    fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
    return;
  }

  const gchar* methodName = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (string_equals(methodName, "postMessage")) {
    // Handle reply from Dart to JavaScript
    // This is called when JavaScriptReplyProxy.postMessage() is invoked on the Dart side
    
    InAppWebView* webView = webMessageListener_->webView();
    if (webView == nullptr || webView->webview() == nullptr) {
      g_autoptr(FlValue) result = fl_value_new_bool(false);
      fl_method_call_respond_success(method_call, result, nullptr);
      return;
    }

    FlValue* message_value = get_fl_map_value_raw(args, "message");
    
    std::string messageData = "";
    int64_t messageType = 0;  // 0 = string, 1 = arrayBuffer
    
    if (message_value != nullptr && fl_value_get_type(message_value) == FL_VALUE_TYPE_MAP) {
      FlValue* data_value = fl_value_lookup_string(message_value, "data");
      FlValue* type_value = fl_value_lookup_string(message_value, "type");
      
      if (data_value != nullptr) {
        if (fl_value_get_type(data_value) == FL_VALUE_TYPE_STRING) {
          messageData = fl_value_get_string(data_value);
        } else if (fl_value_get_type(data_value) == FL_VALUE_TYPE_UINT8_LIST) {
          // Convert bytes to comma-separated values for JavaScript
          const uint8_t* bytes = fl_value_get_uint8_list(data_value);
          size_t length = fl_value_get_length(data_value);
          for (size_t i = 0; i < length; i++) {
            if (i > 0) messageData += ",";
            messageData += std::to_string(bytes[i]);
          }
        }
      }
      if (type_value != nullptr && fl_value_get_type(type_value) == FL_VALUE_TYPE_INT) {
        messageType = fl_value_get_int(type_value);
      }
    }

    // Build the JavaScript message expression
    std::string messageDataJs;
    if (messageType == 1) {
      // ArrayBuffer - messageData contains comma-separated byte values
      messageDataJs = "new Uint8Array([" + messageData + "]).buffer";
    } else {
      // String - escape for JavaScript
      std::string escaped;
      escaped.reserve(messageData.size() * 2);
      for (char c : messageData) {
        switch (c) {
          case '\\': escaped += "\\\\"; break;
          case '"': escaped += "\\\""; break;
          case '\n': escaped += "\\n"; break;
          case '\r': escaped += "\\r"; break;
          case '\t': escaped += "\\t"; break;
          default: escaped += c; break;
        }
      }
      messageDataJs = "\"" + escaped + "\"";
    }

    // Escape the jsObjectName for JavaScript
    std::string jsObjectNameEscaped = webMessageListener_->jsObjectName();
    size_t pos = 0;
    while ((pos = jsObjectNameEscaped.find("'", pos)) != std::string::npos) {
      jsObjectNameEscaped.replace(pos, 1, "\\'");
      pos += 2;
    }

    // Build JavaScript to dispatch message to the listener's callbacks
    // This matches iOS WebMessageListenerChannelDelegate.postMessage behavior
    std::string js = R"JS(
(function() {
    var webMessageListener = window[')JS" + jsObjectNameEscaped + R"JS('];
    if (webMessageListener != null) {
        var event = {data: )JS" + messageDataJs + R"JS(};
        if (webMessageListener.onmessage != null) {
            webMessageListener.onmessage(event);
        }
        for (var listener of webMessageListener.listeners) {
            listener(event);
        }
    }
})();
)JS";

    // Execute the JavaScript
    webView->evaluateJavascript(js, std::nullopt, nullptr);
    
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

void WebMessageListenerChannelDelegate::onPostMessage(const std::string* messageData,
                                                       int64_t messageType,
                                                       const std::string* sourceOrigin,
                                                       bool isMainFrame) const {
  if (channel_ == nullptr) {
    return;
  }

  // Build message map if there's message data
  FlValue* messageMap = nullptr;
  if (messageData != nullptr) {
    FlValue* dataValue = nullptr;
    if (messageType == 1) {
      // ArrayBuffer - convert comma-separated values to byte array
      std::vector<uint8_t> bytes;
      std::string value;
      for (char c : *messageData) {
        if (c == ',') {
          if (!value.empty()) {
            try {
              bytes.push_back(static_cast<uint8_t>(std::stoi(value)));
            } catch (...) {}
            value.clear();
          }
        } else {
          value += c;
        }
      }
      if (!value.empty()) {
        try {
          bytes.push_back(static_cast<uint8_t>(std::stoi(value)));
        } catch (...) {}
      }
      dataValue = fl_value_new_uint8_list(bytes.data(), bytes.size());
    } else {
      dataValue = make_fl_value(*messageData);
    }
    messageMap = to_fl_map({
        {"data", dataValue},
        {"type", make_fl_value(messageType)},
    });
  }

  g_autoptr(FlValue) args = to_fl_map({
      {"message", messageMap != nullptr ? messageMap : fl_value_new_null()},
      {"sourceOrigin", sourceOrigin != nullptr ? make_fl_value(*sourceOrigin) : fl_value_new_null()},
      {"isMainFrame", make_fl_value(isMainFrame)},
  });

  invokeMethod("onPostMessage", args);
}

void WebMessageListenerChannelDelegate::dispose() {
  debugLog("WebMessageListenerChannelDelegate::dispose");
  unregisterMethodCallHandler();
  webMessageListener_ = nullptr;
}

}  // namespace flutter_inappwebview_plugin
