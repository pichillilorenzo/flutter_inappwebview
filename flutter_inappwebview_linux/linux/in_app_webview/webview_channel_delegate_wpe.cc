// WPE WebKit WebView Channel Delegate implementation
//
// This handles the method channel communication between Dart and the WPE
// WebKit-based InAppWebView implementation. The API is identical to the
// WebKitGTK version since the method channel protocol is the same.

#include "webview_channel_delegate_wpe.h"

#ifdef USE_WPE_WEBKIT

#include <cstring>

#include "../utils/flutter.h"
#include "../utils/log.h"
#include "in_app_webview_wpe.h"

namespace flutter_inappwebview_plugin {

namespace {
bool DebugLogEnabled() {
  static bool enabled = g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG") != nullptr;
  return enabled;
}

bool string_equals(const gchar* a, const char* b) {
  return strcmp(a, b) == 0;
}
}  // namespace

WebViewChannelDelegateWpe::WebViewChannelDelegateWpe(
    InAppWebViewWpe* webView,
    FlBinaryMessenger* messenger,
    const std::string& channelName)
    : ChannelDelegate(messenger, channelName.c_str()),
      webview_(webView) {
  if (DebugLogEnabled()) {
    g_message("WebViewChannelDelegateWpe: created channel %s", channelName.c_str());
  }
}

WebViewChannelDelegateWpe::~WebViewChannelDelegateWpe() {
  if (DebugLogEnabled()) {
    g_message("WebViewChannelDelegateWpe: destructor");
  }
}

// === Event dispatchers ===

void WebViewChannelDelegateWpe::onLoadStart(const std::string& url) {
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "url", fl_value_new_string(url.c_str()));
  invokeMethod("onLoadStart", args);
}

void WebViewChannelDelegateWpe::onLoadStop(const std::string& url) {
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "url", fl_value_new_string(url.c_str()));
  invokeMethod("onLoadStop", args);
}

void WebViewChannelDelegateWpe::onLoadError(const std::string& url, 
                                             int errorCode,
                                             const std::string& description) {
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "url", fl_value_new_string(url.c_str()));
  fl_value_set_string_take(args, "code", fl_value_new_int(errorCode));
  fl_value_set_string_take(args, "message", fl_value_new_string(description.c_str()));
  invokeMethod("onLoadError", args);
}

void WebViewChannelDelegateWpe::onProgressChanged(int progress) {
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "progress", fl_value_new_int(progress));
  invokeMethod("onProgressChanged", args);
}

void WebViewChannelDelegateWpe::onTitleChanged(const std::string& title) {
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "title", 
                           title.empty() ? fl_value_new_null() 
                                         : fl_value_new_string(title.c_str()));
  invokeMethod("onTitleChanged", args);
}

void WebViewChannelDelegateWpe::onCallJsHandler(const std::string& handlerName,
                                                 const std::string& args) {
  g_autoptr(FlValue) flArgs = fl_value_new_map();
  fl_value_set_string_take(flArgs, "handlerName", 
                           fl_value_new_string(handlerName.c_str()));
  fl_value_set_string_take(flArgs, "args", fl_value_new_string(args.c_str()));
  invokeMethod("onCallJsHandler", flArgs);
}

