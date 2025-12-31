#include "webview_channel_delegate.h"

#include <cstring>

#include "../types/url_request.h"
#include "../types/user_script.h"
#include "../types/web_resource_request.h"
#include "../types/web_resource_response.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "in_app_webview.h"
#include "in_app_webview_settings.h"

namespace flutter_inappwebview_plugin {

namespace {
bool DebugLogEnabled() {
  static bool enabled = g_getenv("FLUTTER_INAPPWEBVIEW_LINUX_DEBUG") != nullptr;
  return enabled;
}

// Helper to compare method names
bool string_equals(const gchar* a, const char* b) {
  return strcmp(a, b) == 0;
}
}  // namespace

// === Callback implementations ===

WebViewChannelDelegate::ShouldOverrideUrlLoadingCallback::
    ShouldOverrideUrlLoadingCallback() {
  decodeResult = [](FlValue* value) -> std::optional<NavigationActionPolicy> {
    if (value == nullptr ||
        fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
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
  decodeResult = [](FlValue* value) -> std::optional<FlValue*> {
    return value;
  };
}

WebViewChannelDelegate::CreateWindowCallback::CreateWindowCallback() {
  decodeResult = [](FlValue* value) -> std::optional<bool> {
    if (value == nullptr ||
        fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      return false;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_BOOL) {
      return fl_value_get_bool(value);
    }
    return false;
  };
}

WebViewChannelDelegate::ShouldInterceptRequestCallback::
    ShouldInterceptRequestCallback() {
  decodeResult = [](FlValue* value) -> std::optional<std::shared_ptr<WebResourceResponse>> {
    if (value == nullptr ||
        fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
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
    if (value == nullptr ||
        fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
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
    if (value == nullptr ||
        fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
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
    if (value == nullptr ||
        fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
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
    if (value == nullptr ||
        fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
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
    if (value == nullptr ||
        fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
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
    if (value == nullptr ||
        fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
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
    if (value == nullptr ||
        fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      return std::nullopt;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_MAP) {
      return DownloadStartResponse(value);
    }
    return std::nullopt;
  };
}

// === Constructors ===

WebViewChannelDelegate::WebViewChannelDelegate(InAppWebView* webView,
                                               FlBinaryMessenger* messenger)
    : ChannelDelegate(messenger,
                      std::string(InAppWebView::METHOD_CHANNEL_NAME_PREFIX) +
                          std::to_string(webView->id())),
      webView(webView) {}

WebViewChannelDelegate::WebViewChannelDelegate(InAppWebView* webView,
                                               FlBinaryMessenger* messenger,
                                               const std::string& name)
    : ChannelDelegate(messenger, name), webView(webView) {}

WebViewChannelDelegate::~WebViewChannelDelegate() {
  webView = nullptr;
}

void WebViewChannelDelegate::HandleMethodCall(FlMethodCall* method_call) {
  if (!webView) {
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  const gchar* methodName = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  if (DebugLogEnabled()) {
    g_message("WebViewChannelDelegate: method=%s", methodName);
  }

  if (string_equals(methodName, "getUrl")) {
    auto url = webView->getUrl();
    if (url.has_value()) {
      g_autoptr(FlValue) result = fl_value_new_string(url->c_str());
      fl_method_call_respond_success(method_call, result, nullptr);
    } else {
      fl_method_call_respond_success(method_call, nullptr, nullptr);
    }
    return;
  }

  if (string_equals(methodName, "getTitle")) {
    auto title = webView->getTitle();
    if (title.has_value()) {
      g_autoptr(FlValue) result = fl_value_new_string(title->c_str());
      fl_method_call_respond_success(method_call, result, nullptr);
    } else {
      fl_method_call_respond_success(method_call, nullptr, nullptr);
    }
    return;
  }

  if (string_equals(methodName, "loadUrl")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* url_request = fl_value_lookup_string(args, "urlRequest");
      if (url_request != nullptr &&
          fl_value_get_type(url_request) == FL_VALUE_TYPE_MAP) {
        auto request = std::make_shared<URLRequest>(url_request);
        webView->loadUrl(request);
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "loadData")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* data_value = fl_value_lookup_string(args, "data");
      if (data_value != nullptr &&
          fl_value_get_type(data_value) == FL_VALUE_TYPE_STRING) {
        std::string mime_type = "text/html";
        std::string encoding = "UTF-8";
        std::string base_url = "about:blank";

        FlValue* mime_value = fl_value_lookup_string(args, "mimeType");
        if (mime_value != nullptr &&
            fl_value_get_type(mime_value) == FL_VALUE_TYPE_STRING) {
          mime_type = fl_value_get_string(mime_value);
        }

        FlValue* encoding_value = fl_value_lookup_string(args, "encoding");
        if (encoding_value != nullptr &&
            fl_value_get_type(encoding_value) == FL_VALUE_TYPE_STRING) {
          encoding = fl_value_get_string(encoding_value);
        }

        FlValue* base_url_value = fl_value_lookup_string(args, "baseUrl");
        if (base_url_value != nullptr &&
            fl_value_get_type(base_url_value) == FL_VALUE_TYPE_STRING) {
          base_url = fl_value_get_string(base_url_value);
        }

        webView->loadData(fl_value_get_string(data_value), mime_type, encoding,
                           base_url);
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "reload")) {
    webView->reload();
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "goBack")) {
    webView->goBack();
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "goForward")) {
    webView->goForward();
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "canGoBack")) {
    g_autoptr(FlValue) result = fl_value_new_bool(webView->canGoBack());
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "canGoForward")) {
    g_autoptr(FlValue) result = fl_value_new_bool(webView->canGoForward());
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "stopLoading")) {
    webView->stopLoading();
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "getSettings")) {
    g_autoptr(FlValue) result = webView->getSettings();
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "setSettings")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* settings_value = fl_value_lookup_string(args, "settings");
      if (settings_value != nullptr &&
          fl_value_get_type(settings_value) == FL_VALUE_TYPE_MAP) {
        auto newSettings = std::make_shared<InAppWebViewSettings>(settings_value);
        webView->setSettings(newSettings, settings_value);
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "setSize")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_LIST &&
        fl_value_get_length(args) >= 2) {
      FlValue* width_value = fl_value_get_list_value(args, 0);
      FlValue* height_value = fl_value_get_list_value(args, 1);
      if (fl_value_get_type(width_value) == FL_VALUE_TYPE_FLOAT &&
          fl_value_get_type(height_value) == FL_VALUE_TYPE_FLOAT) {
        int width = static_cast<int>(fl_value_get_float(width_value));
        int height = static_cast<int>(fl_value_get_float(height_value));
        webView->setSize(width, height);
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (string_equals(methodName, "loadFile")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* asset_file_path = fl_value_lookup_string(args, "assetFilePath");
      if (asset_file_path != nullptr &&
          fl_value_get_type(asset_file_path) == FL_VALUE_TYPE_STRING) {
        webView->loadFile(fl_value_get_string(asset_file_path));
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "isLoading")) {
    g_autoptr(FlValue) result = fl_value_new_bool(webView->isLoading());
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "evaluateJavascript")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* source_value = fl_value_lookup_string(args, "source");
      if (source_value != nullptr &&
          fl_value_get_type(source_value) == FL_VALUE_TYPE_STRING) {
        std::string source = fl_value_get_string(source_value);

        // Capture method_call for async callback
        g_object_ref(method_call);

        webView->evaluateJavascript(
            source,
            [method_call](const std::optional<std::string>& result) {
              if (result.has_value()) {
                g_autoptr(FlValue) val = fl_value_new_string(result->c_str());
                fl_method_call_respond_success(method_call, val, nullptr);
              } else {
                fl_method_call_respond_success(method_call, nullptr, nullptr);
              }
              g_object_unref(method_call);
            });
        return;
      }
    }
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (string_equals(methodName, "injectJavascriptFileFromUrl")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* url_file = fl_value_lookup_string(args, "urlFile");
      if (url_file != nullptr &&
          fl_value_get_type(url_file) == FL_VALUE_TYPE_STRING) {
        webView->injectJavascriptFileFromUrl(fl_value_get_string(url_file));
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "injectCSSCode")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* source = fl_value_lookup_string(args, "source");
      if (source != nullptr &&
          fl_value_get_type(source) == FL_VALUE_TYPE_STRING) {
        webView->injectCSSCode(fl_value_get_string(source));
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "injectCSSFileFromUrl")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* url_file = fl_value_lookup_string(args, "urlFile");
      if (url_file != nullptr &&
          fl_value_get_type(url_file) == FL_VALUE_TYPE_STRING) {
        webView->injectCSSFileFromUrl(fl_value_get_string(url_file));
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "getProgress")) {
    g_autoptr(FlValue) result = fl_value_new_int(webView->getProgress());
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "getHtml")) {
    // Capture method_call for async callback
    g_object_ref(method_call);

    webView->getHtml(
        [method_call](const std::optional<std::string>& result) {
          if (result.has_value()) {
            g_autoptr(FlValue) val = fl_value_new_string(result->c_str());
            fl_method_call_respond_success(method_call, val, nullptr);
          } else {
            fl_method_call_respond_success(method_call, nullptr, nullptr);
          }
          g_object_unref(method_call);
        });
    return;
  }

  if (string_equals(methodName, "getZoomScale")) {
    g_autoptr(FlValue) result = fl_value_new_float(webView->getZoomScale());
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "setZoomScale")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* zoom_value = fl_value_lookup_string(args, "zoomFactor");
      if (zoom_value != nullptr &&
          fl_value_get_type(zoom_value) == FL_VALUE_TYPE_FLOAT) {
        webView->setZoomScale(fl_value_get_float(zoom_value));
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "scrollTo")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* x_value = fl_value_lookup_string(args, "x");
      FlValue* y_value = fl_value_lookup_string(args, "y");
      FlValue* animated_value = fl_value_lookup_string(args, "animated");

      int64_t x = 0, y = 0;
      bool animated = false;

      if (x_value && fl_value_get_type(x_value) == FL_VALUE_TYPE_INT) {
        x = fl_value_get_int(x_value);
      }
      if (y_value && fl_value_get_type(y_value) == FL_VALUE_TYPE_INT) {
        y = fl_value_get_int(y_value);
      }
      if (animated_value && fl_value_get_type(animated_value) == FL_VALUE_TYPE_BOOL) {
        animated = fl_value_get_bool(animated_value);
      }
      webView->scrollTo(x, y, animated);
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "scrollBy")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* x_value = fl_value_lookup_string(args, "x");
      FlValue* y_value = fl_value_lookup_string(args, "y");
      FlValue* animated_value = fl_value_lookup_string(args, "animated");

      int64_t x = 0, y = 0;
      bool animated = false;

      if (x_value && fl_value_get_type(x_value) == FL_VALUE_TYPE_INT) {
        x = fl_value_get_int(x_value);
      }
      if (y_value && fl_value_get_type(y_value) == FL_VALUE_TYPE_INT) {
        y = fl_value_get_int(y_value);
      }
      if (animated_value && fl_value_get_type(animated_value) == FL_VALUE_TYPE_BOOL) {
        animated = fl_value_get_bool(animated_value);
      }
      webView->scrollBy(x, y, animated);
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "getScrollX")) {
    g_autoptr(FlValue) result = fl_value_new_int(webView->getScrollX());
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "getScrollY")) {
    g_autoptr(FlValue) result = fl_value_new_int(webView->getScrollY());
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  // === User Script Methods ===
  if (string_equals(methodName, "addUserScript")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* user_script_value = fl_value_lookup_string(args, "userScript");
      if (user_script_value != nullptr) {
        auto userScript = std::make_shared<UserScript>(user_script_value);
        webView->addUserScript(userScript);
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "removeUserScript")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* index_value = fl_value_lookup_string(args, "index");
      FlValue* injection_time_value = fl_value_lookup_string(args, "injectionTime");
      
      if (index_value != nullptr && injection_time_value != nullptr) {
        int64_t index = fl_value_get_int(index_value);
        int64_t injectionTimeInt = fl_value_get_int(injection_time_value);
        auto injectionTime = static_cast<UserScriptInjectionTime>(injectionTimeInt);
        webView->removeUserScriptAt(static_cast<size_t>(index), injectionTime);
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "removeUserScriptsByGroupName")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_MAP) {
      FlValue* group_name_value = fl_value_lookup_string(args, "groupName");
      if (group_name_value != nullptr &&
          fl_value_get_type(group_name_value) == FL_VALUE_TYPE_STRING) {
        webView->removeUserScriptsByGroupName(fl_value_get_string(group_name_value));
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "removeAllUserScripts")) {
    webView->removeAllUserScripts();
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "isInFullscreen")) {
    bool fullscreen = webView->isInFullscreen();
    g_autoptr(FlValue) result = fl_value_new_bool(fullscreen);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "requestEnterFullscreen")) {
    webView->requestEnterFullscreen();
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (string_equals(methodName, "requestExitFullscreen")) {
    webView->requestExitFullscreen();
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (string_equals(methodName, "setVisible")) {
    bool visible = true;
    if (fl_value_get_type(args) == FL_VALUE_TYPE_BOOL) {
      visible = fl_value_get_bool(args);
    } else if (fl_value_get_type(args) == FL_VALUE_TYPE_INT) {
      visible = fl_value_get_int(args) != 0;
    }
    webView->setVisible(visible);
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (string_equals(methodName, "setTargetRefreshRate")) {
    uint32_t rate = 0;
    if (fl_value_get_type(args) == FL_VALUE_TYPE_INT) {
      rate = static_cast<uint32_t>(fl_value_get_int(args));
    }
    webView->setTargetRefreshRate(rate);
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (string_equals(methodName, "getTargetRefreshRate")) {
    uint32_t rate = webView->getTargetRefreshRate();
    g_autoptr(FlValue) result = fl_value_new_int(static_cast<int64_t>(rate));
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "requestPointerLock")) {
    bool success = webView->requestPointerLock();
    g_autoptr(FlValue) result = fl_value_new_bool(success);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "requestPointerUnlock")) {
    bool success = webView->requestPointerUnlock();
    g_autoptr(FlValue) result = fl_value_new_bool(success);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

// === Event methods ===

void WebViewChannelDelegate::onLoadStart(
    const std::optional<std::string>& url) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  if (url.has_value()) {
    fl_value_set_string_take(args, "url", fl_value_new_string(url->c_str()));
  } else {
    fl_value_set_string_take(args, "url", fl_value_new_null());
  }

  invokeMethod("onLoadStart", args);
}

void WebViewChannelDelegate::onLoadStop(
    const std::optional<std::string>& url) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  if (url.has_value()) {
    fl_value_set_string_take(args, "url", fl_value_new_string(url->c_str()));
  } else {
    fl_value_set_string_take(args, "url", fl_value_new_null());
  }

  invokeMethod("onLoadStop", args);
}

void WebViewChannelDelegate::onProgressChanged(int64_t progress) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "progress", fl_value_new_int(progress));

  invokeMethod("onProgressChanged", args);
}

