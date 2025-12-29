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

// === Callback implementations (copied from GTK delegate so WPE builds have definitions) ===

WebViewChannelDelegate::ShouldOverrideUrlLoadingCallback::ShouldOverrideUrlLoadingCallback() {
  decodeResult = [](FlValue* value) -> std::optional<NavigationActionPolicy> {
    if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      return NavigationActionPolicy::cancel;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_INT) {
      auto navigationPolicy = static_cast<int>(fl_value_get_int(value));
      return static_cast<NavigationActionPolicy>(navigationPolicy);
    }
    return NavigationActionPolicy::cancel;
  };
}

WebViewChannelDelegate::CallJsHandlerCallback::CallJsHandlerCallback() {
  decodeResult = [](FlValue* value) -> std::optional<FlValue*> { return value; };
}

WebViewChannelDelegate::CreateWindowCallback::CreateWindowCallback() {
  decodeResult = [](FlValue* value) -> std::optional<bool> {
    if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      return false;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_BOOL) {
      return fl_value_get_bool(value);
    }
    return false;
  };
}

WebViewChannelDelegate::ShouldInterceptRequestCallback::ShouldInterceptRequestCallback() {
  decodeResult = [](FlValue* value) -> std::optional<std::shared_ptr<WebResourceResponse>> {
    if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      return std::nullopt;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_MAP) {
      return std::make_shared<WebResourceResponse>(value);
    }
    return std::nullopt;
  };
}

WebViewChannelDelegate::JsAlertCallback::JsAlertCallback() {
  decodeResult = [](FlValue* value) -> std::optional<JsAlertResponse> {
    if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      return std::nullopt;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_MAP) {
      return JsAlertResponse(value);
    }
    return std::nullopt;
  };
}

WebViewChannelDelegate::JsConfirmCallback::JsConfirmCallback() {
  decodeResult = [](FlValue* value) -> std::optional<JsConfirmResponse> {
    if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      return std::nullopt;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_MAP) {
      return JsConfirmResponse(value);
    }
    return std::nullopt;
  };
}

WebViewChannelDelegate::JsPromptCallback::JsPromptCallback() {
  decodeResult = [](FlValue* value) -> std::optional<JsPromptResponse> {
    if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      return std::nullopt;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_MAP) {
      return JsPromptResponse(value);
    }
    return std::nullopt;
  };
}

WebViewChannelDelegate::JsBeforeUnloadCallback::JsBeforeUnloadCallback() {
  decodeResult = [](FlValue* value) -> std::optional<JsBeforeUnloadResponse> {
    if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      return std::nullopt;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_MAP) {
      return JsBeforeUnloadResponse(value);
    }
    return std::nullopt;
  };
}

WebViewChannelDelegate::PermissionRequestCallback::PermissionRequestCallback() {
  decodeResult = [](FlValue* value) -> std::optional<PermissionResponse> {
    if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      return std::nullopt;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_MAP) {
      return PermissionResponse(value);
    }
    return std::nullopt;
  };
}

WebViewChannelDelegate::HttpAuthRequestCallback::HttpAuthRequestCallback() {
  decodeResult = [](FlValue* value) -> std::optional<HttpAuthResponse> {
    if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      return std::nullopt;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_MAP) {
      return HttpAuthResponse(value);
    }
    return std::nullopt;
  };
}

WebViewChannelDelegate::DownloadStartCallback::DownloadStartCallback() {
  decodeResult = [](FlValue* value) -> std::optional<DownloadStartResponse> {
    if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      return std::nullopt;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_MAP) {
      return DownloadStartResponse(value);
    }
    return std::nullopt;
  };
}

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

void WebViewChannelDelegateWpe::onCallJsHandler(
    const std::string& handlerName,
    std::unique_ptr<JavaScriptHandlerFunctionData> data,
    std::unique_ptr<WebViewChannelDelegate::CallJsHandlerCallback> callback) {
  if (!channel_) {
    if (callback) callback->defaultBehaviour(std::nullopt);
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "handlerName", fl_value_new_string(handlerName.c_str()));
  fl_value_set_string_take(args, "data", data->toFlValue());

  auto* cb = callback.release();

  invokeMethodWithResult(
      "onCallJsHandler", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<WebViewChannelDelegate::CallJsHandlerCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response =
            fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue = fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse), fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      cb);
}

