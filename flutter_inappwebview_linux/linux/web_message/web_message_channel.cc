#include "web_message_channel.h"

#include <cstring>

#include "../in_app_webview/in_app_webview.h"
#include "../utils/flutter.h"
#include "../utils/log.h"

namespace flutter_inappwebview_plugin {

namespace {
// Helper to compare method names
bool string_equals(const gchar* a, const char* b) {
  return strcmp(a, b) == 0;
}
}  // namespace

WebMessageChannel::WebMessageChannel(FlBinaryMessenger* messenger,
                                     const std::string& channelId,
                                     InAppWebView* webView)
    : ChannelDelegate(messenger, std::string(METHOD_CHANNEL_NAME_PREFIX) + channelId),
      id_(channelId),
      webView_(webView) {
}

WebMessageChannel::~WebMessageChannel() {
  debugLog("dealloc WebMessageChannel");
  webView_ = nullptr;
}

void WebMessageChannel::dispose() {
  unregisterMethodCallHandler();
  webView_ = nullptr;
}

void WebMessageChannel::HandleMethodCall(FlMethodCall* method_call) {
  if (webView_ == nullptr) {
    fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
    return;
  }

  const gchar* methodName = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (string_equals(methodName, "setWebMessageCallback")) {
    // Set the onmessage callback for a port
    int64_t portIndex = get_fl_map_value<int64_t>(args, "index", 0);
    
    webView_->setWebMessageCallback(id_, static_cast<int>(portIndex));
    
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "postMessage")) {
    // Post a message on a port
    int64_t portIndex = get_fl_map_value<int64_t>(args, "index", 0);
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
    
    webView_->postWebMessageOnPort(id_, static_cast<int>(portIndex), messageData, messageType);
    
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "close")) {
    // Close a port
    int64_t portIndex = get_fl_map_value<int64_t>(args, "index", 0);
    
    webView_->closeWebMessagePort(id_, static_cast<int>(portIndex));
    
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

void WebMessageChannel::onMessage(int portIndex, const std::string* message,
                                   int64_t messageType) {
  if (channel_ == nullptr) {
    return;
  }

  FlValue* messageMap = nullptr;
  if (message != nullptr) {
    FlValue* dataValue = nullptr;
    if (messageType == 1) {
      // ArrayBuffer - convert comma-separated values to byte array
      std::vector<uint8_t> bytes;
      std::string value;
      for (char c : *message) {
        if (c == ',') {
          if (!value.empty()) {
            bytes.push_back(static_cast<uint8_t>(std::stoi(value)));
            value.clear();
          }
        } else {
          value += c;
        }
      }
      if (!value.empty()) {
        bytes.push_back(static_cast<uint8_t>(std::stoi(value)));
      }
      dataValue = fl_value_new_uint8_list(bytes.data(), bytes.size());
    } else {
      dataValue = make_fl_value(*message);
    }
    messageMap = to_fl_map({
        {"data", dataValue},
        {"type", make_fl_value(messageType)},
    });
  }

  g_autoptr(FlValue) args = to_fl_map({
      {"index", make_fl_value(portIndex)},
      {"message", messageMap != nullptr ? messageMap : fl_value_new_null()},
  });

  invokeMethod("onMessage", args);
}

}  // namespace flutter_inappwebview_plugin