void WebViewChannelDelegate::onTitleChanged(
    const std::optional<std::string>& title) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  if (title.has_value()) {
    fl_value_set_string_take(args, "title", fl_value_new_string(title->c_str()));
  } else {
    fl_value_set_string_take(args, "title", fl_value_new_null());
  }

  invokeMethod("onTitleChanged", args);
}

void WebViewChannelDelegate::onUpdateVisitedHistory(
    const std::optional<std::string>& url,
    const std::optional<bool>& isReload) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  if (url.has_value()) {
    fl_value_set_string_take(args, "url", fl_value_new_string(url->c_str()));
  } else {
    fl_value_set_string_take(args, "url", fl_value_new_null());
  }
  if (isReload.has_value()) {
    fl_value_set_string_take(args, "isReload",
                             fl_value_new_bool(isReload.value()));
  } else {
    fl_value_set_string_take(args, "isReload", fl_value_new_null());
  }

  invokeMethod("onUpdateVisitedHistory", args);
}

void WebViewChannelDelegate::shouldOverrideUrlLoading(
    std::shared_ptr<NavigationAction> navigationAction,
    std::unique_ptr<ShouldOverrideUrlLoadingCallback> callback) const {
  if (!channel_) {
    if (callback) {
      callback->defaultBehaviour(std::nullopt);
    }
    return;
  }

  if (DebugLogEnabled()) {
    std::string url = navigationAction->request ? 
        navigationAction->request->url.value_or("") : "";
    g_message("WebViewChannelDelegate: shouldOverrideUrlLoading url=%s mainFrame=%s",
              url.c_str(), navigationAction->isForMainFrame ? "true" : "false");
  }

  FlValue* args = navigationAction->toFlValue();

  // Store callback for async response handling
  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "shouldOverrideUrlLoading", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<ShouldOverrideUrlLoadingCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response =
            fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue =
              fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse =
              FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onConsoleMessage(const std::string& message,
                                               int64_t messageLevel) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "message", fl_value_new_string(message.c_str()));
  fl_value_set_string_take(args, "messageLevel", fl_value_new_int(messageLevel));

  invokeMethod("onConsoleMessage", args);
}