void WebViewChannelDelegateWpe::shouldOverrideUrlLoading(
    std::shared_ptr<NavigationAction> navigationAction,
    std::unique_ptr<WebViewChannelDelegate::ShouldOverrideUrlLoadingCallback> callback) {
  if (!channel_) {
    if (callback) callback->defaultBehaviour(std::nullopt);
    return;
  }

  if (DebugLogEnabled()) {
    std::string url = navigationAction->request ? navigationAction->request->url.value_or("") : "";
    g_message("WebViewChannelDelegateWpe: shouldOverrideUrlLoading url=%s mainFrame=%s",
              url.c_str(), navigationAction->isForMainFrame ? "true" : "false");
  }

  FlValue* args = navigationAction->toFlValue();

  auto* cb = callback.release();

  invokeMethodWithResult(
      "shouldOverrideUrlLoading", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<WebViewChannelDelegate::ShouldOverrideUrlLoadingCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response = fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue = fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse), fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      cb);
}

void WebViewChannelDelegateWpe::onJsAlert(
    std::unique_ptr<JsAlertRequest> request,
    std::unique_ptr<WebViewChannelDelegate::JsAlertCallback> callback) {
  if (!channel_) {
    if (callback) callback->defaultBehaviour(std::nullopt);
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "request", request->toFlValue());

  auto* cb = callback.release();

  invokeMethodWithResult(
      "onJsAlert", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<WebViewChannelDelegate::JsAlertCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response = fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue = fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse), fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      cb);
}

void WebViewChannelDelegateWpe::onJsConfirm(
    std::unique_ptr<JsConfirmRequest> request,
    std::unique_ptr<WebViewChannelDelegate::JsConfirmCallback> callback) {
  if (!channel_) {
    if (callback) callback->defaultBehaviour(std::nullopt);
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "request", request->toFlValue());

  auto* cb = callback.release();

  invokeMethodWithResult(
      "onJsConfirm", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<WebViewChannelDelegate::JsConfirmCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response = fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue = fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse), fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      cb);
}

void WebViewChannelDelegateWpe::onJsPrompt(
    std::unique_ptr<JsPromptRequest> request,
    std::unique_ptr<WebViewChannelDelegate::JsPromptCallback> callback) {
  if (!channel_) {
    if (callback) callback->defaultBehaviour(std::nullopt);
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "request", request->toFlValue());

  auto* cb = callback.release();

  invokeMethodWithResult(
      "onJsPrompt", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<WebViewChannelDelegate::JsPromptCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response = fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue = fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse), fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      cb);
}

void WebViewChannelDelegateWpe::onJsBeforeUnload(
    const std::optional<std::string>& url,
    const std::optional<std::string>& message,
    std::unique_ptr<WebViewChannelDelegate::JsBeforeUnloadCallback> callback) {
  if (!channel_) {
    if (callback) callback->defaultBehaviour(std::nullopt);
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  if (url.has_value()) {
    fl_value_set_string_take(args, "url", fl_value_new_string(url->c_str()));
  } else {
    fl_value_set_string_take(args, "url", fl_value_new_null());
  }
  if (message.has_value()) {
    fl_value_set_string_take(args, "message", fl_value_new_string(message->c_str()));
  } else {
    fl_value_set_string_take(args, "message", fl_value_new_null());
  }

  auto* cb = callback.release();

  invokeMethodWithResult(
      "onJsBeforeUnload", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<WebViewChannelDelegate::JsBeforeUnloadCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response = fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue = fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse), fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      cb);
}

void WebViewChannelDelegateWpe::onPermissionRequest(
    std::unique_ptr<PermissionRequest> request,
    std::unique_ptr<WebViewChannelDelegate::PermissionRequestCallback> callback) {
  if (!channel_) {
    if (callback) callback->defaultBehaviour(std::nullopt);
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "request", request->toFlValue());

  auto* cb = callback.release();

  invokeMethodWithResult(
      "onPermissionRequest", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<WebViewChannelDelegate::PermissionRequestCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response = fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue = fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse), fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      cb);
}

