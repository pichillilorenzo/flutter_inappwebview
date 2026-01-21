#include "webview_channel_delegate.h"

#include <cstring>

#include "../in_app_browser/in_app_browser.h"
#include "../types/client_cert_challenge.h"
#include "../types/client_cert_response.h"
#include "../types/custom_scheme_response.h"
#include "../types/hit_test_result.h"
#include "../types/ssl_certificate.h"
#include "../types/url_request.h"
#include "../types/user_script.h"
#include "../types/find_session.h"
#include "../types/web_resource_request.h"
#include "../types/web_resource_response.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "in_app_webview.h"
#include "in_app_webview_settings.h"

namespace flutter_inappwebview_plugin {

namespace {
// Helper to compare method names
bool string_equals(const gchar* a, const char* b) {
  return strcmp(a, b) == 0;
}
}  // namespace

// === Callback implementations ===

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

WebViewChannelDelegate::ServerTrustAuthRequestCallback::ServerTrustAuthRequestCallback() {
  decodeResult = [](FlValue* value) -> std::optional<ServerTrustAuthResponse> {
    return ServerTrustAuthResponse::fromFlValue(value);
  };
}

WebViewChannelDelegate::ClientCertRequestCallback::ClientCertRequestCallback() {
  decodeResult = [](FlValue* value) -> std::optional<ClientCertResponse> {
    return ClientCertResponse::fromFlValue(value);
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

WebViewChannelDelegate::LoadResourceWithCustomSchemeCallback::
    LoadResourceWithCustomSchemeCallback() {
  decodeResult = [](FlValue* value) -> std::optional<std::shared_ptr<CustomSchemeResponse>> {
    if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      return std::nullopt;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_MAP) {
      return std::make_shared<CustomSchemeResponse>(value);
    }
    return std::nullopt;
  };
}

WebViewChannelDelegate::NavigationResponseCallback::NavigationResponseCallback() {
  decodeResult = [](FlValue* value) -> std::optional<int> {
    if (value == nullptr || fl_value_get_type(value) == FL_VALUE_TYPE_NULL) {
      // Default: allow navigation
      return 1;
    }
    if (fl_value_get_type(value) == FL_VALUE_TYPE_INT) {
      return static_cast<int>(fl_value_get_int(value));
    }
    // If response is a map, extract the "action" field
    if (fl_value_get_type(value) == FL_VALUE_TYPE_MAP) {
      FlValue* action_value = fl_value_lookup_string(value, "action");
      if (action_value != nullptr && fl_value_get_type(action_value) == FL_VALUE_TYPE_INT) {
        return static_cast<int>(fl_value_get_int(action_value));
      }
    }
    return 1;  // Default: allow
  };
}

// === Constructors ===

WebViewChannelDelegate::WebViewChannelDelegate(InAppWebView* webView, FlBinaryMessenger* messenger)
    : ChannelDelegate(messenger, std::string(InAppWebView::METHOD_CHANNEL_NAME_PREFIX) +
                                     std::to_string(webView->id())),
      webView(webView) {}

WebViewChannelDelegate::WebViewChannelDelegate(InAppWebView* webView, FlBinaryMessenger* messenger,
                                               const std::string& name)
    : ChannelDelegate(messenger, name), webView(webView) {}

WebViewChannelDelegate::~WebViewChannelDelegate() {
  debugLog("dealloc WebViewChannelDelegate");
  webView = nullptr;
}

void WebViewChannelDelegate::HandleMethodCall(FlMethodCall* method_call) {
  if (!webView) {
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  const gchar* methodName = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);

  // === InAppBrowser-specific methods ===
  // When this WebView is embedded in an InAppBrowser, forward browser-specific methods
  InAppBrowser* inAppBrowser = webView->getInAppBrowserDelegate();

  if (string_equals(methodName, "show")) {
    if (inAppBrowser) {
      inAppBrowser->show();
      fl_method_call_respond_success(method_call, fl_value_new_bool(true), nullptr);
    } else {
      fl_method_call_respond_not_implemented(method_call, nullptr);
    }
    return;
  }

  if (string_equals(methodName, "hide")) {
    if (inAppBrowser) {
      inAppBrowser->hide();
      fl_method_call_respond_success(method_call, fl_value_new_bool(true), nullptr);
    } else {
      fl_method_call_respond_not_implemented(method_call, nullptr);
    }
    return;
  }

  if (string_equals(methodName, "close")) {
    if (inAppBrowser) {
      inAppBrowser->close();
      fl_method_call_respond_success(method_call, fl_value_new_bool(true), nullptr);
    } else {
      fl_method_call_respond_not_implemented(method_call, nullptr);
    }
    return;
  }

  if (string_equals(methodName, "isHidden")) {
    if (inAppBrowser) {
      bool hidden = inAppBrowser->isHidden();
      fl_method_call_respond_success(method_call, fl_value_new_bool(hidden), nullptr);
    } else {
      fl_method_call_respond_not_implemented(method_call, nullptr);
    }
    return;
  }

  // === WebView methods ===

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

  if (string_equals(methodName, "getOriginalUrl")) {
    // In WPE WebKit, the original URL is not directly tracked separately
    // We return the current URL as a fallback
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
    FlValue* url_request = get_fl_map_value_raw(args, "urlRequest");
    if (url_request != nullptr && fl_value_get_type(url_request) == FL_VALUE_TYPE_MAP) {
      auto request = std::make_shared<URLRequest>(url_request);
      webView->loadUrl(request);
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "loadData")) {
    std::string data = get_fl_map_value<std::string>(args, "data", "");
    if (!data.empty()) {
      std::string mime_type = get_fl_map_value<std::string>(args, "mimeType", "text/html");
      std::string encoding = get_fl_map_value<std::string>(args, "encoding", "UTF-8");
      std::string base_url = get_fl_map_value<std::string>(args, "baseUrl", "about:blank");
      webView->loadData(data, mime_type, encoding, base_url);
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "postUrl")) {
    std::string url = get_fl_map_value<std::string>(args, "url", "");
    auto postData = get_optional_fl_map_value<std::vector<uint8_t>>(args, "postData");
    if (!url.empty() && postData.has_value()) {
      webView->postUrl(url, postData.value());
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

  if (string_equals(methodName, "reloadFromOrigin")) {
    webView->reloadFromOrigin();
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

  if (string_equals(methodName, "goBackOrForward")) {
    int64_t steps = get_fl_map_value<int64_t>(args, "steps", 0);
    webView->goBackOrForward(static_cast<int>(steps));
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "canGoBackOrForward")) {
    int64_t steps = get_fl_map_value<int64_t>(args, "steps", 0);
    bool canGo = webView->canGoBackOrForward(static_cast<int>(steps));
    g_autoptr(FlValue) result = fl_value_new_bool(canGo);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "getCopyBackForwardList")) {
    FlValue* result = webView->getCopyBackForwardList();
    fl_method_call_respond_success(method_call, result, nullptr);
    fl_value_unref(result);  // getCopyBackForwardList returns a new reference
    return;
  }

  if (string_equals(methodName, "stopLoading")) {
    webView->stopLoading();
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "getSettings")) {
    // For InAppBrowser, return combined browser + webview settings
    if (inAppBrowser) {
      g_autoptr(FlValue) result = inAppBrowser->getSettings();
      fl_method_call_respond_success(method_call, result, nullptr);
    } else {
      g_autoptr(FlValue) result = webView->getSettings();
      fl_method_call_respond_success(method_call, result, nullptr);
    }
    return;
  }

  if (string_equals(methodName, "setSettings")) {
    FlValue* settings_value = get_fl_map_value_raw(args, "settings");
    if (settings_value != nullptr && fl_value_get_type(settings_value) == FL_VALUE_TYPE_MAP) {
      // For InAppBrowser, set both browser and webview settings
      if (inAppBrowser) {
        auto newBrowserSettings = std::make_shared<InAppBrowserSettings>(settings_value);
        inAppBrowser->setSettings(newBrowserSettings, settings_value);
      } else {
        auto newSettings = std::make_shared<InAppWebViewSettings>(settings_value);
        webView->setSettings(newSettings, settings_value);
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "setSize")) {
    if (fl_value_get_type(args) == FL_VALUE_TYPE_LIST && fl_value_get_length(args) >= 2) {
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
    std::string assetFilePath = get_fl_map_value<std::string>(args, "assetFilePath", "");
    if (!assetFilePath.empty()) {
      webView->loadFile(assetFilePath);
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
    std::string source = get_fl_map_value<std::string>(args, "source", "");
    if (!source.empty()) {
      // Extract contentWorld if provided
      FlValue* contentWorld = fl_value_lookup_string(args, "contentWorld");
      std::optional<std::string> worldName = std::nullopt;
      if (contentWorld != nullptr && fl_value_get_type(contentWorld) == FL_VALUE_TYPE_MAP) {
        FlValue* name = fl_value_lookup_string(contentWorld, "name");
        if (name != nullptr && fl_value_get_type(name) == FL_VALUE_TYPE_STRING) {
          worldName = fl_value_get_string(name);
        }
      }

      // Capture method_call for async callback
      g_object_ref(method_call);

      webView->evaluateJavascript(
          source, worldName, [method_call](const std::optional<std::string>& result) {
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
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (string_equals(methodName, "callAsyncJavaScript")) {
    std::string functionBody = get_fl_map_value<std::string>(args, "functionBody", "");
    // Arguments are now passed as a JSON-encoded string from Dart
    std::string argumentsJson = get_fl_map_value<std::string>(args, "arguments", "{}");
    // Get the list of argument keys for destructuring
    std::vector<std::string> argumentKeys = get_fl_map_value<std::vector<std::string>>(args, "argumentKeys", {});
    FlValue* contentWorld = fl_value_lookup_string(args, "contentWorld");

    std::optional<std::string> worldName = std::nullopt;
    if (contentWorld != nullptr && fl_value_get_type(contentWorld) == FL_VALUE_TYPE_MAP) {
      FlValue* name = fl_value_lookup_string(contentWorld, "name");
      if (name != nullptr && fl_value_get_type(name) == FL_VALUE_TYPE_STRING) {
        worldName = fl_value_get_string(name);
      }
    }

    // Keep method call alive for async response
    g_object_ref(method_call);

    webView->callAsyncJavaScript(
        functionBody, argumentsJson, argumentKeys, worldName,
        [method_call](const std::string& jsonResult) {
          // Return the JSON string directly - Dart side will decode it
          g_autoptr(FlValue) result = fl_value_new_string(jsonResult.c_str());
          fl_method_call_respond_success(method_call, result, nullptr);
          g_object_unref(method_call);
        });
    return;
  }

  if (string_equals(methodName, "injectJavascriptFileFromUrl")) {
    std::string urlFile = get_fl_map_value<std::string>(args, "urlFile", "");
    if (!urlFile.empty()) {
      webView->injectJavascriptFileFromUrl(urlFile);
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "injectCSSCode")) {
    std::string source = get_fl_map_value<std::string>(args, "source", "");
    if (!source.empty()) {
      webView->injectCSSCode(source);
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "injectCSSFileFromUrl")) {
    std::string urlFile = get_fl_map_value<std::string>(args, "urlFile", "");
    if (!urlFile.empty()) {
      webView->injectCSSFileFromUrl(urlFile);
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

  if (string_equals(methodName, "getCertificate")) {
    auto certificate = webView->getCertificate();
    if (certificate.has_value()) {
      FlValue* result = certificate->toFlValue();
      fl_method_call_respond_success(method_call, result, nullptr);
      fl_value_unref(result);
    } else {
      fl_method_call_respond_success(method_call, nullptr, nullptr);
    }
    return;
  }

  if (string_equals(methodName, "getHitTestResult")) {
    HitTestResult hitTestResult = webView->getHitTestResult();
    FlValue* result = hitTestResult.toFlValue();
    fl_method_call_respond_success(method_call, result, nullptr);
    fl_value_unref(result);
    return;
  }

  if (string_equals(methodName, "getHtml")) {
    // Capture method_call for async callback
    g_object_ref(method_call);

    webView->getHtml([method_call](const std::optional<std::string>& result) {
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

  if (string_equals(methodName, "takeScreenshot")) {
    // Capture method_call for async callback
    g_object_ref(method_call);

    webView->takeScreenshot([method_call](const std::optional<std::vector<uint8_t>>& result) {
      if (result.has_value() && !result->empty()) {
        // Return the PNG data as a Uint8List
        g_autoptr(FlValue) val = fl_value_new_uint8_list(result->data(), result->size());
        fl_method_call_respond_success(method_call, val, nullptr);
      } else {
        fl_method_call_respond_success(method_call, nullptr, nullptr);
      }
      g_object_unref(method_call);
    });
    return;
  }

  if (string_equals(methodName, "getSelectedText")) {
    // Capture method_call for async callback
    g_object_ref(method_call);

    webView->getSelectedText([method_call](const std::optional<std::string>& result) {
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

  if (string_equals(methodName, "isSecureContext")) {
    // Capture method_call for async callback
    g_object_ref(method_call);

    webView->isSecureContext([method_call](bool isSecure) {
      g_autoptr(FlValue) val = fl_value_new_bool(isSecure);
      fl_method_call_respond_success(method_call, val, nullptr);
      g_object_unref(method_call);
    });
    return;
  }

  if (string_equals(methodName, "canScrollVertically")) {
    // Capture method_call for async callback
    g_object_ref(method_call);

    webView->canScrollVertically([method_call](bool canScroll) {
      g_autoptr(FlValue) val = fl_value_new_bool(canScroll);
      fl_method_call_respond_success(method_call, val, nullptr);
      g_object_unref(method_call);
    });
    return;
  }

  if (string_equals(methodName, "canScrollHorizontally")) {
    // Capture method_call for async callback
    g_object_ref(method_call);

    webView->canScrollHorizontally([method_call](bool canScroll) {
      g_autoptr(FlValue) val = fl_value_new_bool(canScroll);
      fl_method_call_respond_success(method_call, val, nullptr);
      g_object_unref(method_call);
    });
    return;
  }

  if (string_equals(methodName, "saveState")) {
    auto state = webView->saveState();
    if (state.has_value() && !state->empty()) {
      g_autoptr(FlValue) result = fl_value_new_uint8_list(state->data(), state->size());
      fl_method_call_respond_success(method_call, result, nullptr);
    } else {
      fl_method_call_respond_success(method_call, nullptr, nullptr);
    }
    return;
  }

  if (string_equals(methodName, "restoreState")) {
    auto stateOpt = get_optional_fl_map_value<std::vector<uint8_t>>(args, "state");
    if (stateOpt.has_value() && !stateOpt->empty()) {
      bool success = webView->restoreState(stateOpt.value());
      g_autoptr(FlValue) result = fl_value_new_bool(success);
      fl_method_call_respond_success(method_call, result, nullptr);
      return;
    }
    g_autoptr(FlValue) result = fl_value_new_bool(false);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "saveWebArchive")) {
    auto filePath = get_fl_map_value<std::string>(args, "filePath", "");
    bool autoname = get_fl_map_value<bool>(args, "autoname", false);
    
    if (filePath.empty()) {
      fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
      return;
    }
    
    // Ref the method call to prevent it from being freed before async callback
    g_object_ref(method_call);
    
    webView->saveWebArchive(filePath, autoname, [method_call](const std::optional<std::string>& result) {
      if (result.has_value()) {
        g_autoptr(FlValue) flResult = fl_value_new_string(result->c_str());
        fl_method_call_respond_success(method_call, flResult, nullptr);
      } else {
        fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
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
    double zoomScale = get_fl_map_value<double>(args, "zoomScale", 1.0);
    webView->setZoomScale(zoomScale);
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "scrollTo")) {
    int64_t x = get_fl_map_value<int64_t>(args, "x", 0);
    int64_t y = get_fl_map_value<int64_t>(args, "y", 0);
    bool animated = get_fl_map_value<bool>(args, "animated", false);
    webView->scrollTo(x, y, animated);
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "scrollBy")) {
    int64_t x = get_fl_map_value<int64_t>(args, "x", 0);
    int64_t y = get_fl_map_value<int64_t>(args, "y", 0);
    bool animated = get_fl_map_value<bool>(args, "animated", false);
    webView->scrollBy(x, y, animated);
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "getScrollX")) {
    g_object_ref(method_call);
    webView->getScrollX([method_call](int64_t scrollX) {
      g_autoptr(FlValue) result = fl_value_new_int(scrollX);
      fl_method_call_respond_success(method_call, result, nullptr);
      g_object_unref(method_call);
    });
    return;
  }

  if (string_equals(methodName, "getScrollY")) {
    g_object_ref(method_call);
    webView->getScrollY([method_call](int64_t scrollY) {
      g_autoptr(FlValue) result = fl_value_new_int(scrollY);
      fl_method_call_respond_success(method_call, result, nullptr);
      g_object_unref(method_call);
    });
    return;
  }

  if (string_equals(methodName, "getContentHeight")) {
    // Capture method_call for async callback
    g_object_ref(method_call);
    webView->getContentHeight([method_call](int64_t height) {
      g_autoptr(FlValue) result = fl_value_new_int(height);
      fl_method_call_respond_success(method_call, result, nullptr);
      g_object_unref(method_call);
    });
    return;
  }

  if (string_equals(methodName, "getContentWidth")) {
    // Capture method_call for async callback
    g_object_ref(method_call);
    webView->getContentWidth([method_call](int64_t width) {
      g_autoptr(FlValue) result = fl_value_new_int(width);
      fl_method_call_respond_success(method_call, result, nullptr);
      g_object_unref(method_call);
    });
    return;
  }

  // === User Script Methods ===
  if (string_equals(methodName, "addUserScript")) {
    FlValue* user_script_value = get_fl_map_value_raw(args, "userScript");
    if (user_script_value != nullptr && fl_value_get_type(user_script_value) == FL_VALUE_TYPE_MAP) {
      auto userScript = std::make_shared<UserScript>(user_script_value);
      webView->addUserScript(userScript);
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "removeUserScript")) {
    int64_t index = get_fl_map_value<int64_t>(args, "index", 0);
    int64_t injectionTimeInt = get_fl_map_value<int64_t>(args, "injectionTime", 0);
    auto injectionTime = static_cast<UserScriptInjectionTime>(injectionTimeInt);
    webView->removeUserScriptAt(static_cast<size_t>(index), injectionTime);
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "removeUserScriptsByGroupName")) {
    std::string groupName = get_fl_map_value<std::string>(args, "groupName", "");
    if (!groupName.empty()) {
      webView->removeUserScriptsByGroupName(groupName);
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

  // === Web Message Listener Methods ===
  if (string_equals(methodName, "addWebMessageListener")) {
    FlValue* listener_value = get_fl_map_value_raw(args, "webMessageListener");
    if (listener_value != nullptr && fl_value_get_type(listener_value) == FL_VALUE_TYPE_MAP) {
      std::string jsObjectName = get_fl_map_value<std::string>(listener_value, "jsObjectName", "");
      std::vector<std::string> allowedOriginRules = 
          get_fl_map_value<std::vector<std::string>>(listener_value, "allowedOriginRules", std::vector<std::string>());
      
      if (!jsObjectName.empty()) {
        webView->addWebMessageListener(jsObjectName, allowedOriginRules);
      }
    }
    g_autoptr(FlValue) result = fl_value_new_bool(true);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  // === Web Message Channel Methods ===
  if (string_equals(methodName, "createWebMessageChannel")) {
    // Ref the method call for async response
    g_object_ref(method_call);
    
    webView->createWebMessageChannel([method_call](const std::optional<std::string>& channelId) {
      if (channelId.has_value()) {
        g_autoptr(FlValue) result = to_fl_map({
            {"id", make_fl_value(*channelId)},
        });
        fl_method_call_respond_success(method_call, result, nullptr);
      } else {
        fl_method_call_respond_success(method_call, fl_value_new_null(), nullptr);
      }
      g_object_unref(method_call);
    });
    return;
  }

  if (string_equals(methodName, "postWebMessage")) {
    FlValue* message_value = get_fl_map_value_raw(args, "message");
    std::string targetOrigin = get_fl_map_value<std::string>(args, "targetOrigin", "*");
    
    if (message_value != nullptr && fl_value_get_type(message_value) == FL_VALUE_TYPE_MAP) {
      // Extract message data
      std::string data = "";
      int64_t type = 0;  // 0 = string, 1 = arrayBuffer
      
      FlValue* data_value = fl_value_lookup_string(message_value, "data");
      FlValue* type_value = fl_value_lookup_string(message_value, "type");
      
      if (data_value != nullptr && fl_value_get_type(data_value) == FL_VALUE_TYPE_STRING) {
        data = fl_value_get_string(data_value);
      }
      if (type_value != nullptr && fl_value_get_type(type_value) == FL_VALUE_TYPE_INT) {
        type = fl_value_get_int(type_value);
      }
      
      webView->postWebMessage(data, targetOrigin, type);
    }
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

  if (string_equals(methodName, "getScreenScale")) {
    double scale = webView->getScreenScale();
    g_autoptr(FlValue) result = fl_value_new_float(scale);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "setScreenScale")) {
    double scale = 1.0;
    if (fl_value_get_type(args) == FL_VALUE_TYPE_FLOAT) {
      scale = fl_value_get_float(args);
    } else if (fl_value_get_type(args) == FL_VALUE_TYPE_INT) {
      scale = static_cast<double>(fl_value_get_int(args));
    }
    webView->setScreenScale(scale);
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (string_equals(methodName, "isVisible")) {
    bool visible = webView->isVisible();
    g_autoptr(FlValue) result = fl_value_new_bool(visible);
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

  if (string_equals(methodName, "hideContextMenu")) {
    webView->HideContextMenu();
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // === Media Playback Control ===
  if (string_equals(methodName, "pauseAllMediaPlayback")) {
    webView->pauseAllMediaPlayback();
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (string_equals(methodName, "setAllMediaPlaybackSuspended")) {
    bool suspended = get_fl_map_value<bool>(args, "suspended", false);
    webView->setAllMediaPlaybackSuspended(suspended);
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (string_equals(methodName, "closeAllMediaPresentations")) {
    webView->closeAllMediaPresentations();
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (string_equals(methodName, "requestMediaPlaybackState")) {
    g_object_ref(method_call);
    webView->requestMediaPlaybackState([method_call](int state) {
      g_autoptr(FlValue) result = fl_value_new_int(state);
      fl_method_call_respond_success(method_call, result, nullptr);
      g_object_unref(method_call);
    });
    return;
  }

  // === Media Capture State (Camera and Microphone) ===
  if (string_equals(methodName, "getCameraCaptureState")) {
    int state = webView->getCameraCaptureState();
    g_autoptr(FlValue) result = fl_value_new_int(state);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "setCameraCaptureState")) {
    int64_t state = get_fl_map_value<int64_t>(args, "state", 0);
    webView->setCameraCaptureState(static_cast<int>(state));
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (string_equals(methodName, "getMicrophoneCaptureState")) {
    int state = webView->getMicrophoneCaptureState();
    g_autoptr(FlValue) result = fl_value_new_int(state);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "setMicrophoneCaptureState")) {
    int64_t state = get_fl_map_value<int64_t>(args, "state", 0);
    webView->setMicrophoneCaptureState(static_cast<int>(state));
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // === Theme Color ===
  if (string_equals(methodName, "getMetaThemeColor")) {
    auto themeColor = webView->getMetaThemeColor();
    if (themeColor.has_value()) {
      g_autoptr(FlValue) result = fl_value_new_string(themeColor->c_str());
      fl_method_call_respond_success(method_call, result, nullptr);
    } else {
      fl_method_call_respond_success(method_call, nullptr, nullptr);
    }
    return;
  }

  // === Audio State (Playing and Mute) ===
  if (string_equals(methodName, "isPlayingAudio")) {
    bool isPlaying = webView->isPlayingAudio();
    g_autoptr(FlValue) result = fl_value_new_bool(isPlaying);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "isMuted")) {
    bool isMuted = webView->isMuted();
    g_autoptr(FlValue) result = fl_value_new_bool(isMuted);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  if (string_equals(methodName, "setMuted")) {
    bool muted = get_fl_map_value<bool>(args, "muted", false);
    webView->setMuted(muted);
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // === Web Process Control ===
  if (string_equals(methodName, "terminateWebProcess")) {
    webView->terminateWebProcess();
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  // === Focus Control ===
  if (string_equals(methodName, "clearFocus")) {
    webView->clearFocus();
    fl_method_call_respond_success(method_call, nullptr, nullptr);
    return;
  }

  if (string_equals(methodName, "requestFocus")) {
    bool success = webView->requestFocus();
    g_autoptr(FlValue) result = fl_value_new_bool(success);
    fl_method_call_respond_success(method_call, result, nullptr);
    return;
  }

  fl_method_call_respond_not_implemented(method_call, nullptr);
}

// === Event methods ===

void WebViewChannelDelegate::onLoadStart(const std::optional<std::string>& url) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map({{"url", make_fl_value(url)}});

  invokeMethod("onLoadStart", args);
}

void WebViewChannelDelegate::onLoadStop(const std::optional<std::string>& url) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map({{"url", make_fl_value(url)}});

  invokeMethod("onLoadStop", args);
}

void WebViewChannelDelegate::onProgressChanged(int64_t progress) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map({{"progress", make_fl_value(progress)}});

  invokeMethod("onProgressChanged", args);
}

void WebViewChannelDelegate::onTitleChanged(const std::optional<std::string>& title) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map({{"title", make_fl_value(title)}});

  invokeMethod("onTitleChanged", args);
}

void WebViewChannelDelegate::onUpdateVisitedHistory(const std::optional<std::string>& url,
                                                    const std::optional<bool>& isReload) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args =
      to_fl_map({{"url", make_fl_value(url)}, {"isReload", make_fl_value(isReload)}});

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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
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

  g_autoptr(FlValue) args =
      to_fl_map({{"message", make_fl_value(message)}, {"messageLevel", make_fl_value(messageLevel)}});

  invokeMethod("onConsoleMessage", args);
}

void WebViewChannelDelegate::onLoadResource(const std::string& url,
                                            const std::string& initiatorType,
                                            double startTime,
                                            double duration) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map({{"url", make_fl_value(url)},
                                      {"initiatorType", make_fl_value(initiatorType)},
                                      {"startTime", make_fl_value(startTime)},
                                      {"duration", make_fl_value(duration)}});

  invokeMethod("onLoadResource", args);
}

void WebViewChannelDelegate::onReceivedError(std::shared_ptr<WebResourceRequest> request,
                                             std::shared_ptr<WebResourceError> error) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args =
      to_fl_map({{"request", request->toFlValue()}, {"error", error->toFlValue()}});

  invokeMethod("onReceivedError", args);
}

void WebViewChannelDelegate::onReceivedHttpError(
    std::shared_ptr<WebResourceRequest> request,
    std::shared_ptr<WebResourceResponse> errorResponse) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map(
      {{"request", request->toFlValue()}, {"errorResponse", errorResponse->toFlValue()}});

  invokeMethod("onReceivedHttpError", args);
}

void WebViewChannelDelegate::onCallJsHandler(
    const std::string& handlerName, std::unique_ptr<JavaScriptHandlerFunctionData> data,
    std::unique_ptr<CallJsHandlerCallback> callback) const {
  if (!channel_) {
    if (callback) {
      callback->defaultBehaviour(std::nullopt);
    }
    return;
  }

  g_autoptr(FlValue) args =
      to_fl_map({{"handlerName", make_fl_value(handlerName)}, {"data", data->toFlValue()}});

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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
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

  g_autoptr(FlValue) args = to_fl_map({});
  invokeMethod("onCloseWindow", args);
}

void WebViewChannelDelegate::onPageCommitVisible(const std::optional<std::string>& url) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map({{"url", make_fl_value(url)}});

  invokeMethod("onPageCommitVisible", args);
}

void WebViewChannelDelegate::onZoomScaleChanged(double newScale, double oldScale) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args =
      to_fl_map({{"newScale", make_fl_value(newScale)}, {"oldScale", make_fl_value(oldScale)}});

  invokeMethod("onZoomScaleChanged", args);
}

void WebViewChannelDelegate::onScrollChanged(int64_t x, int64_t y) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map({{"x", make_fl_value(x)}, {"y", make_fl_value(y)}});

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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
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

  g_autoptr(FlValue) args = to_fl_map({});
  invokeMethod("onWebViewCreated", args);
}

void WebViewChannelDelegate::onContentSizeChanged(int64_t width, int64_t height) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args =
      to_fl_map({{"width", make_fl_value(width)}, {"height", make_fl_value(height)}});

  invokeMethod("onContentSizeChanged", args);
}

void WebViewChannelDelegate::onCreateWindow(std::unique_ptr<CreateWindowAction> createWindowAction,
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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onJsAlert(std::unique_ptr<JsAlertRequest> request,
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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onJsConfirm(std::unique_ptr<JsConfirmRequest> request,
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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onJsPrompt(std::unique_ptr<JsPromptRequest> request,
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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
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
    const std::optional<std::string>& url, const std::optional<std::string>& message,
    std::unique_ptr<JsBeforeUnloadCallback> callback) const {
  if (!channel_) {
    callback->defaultBehaviour(std::nullopt);
    return;
  }

  g_autoptr(FlValue) args =
      to_fl_map({{"url", make_fl_value(url)}, {"message", make_fl_value(message)}});

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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onReceivedServerTrustAuthRequest(
    std::unique_ptr<ServerTrustChallenge> challenge,
    std::unique_ptr<ServerTrustAuthRequestCallback> callback) const {
  if (!channel_) {
    callback->defaultBehaviour(std::nullopt);
    return;
  }

  FlValue* args = challenge->toFlValue();
  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "onReceivedServerTrustAuthRequest", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<ServerTrustAuthRequestCallback*>(user_data);
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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onReceivedClientCertRequest(
    std::unique_ptr<ClientCertChallenge> challenge,
    std::unique_ptr<ClientCertRequestCallback> callback) const {
  if (!channel_) {
    callback->defaultBehaviour(std::nullopt);
    return;
  }

  FlValue* args = challenge->toFlValue();
  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "onReceivedClientCertRequest", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<ClientCertRequestCallback*>(user_data);
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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
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

  g_autoptr(FlValue) args = to_fl_map({});
  invokeMethod("onEnterFullscreen", args);
}

void WebViewChannelDelegate::onExitFullscreen() const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map({});
  invokeMethod("onExitFullscreen", args);
}

void WebViewChannelDelegate::onFaviconChanged(const std::optional<std::string>& faviconUrl) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map({{"url", make_fl_value(faviconUrl)}});

  invokeMethod("onReceivedIcon", args);
}

void WebViewChannelDelegate::onRenderProcessGone(bool didCrash) const {
  if (!channel_) {
    return;
  }

  // Send didCrash and rendererPriorityAtExit at the top level (matching Android format)
  // Linux doesn't have renderer priority info, so we send null
  g_autoptr(FlValue) args = to_fl_map({{"didCrash", make_fl_value(didCrash)},
                                       {"rendererPriorityAtExit", make_fl_value()}});

  invokeMethod("onRenderProcessGone", args);
}

// Helper struct for onShowFileChooser callback
struct ShowFileChooserCallbackData {
  std::function<void(ShowFileChooserResponse)> callback;
};

void WebViewChannelDelegate::onShowFileChooser(
    int mode,
    const std::vector<std::string>& acceptTypes,
    bool isCaptureEnabled,
    const std::optional<std::string>& title,
    const std::optional<std::string>& filenameHint,
    std::function<void(ShowFileChooserResponse)> callback) const {
  if (!channel_) {
    callback(ShowFileChooserResponse());
    return;
  }

  g_autoptr(FlValue) args =
      to_fl_map({{"mode", make_fl_value(static_cast<int64_t>(mode))},
                 {"acceptTypes", make_fl_value(acceptTypes)},
                 {"isCaptureEnabled", make_fl_value(isCaptureEnabled)},
                 {"title", make_fl_value(title)},
                 {"filenameHint", make_fl_value(filenameHint)}});

  // Create callback data on heap
  auto* callbackData = new ShowFileChooserCallbackData{std::move(callback)};

  invokeMethodWithResult(
      "onShowFileChooser", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* data = static_cast<ShowFileChooserCallbackData*>(user_data);
        FlMethodChannel* ch = FL_METHOD_CHANNEL(source);

        g_autoptr(GError) error = nullptr;
        g_autoptr(FlMethodResponse) response =
            fl_method_channel_invoke_method_finish(ch, result, &error);

        if (error != nullptr || !FL_IS_METHOD_SUCCESS_RESPONSE(response)) {
          data->callback(ShowFileChooserResponse());
          delete data;
          return;
        }

        FlValue* returnValue =
            fl_method_success_response_get_result(FL_METHOD_SUCCESS_RESPONSE(response));

        // Errors / null / unexpected types should behave as: handledByClient=false.
        data->callback(ShowFileChooserResponse::fromFlValue(returnValue));

        delete data;
      },
      callbackData);
}

void WebViewChannelDelegate::onCreateContextMenu(const HitTestResult& hitTestResult) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = hitTestResult.toFlValue();
  invokeMethod("onCreateContextMenu", args);
}

void WebViewChannelDelegate::onHideContextMenu() const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map({});
  invokeMethod("onHideContextMenu", args);
}

void WebViewChannelDelegate::onContextMenuActionItemClicked(const std::string& id,
                                                            const std::string& title) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args =
      to_fl_map({{"id", make_fl_value(id)}, {"title", make_fl_value(title)}});

  invokeMethod("onContextMenuActionItemClicked", args);
}

void WebViewChannelDelegate::onLoadResourceWithCustomScheme(
    std::shared_ptr<WebResourceRequest> request,
    std::unique_ptr<LoadResourceWithCustomSchemeCallback> callback) const {
  if (!channel_) {
    if (callback) {
      callback->defaultBehaviour(std::nullopt);
    }
    return;
  }

  FlValue* args = request->toFlValue();

  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "onLoadResourceWithCustomScheme", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<LoadResourceWithCustomSchemeCallback*>(user_data);
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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onCameraCaptureStateChanged(int oldState, int newState) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map({
      {"oldState", make_fl_value(static_cast<int64_t>(oldState))},
      {"newState", make_fl_value(static_cast<int64_t>(newState))}
  });

  invokeMethod("onCameraCaptureStateChanged", args);
}

void WebViewChannelDelegate::onMicrophoneCaptureStateChanged(int oldState, int newState) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map({
      {"oldState", make_fl_value(static_cast<int64_t>(oldState))},
      {"newState", make_fl_value(static_cast<int64_t>(newState))}
  });

  invokeMethod("onMicrophoneCaptureStateChanged", args);
}

void WebViewChannelDelegate::onNavigationResponse(
    const std::string& url,
    const std::optional<std::string>& mimeType,
    int64_t contentLength,
    int statusCode,
    bool isForMainFrame,
    bool canShowMimeType,
    std::unique_ptr<NavigationResponseCallback> callback) const {
  if (!channel_) {
    if (callback) {
      callback->defaultBehaviour(1);  // Allow by default
    }
    return;
  }

  // Build the response map (matching platform interface URLResponse structure)
  g_autoptr(FlValue) responseMap = to_fl_map({
      {"url", make_fl_value(url)},
      {"mimeType", mimeType ? make_fl_value(*mimeType) : make_fl_value()},
      {"expectedContentLength", make_fl_value(contentLength)},
      {"statusCode", make_fl_value(static_cast<int64_t>(statusCode))},
      {"headers", make_fl_value()}  // Headers not easily available from WebKit response
  });

  // Build the main arguments map (matching platform interface format)
  // Note: Use "canShowMIMEType" to match Dart's NavigationResponse.fromMap expectations
  g_autoptr(FlValue) args = to_fl_map({
      {"response", responseMap},
      {"isForMainFrame", make_fl_value(isForMainFrame)},
      {"canShowMIMEType", make_fl_value(canShowMimeType)}
  });

  // Don't unref responseMap - it's now owned by args
  g_steal_pointer(&responseMap);

  auto* callbackPtr = callback.release();

  invokeMethodWithResult(
      "onNavigationResponse", args,
      [](GObject* source, GAsyncResult* result, gpointer user_data) {
        auto* cb = static_cast<NavigationResponseCallback*>(user_data);
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
          FlMethodErrorResponse* errorResponse = FL_METHOD_ERROR_RESPONSE(response);
          cb->handleError(fl_method_error_response_get_code(errorResponse),
                          fl_method_error_response_get_message(errorResponse));
        } else {
          cb->handleNotImplemented();
        }

        delete cb;
      },
      callbackPtr);
}

void WebViewChannelDelegate::onPrintRequest(const std::optional<std::string>& url) const {
  if (!channel_) {
    return;
  }

  g_autoptr(FlValue) args = to_fl_map({
      {"url", make_fl_value(url)},
      {"printJobController", make_fl_value()}  // No native print job controller on Linux
  });

  invokeMethod("onPrintRequest", args);
}

}  // namespace flutter_inappwebview_plugin