void WebViewChannelDelegate::onReceivedError(
    std::shared_ptr<WebResourceRequest> request,
    std::shared_ptr<WebResourceError> error) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "request", request->toFlValue());
  fl_value_set_string_take(args, "error", error->toFlValue());

  invokeMethod("onReceivedError", args);
}

void WebViewChannelDelegate::onReceivedHttpError(
    std::shared_ptr<WebResourceRequest> request,
    std::shared_ptr<WebResourceResponse> errorResponse) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "request", request->toFlValue());
  fl_value_set_string_take(args, "errorResponse", errorResponse->toFlValue());

  invokeMethod("onReceivedHttpError", args);
}

void WebViewChannelDelegate::onCallJsHandler(
    const std::string& handlerName,
    std::unique_ptr<JavaScriptHandlerFunctionData> data,
    std::unique_ptr<CallJsHandlerCallback> callback) const {
  if (!channel_) {
    if (callback) {
      callback->defaultBehaviour(std::nullopt);
    }
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "handlerName",
                           fl_value_new_string(handlerName.c_str()));
  fl_value_set_string_take(args, "data", data->toFlValue());

  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "onCallJsHandler", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<CallJsHandlerCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response =
            fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue =
              fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse =
              FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onCloseWindow() const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  invokeMethod("onCloseWindow", args);
}