void WebViewChannelDelegateWpe::onReceivedHttpAuthRequest(
    std::unique_ptr<HttpAuthenticationChallenge> challenge,
    std::unique_ptr<WebViewChannelDelegate::HttpAuthRequestCallback> callback) {
  if (!channel_) {
    if (callback) callback->defaultBehaviour(std::nullopt);
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "challenge", challenge->toFlValue());

  auto* cb = callback.release();

  invokeMethodWithResult(
      "onReceivedHttpAuthRequest", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<WebViewChannelDelegate::HttpAuthRequestCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response = fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue = fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse), fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      cb);
}

void WebViewChannelDelegateWpe::onCreateWindow(
    std::unique_ptr<CreateWindowAction> createWindowAction,
    std::unique_ptr<WebViewChannelDelegate::CreateWindowCallback> callback) {
  if (!channel_) {
    if (callback) callback->defaultBehaviour(std::nullopt);
    return;
  }

  FlValue* args = createWindowAction->toFlValue();
  auto* cb = callback.release();

  invokeMethodWithResult(
      "onCreateWindow", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<WebViewChannelDelegate::CreateWindowCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response = fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue = fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse), fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      cb);
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

void WebViewChannelDelegateWpe::onFaviconChanged(const std::optional<std::string>& faviconUrl) {
  g_autoptr(FlValue) args = fl_value_new_map();
  if (faviconUrl.has_value()) {
    fl_value_set_string_take(args, "url",
                             fl_value_new_string(faviconUrl.value().c_str()));
  } else {
    fl_value_set_string_take(args, "url", fl_value_new_null());
  }

  invokeMethod("onReceivedIcon", args);
}

void WebViewChannelDelegateWpe::onConsoleMessage(const std::string& message,
                                                  int64_t messageLevel) {
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "message", fl_value_new_string(message.c_str()));
  fl_value_set_string_take(args, "messageLevel", fl_value_new_int(messageLevel));

  invokeMethod("onConsoleMessage", args);
}

void WebViewChannelDelegateWpe::onUpdateVisitedHistory(
    const std::optional<std::string>& url,
    const std::optional<bool>& isReload) {
  g_autoptr(FlValue) args = fl_value_new_map();
  if (url.has_value()) {
    fl_value_set_string_take(args, "url", fl_value_new_string(url->c_str()));
  } else {
    fl_value_set_string_take(args, "url", fl_value_new_null());
  }
  if (isReload.has_value()) {
    fl_value_set_string_take(args, "isReload", fl_value_new_bool(isReload.value()));
  } else {
    fl_value_set_string_take(args, "isReload", fl_value_new_null());
  }

  invokeMethod("onUpdateVisitedHistory", args);
}

void WebViewChannelDelegateWpe::onPageCommitVisible(const std::optional<std::string>& url) {
  g_autoptr(FlValue) args = fl_value_new_map();
  if (url.has_value()) {
    fl_value_set_string_take(args, "url", fl_value_new_string(url->c_str()));
  } else {
    fl_value_set_string_take(args, "url", fl_value_new_null());
  }

  invokeMethod("onPageCommitVisible", args);
}

void WebViewChannelDelegateWpe::onZoomScaleChanged(double newScale, double oldScale) {
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "newScale", fl_value_new_float(newScale));
  fl_value_set_string_take(args, "oldScale", fl_value_new_float(oldScale));

  invokeMethod("onZoomScaleChanged", args);
}

void WebViewChannelDelegateWpe::onScrollChanged(int64_t x, int64_t y) {
  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "x", fl_value_new_int(x));
  fl_value_set_string_take(args, "y", fl_value_new_int(y));

  invokeMethod("onScrollChanged", args);
}

void WebViewChannelDelegateWpe::onWebViewCreated() {
  invokeMethod("onWebViewCreated", nullptr);
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



}  // namespace flutter_inappwebview_plugin

#endif  // USE_WPE_WEBKIT