void WebViewChannelDelegateWpe::shouldOverrideUrlLoading(
    int64_t decisionId, 
    const std::string& url) {
  if (DebugLogEnabled()) {
    g_message("WebViewChannelDelegateWpe: shouldOverrideUrlLoading url=%s mainFrame=true", 
              url.c_str());
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  
  // Create navigation action
  g_autoptr(FlValue) navigationAction = fl_value_new_map();
  
  // Create request
  g_autoptr(FlValue) request = fl_value_new_map();
  fl_value_set_string_take(request, "url", fl_value_new_string(url.c_str()));
  fl_value_set_string_take(request, "method", fl_value_new_string("GET"));
  fl_value_set_string(navigationAction, "request", request);
  
  fl_value_set_string_take(navigationAction, "isForMainFrame", fl_value_new_bool(true));
  fl_value_set_string_take(navigationAction, "hasGesture", fl_value_new_bool(false));
  fl_value_set_string_take(navigationAction, "isRedirect", fl_value_new_bool(false));
  
  fl_value_set_string(args, "navigationAction", navigationAction);
  fl_value_set_string_take(args, "decisionId", fl_value_new_int(decisionId));

  invokeMethod("shouldOverrideUrlLoading", args);
}

void WebViewChannelDelegateWpe::onCloseWindow() {
  invokeMethod("onCloseWindow", nullptr);
}

void WebViewChannelDelegateWpe::onEnterFullscreen() {
  invokeMethod("onEnterFullscreen", nullptr);
}

void WebViewChannelDelegateWpe::onExitFullscreen() {
  invokeMethod("onExitFullscreen", nullptr);
}

// === Method call handler ===

void WebViewChannelDelegateWpe::HandleMethodCall(FlMethodCall* method_call) {
  const gchar* method = fl_method_call_get_name(method_call);

  if (DebugLogEnabled()) {
    g_message("WebViewChannelDelegateWpe: method=%s", method);
  }

  if (string_equals(method, "loadUrl")) {
    HandleLoadUrl(method_call);
  } else if (string_equals(method, "loadData")) {
    HandleLoadData(method_call);
  } else if (string_equals(method, "loadFile")) {
    HandleLoadFile(method_call);
  } else if (string_equals(method, "reload")) {
    HandleReload(method_call);
  } else if (string_equals(method, "goBack")) {
    HandleGoBack(method_call);
  } else if (string_equals(method, "goForward")) {
    HandleGoForward(method_call);
  } else if (string_equals(method, "canGoBack")) {
    HandleCanGoBack(method_call);
  } else if (string_equals(method, "canGoForward")) {
    HandleCanGoForward(method_call);
  } else if (string_equals(method, "stopLoading")) {
    HandleStopLoading(method_call);
  } else if (string_equals(method, "isLoading")) {
    HandleIsLoading(method_call);
  } else if (string_equals(method, "getUrl")) {
    HandleGetUrl(method_call);
  } else if (string_equals(method, "getTitle")) {
    HandleGetTitle(method_call);
  } else if (string_equals(method, "getProgress")) {
    HandleGetProgress(method_call);
  } else if (string_equals(method, "evaluateJavascript")) {
    HandleEvaluateJavascript(method_call);
  } else if (string_equals(method, "shouldOverrideUrlLoadingResponse")) {
    HandleShouldOverrideUrlLoadingDecision(method_call);
  } else {
    fl_method_call_respond_not_implemented(method_call, nullptr);
  }
}

void WebViewChannelDelegateWpe::HandleLoadUrl(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  FlValue* urlRequest = fl_value_lookup_string(args, "urlRequest");
  
  if (urlRequest != nullptr && webview_ != nullptr) {
    auto request = std::make_shared<URLRequest>(urlRequest);
    webview_->loadUrl(request);
  }
  
  fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
}

void WebViewChannelDelegateWpe::HandleLoadData(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  
  auto data = get_fl_map_value<std::string>(args, "data", "");
  auto mimeType = get_fl_map_value<std::string>(args, "mimeType", "text/html");
  auto encoding = get_fl_map_value<std::string>(args, "encoding", "UTF-8");
  auto baseUrl = get_fl_map_value<std::string>(args, "baseUrl", "about:blank");
  
  if (webview_ != nullptr && !data.empty()) {
    webview_->loadData(data, mimeType, encoding, baseUrl);
  }
  
  fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
}

void WebViewChannelDelegateWpe::HandleLoadFile(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  
  auto assetFilePath = get_fl_map_value<std::string>(args, "assetFilePath", "");
  
  if (webview_ != nullptr && !assetFilePath.empty()) {
    webview_->loadFile(assetFilePath);
  }
  
  fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
}

void WebViewChannelDelegateWpe::HandleReload(FlMethodCall* method_call) {
  if (webview_ != nullptr) {
    webview_->reload();
  }
  fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
}

void WebViewChannelDelegateWpe::HandleGoBack(FlMethodCall* method_call) {
  if (webview_ != nullptr) {
    webview_->goBack();
  }
  fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
}

void WebViewChannelDelegateWpe::HandleGoForward(FlMethodCall* method_call) {
  if (webview_ != nullptr) {
    webview_->goForward();
  }
  fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
}

void WebViewChannelDelegateWpe::HandleCanGoBack(FlMethodCall* method_call) {
  bool result = webview_ != nullptr && webview_->canGoBack();
  fl_method_call_respond_success(method_call, fl_value_new_bool(result), nullptr);
}

void WebViewChannelDelegateWpe::HandleCanGoForward(FlMethodCall* method_call) {
  bool result = webview_ != nullptr && webview_->canGoForward();
  fl_method_call_respond_success(method_call, fl_value_new_bool(result), nullptr);
}

void WebViewChannelDelegateWpe::HandleStopLoading(FlMethodCall* method_call) {
  if (webview_ != nullptr) {
    webview_->stopLoading();
  }
  fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
}

void WebViewChannelDelegateWpe::HandleIsLoading(FlMethodCall* method_call) {
  bool result = webview_ != nullptr && webview_->isLoading();
  fl_method_call_respond_success(method_call, fl_value_new_bool(result), nullptr);
}

void WebViewChannelDelegateWpe::HandleGetUrl(FlMethodCall* method_call) {
  if (webview_ != nullptr) {
    auto url = webview_->getUrl();
    if (url.has_value()) {
      fl_method_call_respond_success(method_call, 
                                      fl_value_new_string(url.value().c_str()), 
                                      nullptr);
      return;
    }
  }
  fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
}

void WebViewChannelDelegateWpe::HandleGetTitle(FlMethodCall* method_call) {
  if (webview_ != nullptr) {
    auto title = webview_->getTitle();
    if (title.has_value()) {
      fl_method_call_respond_success(method_call, 
                                      fl_value_new_string(title.value().c_str()), 
                                      nullptr);
      return;
    }
  }
  fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
}

void WebViewChannelDelegateWpe::HandleGetProgress(FlMethodCall* method_call) {
  int64_t progress = 0;
  if (webview_ != nullptr) {
    progress = webview_->getProgress();
  }
  fl_method_call_respond_success(method_call, fl_value_new_int(progress), nullptr);
}

void WebViewChannelDelegateWpe::HandleEvaluateJavascript(FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  auto source = get_fl_map_value<std::string>(args, "source", "");
  
  if (webview_ != nullptr && !source.empty()) {
    // Ref the method call to keep it alive during async operation
    g_object_ref(method_call);
    
    webview_->evaluateJavascript(source, 
        [method_call](const std::optional<std::string>& result) {
          if (result.has_value()) {
            fl_method_call_respond_success(method_call, 
                                           fl_value_new_string(result.value().c_str()), 
                                           nullptr);
          } else {
            fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
          }
          g_object_unref(method_call);
        });
    return;
  }
  
  fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
}

void WebViewChannelDelegateWpe::HandleShouldOverrideUrlLoadingDecision(
    FlMethodCall* method_call) {
  FlValue* args = fl_method_call_get_args(method_call);
  
  auto decisionId = get_fl_map_value<int64_t>(args, "decisionId", -1);
  auto action = get_fl_map_value<int64_t>(args, "action", 0);
  bool allow = (action == 1);  // 1 = ALLOW
  
  if (DebugLogEnabled()) {
    g_message("WebViewChannelDelegateWpe: shouldOverrideUrlLoadingResponse decisionId=%ld action=%ld",
              static_cast<long>(decisionId), static_cast<long>(action));
  }
  
  if (webview_ != nullptr && decisionId >= 0) {
    webview_->OnShouldOverrideUrlLoadingDecision(decisionId, allow);
  }
  
  fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
}

}  // namespace flutter_inappwebview_plugin

#endif  // USE_WPE_WEBKIT