void WebViewChannelDelegate::onPageCommitVisible(
    const std::optional<std::string>& url) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  if (url.has_value()) {
    fl_value_set_string_take(args, "url", fl_value_new_string(url->c_str()));
  } else {
    fl_value_set_string_take(args, "url", fl_value_new_null());
  }

  invokeMethod("onPageCommitVisible", args);
}

void WebViewChannelDelegate::onZoomScaleChanged(double newScale,
                                                 double oldScale) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "newScale", fl_value_new_float(newScale));
  fl_value_set_string_take(args, "oldScale", fl_value_new_float(oldScale));

  invokeMethod("onZoomScaleChanged", args);
}

void WebViewChannelDelegate::onScrollChanged(int64_t x, int64_t y) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "x", fl_value_new_int(x));
  fl_value_set_string_take(args, "y", fl_value_new_int(y));

  invokeMethod("onScrollChanged", args);
}

void WebViewChannelDelegate::shouldInterceptRequest(
    std::shared_ptr<WebResourceRequest> request,
    std::unique_ptr<ShouldInterceptRequestCallback> callback) const {
  if (!channel_) {
    if (callback) {
      callback->defaultBehaviour(std::nullopt);
    }
    return;
  }

  FlValue* args = request->toFlValue();

  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "shouldInterceptRequest", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<ShouldInterceptRequestCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response =
            fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue =
              fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse =
              FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onWebViewCreated() const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  invokeMethod("onWebViewCreated", args);
}

void WebViewChannelDelegate::onContentSizeChanged(int64_t width,
                                                   int64_t height) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "width", fl_value_new_int(width));
  fl_value_set_string_take(args, "height", fl_value_new_int(height));

  invokeMethod("onContentSizeChanged", args);
}

void WebViewChannelDelegate::onCreateWindow(
    std::unique_ptr<CreateWindowAction> createWindowAction,
    std::unique_ptr<CreateWindowCallback> callback) const {
  if (!channel_) {
    callback->defaultBehaviour(std::nullopt);
    return;
  }

  FlValue* args = createWindowAction->toFlValue();
  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "onCreateWindow", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<CreateWindowCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response =
            fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue =
              fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse =
              FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onJsAlert(
    std::unique_ptr<JsAlertRequest> request,
    std::unique_ptr<JsAlertCallback> callback) const {
  if (!channel_) {
    callback->defaultBehaviour(std::nullopt);
    return;
  }

  FlValue* args = request->toFlValue();
  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "onJsAlert", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<JsAlertCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response =
            fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue =
              fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse =
              FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onJsConfirm(
    std::unique_ptr<JsConfirmRequest> request,
    std::unique_ptr<JsConfirmCallback> callback) const {
  if (!channel_) {
    callback->defaultBehaviour(std::nullopt);
    return;
  }

  FlValue* args = request->toFlValue();
  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "onJsConfirm", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<JsConfirmCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response =
            fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue =
              fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse =
              FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onJsPrompt(
    std::unique_ptr<JsPromptRequest> request,
    std::unique_ptr<JsPromptCallback> callback) const {
  if (!channel_) {
    callback->defaultBehaviour(std::nullopt);
    return;
  }

  FlValue* args = request->toFlValue();
  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "onJsPrompt", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<JsPromptCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response =
            fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue =
              fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse =
              FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onJsBeforeUnload(
    const std::optional<std::string>& url,
    const std::optional<std::string>& message,
    std::unique_ptr<JsBeforeUnloadCallback> callback) const {
  if (!channel_) {
    callback->defaultBehaviour(std::nullopt);
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  if (url.has_value()) {
    fl_value_set_string_take(args, "url",
                             fl_value_new_string(url.value().c_str()));
  } else {
    fl_value_set_string_take(args, "url", fl_value_new_null());
  }
  if (message.has_value()) {
    fl_value_set_string_take(args, "message",
                             fl_value_new_string(message.value().c_str()));
  } else {
    fl_value_set_string_take(args, "message", fl_value_new_null());
  }

  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "onJsBeforeUnload", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<JsBeforeUnloadCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response =
            fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue =
              fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse =
              FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onPermissionRequest(
    std::unique_ptr<PermissionRequest> request,
    std::unique_ptr<PermissionRequestCallback> callback) const {
  if (!channel_) {
    callback->defaultBehaviour(std::nullopt);
    return;
  }

  FlValue* args = request->toFlValue();
  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "onPermissionRequest", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<PermissionRequestCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response =
            fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue =
              fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse =
              FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onReceivedHttpAuthRequest(
    std::unique_ptr<HttpAuthenticationChallenge> challenge,
    std::unique_ptr<HttpAuthRequestCallback> callback) const {
  if (!channel_) {
    callback->defaultBehaviour(std::nullopt);
    return;
  }

  FlValue* args = challenge->toFlValue();
  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "onReceivedHttpAuthRequest", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<HttpAuthRequestCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response =
            fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue =
              fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse =
              FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onDownloadStarting(
    std::unique_ptr<DownloadStartRequest> request,
    std::unique_ptr<DownloadStartCallback> callback) const {
  if (!channel_) {
    callback->defaultBehaviour(std::nullopt);
    return;
  }

  FlValue* args = request->toFlValue();
  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "onDownloadStarting", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<DownloadStartCallback*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response =
            fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr) {
          cb->handleError("CHANNEL_ERROR", error->message);
        } else if (FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          FlValue* returnValue =
              fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));
          cb->handleResult(returnValue);
        } else if (FL_IS_METHOD_ERROR_RESPONSE(response)) {
          FlMethodErrorResponse* errorResponse =
              FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onEnterFullscreen() const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  invokeMethod("onEnterFullscreen", args);
}

void WebViewChannelDelegate::onExitFullscreen() const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  invokeMethod("onExitFullscreen", args);
}

void WebViewChannelDelegate::onFaviconChanged(
    const std::optional<std::string>& faviconUrl) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  if (faviconUrl.has_value()) {
    fl_value_set_string_take(args, "url",
                             fl_value_new_string(faviconUrl.value().c_str()));
  } else {
    fl_value_set_string_take(args, "url", fl_value_new_null());
  }

  invokeMethod("onReceivedIcon", args);
}

void WebViewChannelDelegate::onCreateContextMenu(
    const std::string& hitTestResultType,
    const std::string& extra) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "type",
                           fl_value_new_string(hitTestResultType.c_str()));
  fl_value_set_string_take(args, "extra",
                           fl_value_new_string(extra.c_str()));

  invokeMethod("onCreateContextMenu", args);
}

void WebViewChannelDelegate::onHideContextMenu() const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  invokeMethod("onHideContextMenu", args);
}

void WebViewChannelDelegate::onContextMenuActionItemClicked(
    const std::string& id,
    const std::string& title) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = fl_value_new_map();
  fl_value_set_string_take(args, "id", fl_value_new_string(id.c_str()));
  fl_value_set_string_take(args, "title", fl_value_new_string(title.c_str()));

  invokeMethod("onContextMenuActionItemClicked", args);
}

}  // namespace flutter_inappwebview_plugin
