#include "../in_app_browser/in_app_browser.h"
#include "../print_job/print_job_settings.h"
#include "../types/base_callback_result.h"
#include "../types/content_world.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/strconv.h"
#include "../utils/string.h"
#include "../utils/uuid.h"
#include "in_app_webview.h"
#include "webview_channel_delegate.h"

namespace flutter_inappwebview_plugin
{
  WebViewChannelDelegate::WebViewChannelDelegate(InAppWebView* webView, flutter::BinaryMessenger* messenger)
    : webView(webView), ChannelDelegate(messenger, InAppWebView::METHOD_CHANNEL_NAME_PREFIX + variant_to_string(webView->id))
  {}

  WebViewChannelDelegate::WebViewChannelDelegate(InAppWebView* webView, flutter::BinaryMessenger* messenger, const std::string& name)
    : webView(webView), ChannelDelegate(messenger, name)
  {}

  WebViewChannelDelegate::ShouldOverrideUrlLoadingCallback::ShouldOverrideUrlLoadingCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        if (!value || value->IsNull()) {
          return NavigationActionPolicy::cancel;
        }
        auto navigationPolicy = std::get<int>(*value);
        return static_cast<NavigationActionPolicy>(navigationPolicy);
      };
  }

  WebViewChannelDelegate::CallJsHandlerCallback::CallJsHandlerCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        return value;
      };
  }

  WebViewChannelDelegate::CreateWindowCallback::CreateWindowCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        if (!value || value->IsNull()) {
          return false;
        }
        auto handledByClient = std::get<bool>(*value);
        return handledByClient;
      };
  }

  WebViewChannelDelegate::PermissionRequestCallback::PermissionRequestCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        return value == nullptr || value->IsNull() ? std::optional<std::shared_ptr<PermissionResponse>>{} : std::make_shared<PermissionResponse>(std::get<flutter::EncodableMap>(*value));
      };
  }

  WebViewChannelDelegate::ShouldInterceptRequestCallback::ShouldInterceptRequestCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        return value == nullptr || value->IsNull() ? std::optional<std::shared_ptr<WebResourceResponse>>{} : std::make_shared<WebResourceResponse>(std::get<flutter::EncodableMap>(*value));
      };
  }

  WebViewChannelDelegate::LoadResourceWithCustomSchemeCallback::LoadResourceWithCustomSchemeCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        return value == nullptr || value->IsNull() ? std::optional<std::shared_ptr<CustomSchemeResponse>>{} : std::make_shared<CustomSchemeResponse>(std::get<flutter::EncodableMap>(*value));
      };
  }

  WebViewChannelDelegate::ReceivedHttpAuthRequestCallback::ReceivedHttpAuthRequestCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        return value == nullptr || value->IsNull() ? std::optional<std::shared_ptr<HttpAuthResponse>>{} : std::make_shared<HttpAuthResponse>(std::get<flutter::EncodableMap>(*value));
      };
  }

  WebViewChannelDelegate::ReceivedClientCertRequestCallback::ReceivedClientCertRequestCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        return value == nullptr || value->IsNull() ? std::optional<std::shared_ptr<ClientCertResponse>>{} : std::make_shared<ClientCertResponse>(std::get<flutter::EncodableMap>(*value));
      };
  }

  WebViewChannelDelegate::ReceivedServerTrustAuthRequestCallback::ReceivedServerTrustAuthRequestCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        return value == nullptr || value->IsNull() ? std::optional<std::shared_ptr<ServerTrustAuthResponse>>{} : std::make_shared<ServerTrustAuthResponse>(std::get<flutter::EncodableMap>(*value));
      };
  }

  WebViewChannelDelegate::DownloadStartRequestCallback::DownloadStartRequestCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        return value == nullptr || value->IsNull() ? std::optional<std::shared_ptr<DownloadStartResponse>>{} : std::make_shared<DownloadStartResponse>(std::get<flutter::EncodableMap>(*value));
      };
  }

  WebViewChannelDelegate::LaunchingExternalUriSchemeCallback::LaunchingExternalUriSchemeCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        return value == nullptr || value->IsNull() ? std::optional<std::shared_ptr<LaunchingExternalUriSchemeResponse>>{} : std::make_shared<LaunchingExternalUriSchemeResponse>(std::get<flutter::EncodableMap>(*value));
      };
  }

  WebViewChannelDelegate::NotificationReceivedCallback::NotificationReceivedCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        return value == nullptr || value->IsNull() ? std::optional<std::shared_ptr<NotificationReceivedResponse>>{} : std::make_shared<NotificationReceivedResponse>(std::get<flutter::EncodableMap>(*value));
      };
  }

  WebViewChannelDelegate::SaveAsUIShowingCallback::SaveAsUIShowingCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        return value == nullptr || value->IsNull() ? std::optional<std::shared_ptr<SaveAsUIShowingResponse>>{} : std::make_shared<SaveAsUIShowingResponse>(std::get<flutter::EncodableMap>(*value));
      };
  }

  WebViewChannelDelegate::SaveFileSecurityCheckStartingCallback::SaveFileSecurityCheckStartingCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        return value == nullptr || value->IsNull() ? std::optional<std::shared_ptr<SaveFileSecurityCheckStartingResponse>>{} : std::make_shared<SaveFileSecurityCheckStartingResponse>(std::get<flutter::EncodableMap>(*value));
      };
  }

  WebViewChannelDelegate::ScreenCaptureStartingCallback::ScreenCaptureStartingCallback()
  {
    decodeResult = [](const flutter::EncodableValue* value)
      {
        return value == nullptr || value->IsNull() ? std::optional<std::shared_ptr<ScreenCaptureStartingResponse>>{} : std::make_shared<ScreenCaptureStartingResponse>(std::get<flutter::EncodableMap>(*value));
      };
  }

  void WebViewChannelDelegate::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (!webView) {
      result->Success();
      return;
    }

    auto& arguments = std::get<flutter::EncodableMap>(*method_call.arguments());
    auto& methodName = method_call.method_name();

    if (string_equals(methodName, "getUrl")) {
      result->Success(make_fl_value(webView->getUrl()));
    }
    else if (string_equals(methodName, "getTitle")) {
      result->Success(make_fl_value(webView->getTitle()));
    }
    else if (string_equals(methodName, "loadUrl")) {
      auto urlRequest = std::make_unique<URLRequest>(get_fl_map_value<flutter::EncodableMap>(arguments, "urlRequest"));
      webView->loadUrl(std::move(urlRequest));
      result->Success(true);
    }
    else if (string_equals(methodName, "loadFile")) {
      auto assetFilePath = get_fl_map_value<std::string>(arguments, "assetFilePath");
      webView->loadFile(assetFilePath);
      result->Success(true);
    }
    else if (string_equals(methodName, "loadData")) {
      auto data = get_fl_map_value<std::string>(arguments, "data");
      webView->loadData(data);
      result->Success(true);
    }
    else if (string_equals(methodName, "reload")) {
      webView->reload();
      result->Success(true);
    }
    else if (string_equals(methodName, "goBack")) {
      webView->goBack();
      result->Success(true);
    }
    else if (string_equals(methodName, "canGoBack")) {
      result->Success(webView->canGoBack());
    }
    else if (string_equals(methodName, "goForward")) {
      webView->goForward();
      result->Success(true);
    }
    else if (string_equals(methodName, "canGoForward")) {
      result->Success(webView->canGoForward());
    }
    else if (string_equals(methodName, "goBackOrForward")) {
      auto steps = get_fl_map_value<int>(arguments, "steps");
      webView->goBackOrForward(steps);
      result->Success(true);
    }
    else if (string_equals(methodName, "canGoBackOrForward")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));

      auto steps = get_fl_map_value<int>(arguments, "steps");
      webView->canGoBackOrForward(steps, [result_ = std::move(result_)](const bool& value)
        {
          result_->Success(value);
        });
    }
    else if (string_equals(methodName, "isLoading")) {
      result->Success(webView->isLoading());
    }
    else if (string_equals(methodName, "stopLoading")) {
      webView->stopLoading();
      result->Success(true);
    }
    else if (string_equals(methodName, "evaluateJavascript")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));

      auto source = get_fl_map_value<std::string>(arguments, "source");
      auto contentWorldMap = get_optional_fl_map_value<flutter::EncodableMap>(arguments, "contentWorld");
      std::shared_ptr<ContentWorld> contentWorld = contentWorldMap.has_value() ? std::make_shared<ContentWorld>(contentWorldMap.value()) : ContentWorld::page();
      webView->evaluateJavascript(source, std::move(contentWorld), [result_ = std::move(result_)](const std::string& value)
        {
          result_->Success(value);
        });
    }
    else if (string_equals(methodName, "callAsyncJavaScript")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));

      auto functionBody = get_fl_map_value<std::string>(arguments, "functionBody");
      auto argumentsAsJson = get_fl_map_value<std::string>(arguments, "arguments");
      auto contentWorldMap = get_optional_fl_map_value<flutter::EncodableMap>(arguments, "contentWorld");
      std::shared_ptr<ContentWorld> contentWorld = contentWorldMap.has_value() ? std::make_shared<ContentWorld>(contentWorldMap.value()) : ContentWorld::page();
      webView->callAsyncJavaScript(functionBody, argumentsAsJson, std::move(contentWorld), [result_ = std::move(result_)](const std::string& value)
        {
          result_->Success(value);
        });
    }
    else if (string_equals(methodName, "getCopyBackForwardList")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      webView->getCopyBackForwardList([result_ = std::move(result_)](const std::unique_ptr<WebHistory> value)
        {
          result_->Success(value->toEncodableMap());
        });
    }
    else if (string_equals(methodName, "addUserScript")) {
      auto userScript = std::make_unique<UserScript>(get_fl_map_value<flutter::EncodableMap>(arguments, "userScript"));
      webView->addUserScript(std::move(userScript));
      result->Success(true);
    }
    else if (string_equals(methodName, "removeUserScript")) {
      auto index = get_fl_map_value<int>(arguments, "index");
      auto userScript = std::make_unique<UserScript>(get_fl_map_value<flutter::EncodableMap>(arguments, "userScript"));
      webView->removeUserScript(index, std::move(userScript));
      result->Success(true);
    }
    else if (string_equals(methodName, "removeUserScriptsByGroupName")) {
      auto groupName = get_fl_map_value<std::string>(arguments, "groupName");
      webView->removeUserScriptsByGroupName(groupName);
      result->Success(true);
    }
    else if (string_equals(methodName, "removeAllUserScripts")) {
      webView->removeAllUserScripts();
      result->Success(true);
    }
    else if (string_equals(methodName, "addWebMessageListener")) {
      auto listenerValue = get_fl_map_value<flutter::EncodableMap>(arguments, "webMessageListener");
      auto listenerId = get_fl_map_value<std::string>(listenerValue, "id");
      auto jsObjectName = get_fl_map_value<std::string>(listenerValue, "jsObjectName");
      auto allowedOriginRules = get_fl_map_value<std::vector<std::string>>(
        listenerValue, "allowedOriginRules", std::vector<std::string>{});
      if (!jsObjectName.empty() && !listenerId.empty()) {
        webView->addWebMessageListener(jsObjectName, allowedOriginRules, listenerId);
      }
      result->Success(true);
    }
    else if (string_equals(methodName, "createWebMessageChannel")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      webView->createWebMessageChannel([result_ = std::move(result_)](const std::optional<std::string>& channelId)
        {
          if (channelId.has_value()) {
            flutter::EncodableMap map = {
              {make_fl_value("id"), make_fl_value(channelId.value())}
            };
            result_->Success(make_fl_value(map));
          }
          else {
            result_->Success(make_fl_value());
          }
        });
    }
    else if (string_equals(methodName, "postWebMessage")) {
      auto messageValue = get_fl_map_value<flutter::EncodableMap>(arguments, "message");
      auto targetOrigin = get_fl_map_value<std::string>(arguments, "targetOrigin", "*");
      std::string messageData = "";
      int64_t messageType = 0;

      if (fl_map_contains_not_null(messageValue, "type")) {
        messageType = messageValue.at(make_fl_value("type")).LongValue();
      }
      if (fl_map_contains_not_null(messageValue, "data")) {
        const auto& dataValue = messageValue.at(make_fl_value("data"));
        if (std::holds_alternative<std::string>(dataValue)) {
          messageData = std::get<std::string>(dataValue);
        } else if (std::holds_alternative<std::vector<uint8_t>>(dataValue)) {
          const auto& bytes = std::get<std::vector<uint8_t>>(dataValue);
          for (size_t i = 0; i < bytes.size(); i++) {
            if (i > 0) messageData += ",";
            messageData += std::to_string(bytes[i]);
          }
          messageType = 1;
        }
      }

      webView->postWebMessage(messageData, targetOrigin, messageType);
      result->Success(true);
    }
    else if (string_equals(methodName, "takeScreenshot")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      auto screenshotConfigurationMap = get_optional_fl_map_value<flutter::EncodableMap>(arguments, "screenshotConfiguration");
      std::optional<std::unique_ptr<ScreenshotConfiguration>> screenshotConfiguration =
        screenshotConfigurationMap.has_value() ? std::make_unique<ScreenshotConfiguration>(screenshotConfigurationMap.value()) : std::optional<std::unique_ptr<ScreenshotConfiguration>>{};
      webView->takeScreenshot(std::move(screenshotConfiguration), [result_ = std::move(result_)](const std::optional<std::string> data)
        {
          result_->Success(make_fl_value(data));
        });
    }
    else if (string_equals(methodName, "setSettings")) {
      if (webView->inAppBrowser) {
        auto settingsMap = get_fl_map_value<flutter::EncodableMap>(arguments, "settings");
        auto settings = std::make_unique<InAppBrowserSettings>(settingsMap);
        webView->inAppBrowser->setSettings(std::move(settings), settingsMap);
      }
      else {
        auto settingsMap = get_fl_map_value<flutter::EncodableMap>(arguments, "settings");
        auto settings = std::make_unique<InAppWebViewSettings>(settingsMap);
        webView->setSettings(std::move(settings), settingsMap);
      }
      result->Success(true);
    }
    else if (string_equals(methodName, "getSettings")) {
      if (webView->inAppBrowser) {
        result->Success(webView->inAppBrowser->getSettings());
      }
      else {
        result->Success(webView->getSettings());
      }
    }
    else if (string_equals(methodName, "openDevTools")) {
      webView->openDevTools();
      result->Success(true);
    }
    else if (string_equals(methodName, "callDevToolsProtocolMethod")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      auto cdpMethodName = get_fl_map_value<std::string>(arguments, "methodName");
      auto parametersAsJson = get_optional_fl_map_value<std::string>(arguments, "parametersAsJson");
      webView->callDevToolsProtocolMethod(cdpMethodName, parametersAsJson, [result_ = std::move(result_)](const HRESULT& errorCode, const std::optional<std::string>& data)
        {
          if (SUCCEEDED(errorCode)) {
            result_->Success(make_fl_value(data));
          }
          else {
            result_->Error(std::to_string(errorCode), getHRMessage(errorCode));
          }
        });
    }
    else if (string_equals(methodName, "addDevToolsProtocolEventListener")) {
      auto eventName = get_fl_map_value<std::string>(arguments, "eventName");
      webView->addDevToolsProtocolEventListener(eventName);
      result->Success(true);
    }
    else if (string_equals(methodName, "removeDevToolsProtocolEventListener")) {
      auto eventName = get_fl_map_value<std::string>(arguments, "eventName");
      webView->removeDevToolsProtocolEventListener(eventName);
      result->Success(true);
    }
    else if (string_equals(methodName, "pause")) {
      webView->pause();
      result->Success(true);
    }
    else if (string_equals(methodName, "resume")) {
      webView->resume();
      result->Success(true);
    }
    else if (string_equals(methodName, "getCertificate")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      webView->getCertificate([result_ = std::move(result_)](const std::optional<std::unique_ptr<SslCertificate>> data)
        {
          result_->Success(data.has_value() ? data.value()->toEncodableMap() : make_fl_value());
        });
    }
    else if (string_equals(methodName, "clearSslPreferences")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      webView->clearSslPreferences([result_ = std::move(result_)]()
        {
          result_->Success();
        });
    }
    else if (string_equals(methodName, "isInterfaceSupported")) {
      auto interfaceName = get_fl_map_value<std::string>(arguments, "interface");
      result->Success(webView->isInterfaceSupported(interfaceName));
    }
    else if (string_equals(methodName, "getZoomScale")) {
      result->Success(webView->getZoomScale());
    }
    else if (string_equals(methodName, "getProgress")) {
      result->Success(webView->getProgress());
    }
    else if (string_equals(methodName, "getOriginalUrl")) {
      // WebView2 does not distinguish between original and current URL
      result->Success(make_fl_value(webView->getUrl()));
    }
    else if (string_equals(methodName, "getFrameId")) {
      result->Success(make_fl_value(webView->getFrameId()));
    }
    else if (string_equals(methodName, "getMemoryUsageTargetLevel")) {
      result->Success(make_fl_value(webView->getMemoryUsageTargetLevel()));
    }
    else if (string_equals(methodName, "setMemoryUsageTargetLevel")) {
      auto level = get_fl_map_value<int64_t>(arguments, "level");
      webView->setMemoryUsageTargetLevel(level);
      result->Success(true);
    }
    else if (string_equals(methodName, "getFavicon")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      auto url = get_fl_map_value<std::string>(arguments, "url");
      std::optional<std::string> targetUrl = url.empty() ? std::optional<std::string>{} : std::optional<std::string>{ url };
      auto faviconImageFormat = FaviconImageFormatFromInteger(get_optional_fl_map_value<int64_t>(arguments, "faviconImageFormat"));
      webView->getFavicon(targetUrl, faviconImageFormat, [result_ = std::move(result_)](const std::optional<std::vector<uint8_t>> data)
        {
          result_->Success(make_fl_value(data));
        });
    }
    else if (string_equals(methodName, "showSaveAsUI")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      webView->showSaveAsUI([result_ = std::move(result_)](const std::optional<int64_t> value)
        {
          result_->Success(make_fl_value(value));
        });
    }
    else if (string_equals(methodName, "scrollTo")) {
      auto x = get_fl_map_value<int>(arguments, "x");
      auto y = get_fl_map_value<int>(arguments, "y");
      auto animated = get_fl_map_value<bool>(arguments, "animated", false);
      webView->scrollTo(x, y, animated);
      result->Success(true);
    }
    else if (string_equals(methodName, "scrollBy")) {
      auto x = get_fl_map_value<int>(arguments, "x");
      auto y = get_fl_map_value<int>(arguments, "y");
      auto animated = get_fl_map_value<bool>(arguments, "animated", false);
      webView->scrollBy(x, y, animated);
      result->Success(true);
    }
    else if (string_equals(methodName, "getScrollX")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      webView->getScrollX([result_ = std::move(result_)](const std::optional<int64_t> value)
        {
          result_->Success(make_fl_value(value));
        });
    }
    else if (string_equals(methodName, "getScrollY")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      webView->getScrollY([result_ = std::move(result_)](const std::optional<int64_t> value)
        {
          result_->Success(make_fl_value(value));
        });
    }
    else if (string_equals(methodName, "getContentHeight")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      webView->getContentHeight([result_ = std::move(result_)](const std::optional<int64_t> value)
        {
          result_->Success(make_fl_value(value));
        });
    }
    else if (string_equals(methodName, "getContentWidth")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      webView->getContentWidth([result_ = std::move(result_)](const std::optional<int64_t> value)
        {
          result_->Success(make_fl_value(value));
        });
    }
    else if (string_equals(methodName, "isSecureContext")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      webView->isSecureContext([result_ = std::move(result_)](const bool value)
        {
          result_->Success(value);
        });
    }
    else if (string_equals(methodName, "injectCSSCode")) {
      auto source = get_fl_map_value<std::string>(arguments, "source");
      webView->injectCSSCode(source);
      result->Success(true);
    }
    else if (string_equals(methodName, "injectCSSFileFromUrl")) {
      auto urlFile = get_fl_map_value<std::string>(arguments, "urlFile");
      webView->injectCSSFileFromUrl(urlFile);
      result->Success(true);
    }
    else if (string_equals(methodName, "printCurrentPage")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      auto settingsMap = get_optional_fl_map_value<flutter::EncodableMap>(arguments, "settings");
      std::shared_ptr<PrintJobSettings> settings = settingsMap.has_value() 
        ? std::make_shared<PrintJobSettings>(settingsMap.value()) 
        : nullptr;
      webView->printCurrentPage(settings, [result_ = std::move(result_)](const std::optional<std::string>& printJobId)
        {
          result_->Success(make_fl_value(printJobId));
        });
    }
    else if (string_equals(methodName, "createPdf")) {
      auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));
      
      // Parse settings from pdfConfiguration if provided
      std::shared_ptr<PrintJobSettings> settings = nullptr;
      if (fl_map_contains_not_null(arguments, "pdfConfiguration")) {
        auto pdfConfig = get_fl_map_value<flutter::EncodableMap>(arguments, "pdfConfiguration");
        if (fl_map_contains_not_null(pdfConfig, "settings")) {
          auto settingsMap = get_fl_map_value<flutter::EncodableMap>(pdfConfig, "settings");
          settings = std::make_shared<PrintJobSettings>(settingsMap);
        }
      }
      
      webView->createPdf(settings, [result_ = std::move(result_)](const std::optional<std::vector<uint8_t>>& pdfData)
        {
          if (pdfData.has_value()) {
            result_->Success(flutter::EncodableValue(pdfData.value()));
          } else {
            result_->Success(flutter::EncodableValue());
          }
        });
    }
    // for inAppBrowser
    else if (webView->inAppBrowser && string_equals(methodName, "show")) {
      webView->inAppBrowser->show();
      result->Success(true);
    }
    else if (webView->inAppBrowser && string_equals(methodName, "hide")) {
      webView->inAppBrowser->hide();
      result->Success(true);
    }
    else if (webView->inAppBrowser && string_equals(methodName, "close")) {
      webView->inAppBrowser->close();
      result->Success(true);
    }
    else {
      result->NotImplemented();
    }
  }

  void WebViewChannelDelegate::onLoadStart(const std::optional<std::string>& url) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"url", make_fl_value(url)},
      });
    channel->InvokeMethod("onLoadStart", std::move(arguments));
  }

  void WebViewChannelDelegate::onLoadStop(const std::optional<std::string>& url) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"url", make_fl_value(url)},
      });
    channel->InvokeMethod("onLoadStop", std::move(arguments));
  }

  void WebViewChannelDelegate::onContentLoading(const std::optional<std::string>& url) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"url", make_fl_value(url)},
      });
    channel->InvokeMethod("onContentLoading", std::move(arguments));
  }

  void WebViewChannelDelegate::onDOMContentLoaded(const std::optional<std::string>& url) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"url", make_fl_value(url)},
      });
    channel->InvokeMethod("onDOMContentLoaded", std::move(arguments));
  }

  void WebViewChannelDelegate::shouldOverrideUrlLoading(std::shared_ptr<NavigationAction> navigationAction, std::unique_ptr<ShouldOverrideUrlLoadingCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(navigationAction->toEncodableMap());
    channel->InvokeMethod("shouldOverrideUrlLoading", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::onReceivedError(std::shared_ptr<WebResourceRequest> request, std::shared_ptr<WebResourceError> error) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"request", request->toEncodableMap()},
      {"error", error->toEncodableMap()},
      });
    channel->InvokeMethod("onReceivedError", std::move(arguments));
  }

  void WebViewChannelDelegate::onReceivedHttpError(std::shared_ptr<WebResourceRequest> request, std::shared_ptr<WebResourceResponse> errorResponse) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"request", request->toEncodableMap()},
      {"errorResponse", errorResponse->toEncodableMap()},
      });
    channel->InvokeMethod("onReceivedHttpError", std::move(arguments));
  }

  void WebViewChannelDelegate::onTitleChanged(const std::optional<std::string>& title) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"title", make_fl_value(title)}
      });
    channel->InvokeMethod("onTitleChanged", std::move(arguments));

    if (webView && webView->inAppBrowser) {
      webView->inAppBrowser->didChangeTitle(title);
    }
  }

  void WebViewChannelDelegate::onUpdateVisitedHistory(const std::optional<std::string>& url, const std::optional<bool>& isReload) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"url", make_fl_value(url)},
      {"isReload", make_fl_value(isReload)}
      });
    channel->InvokeMethod("onUpdateVisitedHistory", std::move(arguments));
  }

  void WebViewChannelDelegate::onCallJsHandler(const std::string& handlerName, const std::unique_ptr<JavaScriptHandlerFunctionData> data, std::unique_ptr<CallJsHandlerCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"handlerName", handlerName},
      {"data", data->toEncodableMap()}
      });
    channel->InvokeMethod("onCallJsHandler", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::onConsoleMessage(const std::string& message, const int64_t& messageLevel) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"message", message},
      {"messageLevel", messageLevel}
      });
    channel->InvokeMethod("onConsoleMessage", std::move(arguments));
  }

  void WebViewChannelDelegate::onDevToolsProtocolEventReceived(const std::string& eventName, const std::string& data) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"eventName", eventName},
      {"data", data}
      });
    channel->InvokeMethod("onDevToolsProtocolEventReceived", std::move(arguments));
  }

  void WebViewChannelDelegate::onProgressChanged(const int64_t& progress) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"progress", progress}
      });
    channel->InvokeMethod("onProgressChanged", std::move(arguments));
  }

  void WebViewChannelDelegate::onCreateWindow(std::shared_ptr<CreateWindowAction> createWindowAction, std::unique_ptr<CreateWindowCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(createWindowAction->toEncodableMap());
    channel->InvokeMethod("onCreateWindow", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::onCloseWindow() const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>();
    channel->InvokeMethod("onCloseWindow", std::move(arguments));
  }

  void WebViewChannelDelegate::onPermissionRequest(const std::string& origin, const std::vector<int64_t>& resources, std::unique_ptr<PermissionRequestCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"origin", origin},
      {"resources", make_fl_value(resources)}
      });
    channel->InvokeMethod("onPermissionRequest", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::shouldInterceptRequest(std::shared_ptr<WebResourceRequest> request, std::unique_ptr<ShouldInterceptRequestCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(make_fl_value(request->toEncodableMap()));
    channel->InvokeMethod("shouldInterceptRequest", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::onLoadResourceWithCustomScheme(std::shared_ptr<WebResourceRequest> request, std::unique_ptr<LoadResourceWithCustomSchemeCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"request", request->toEncodableMap()},
      });
    channel->InvokeMethod("onLoadResourceWithCustomScheme", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::onReceivedHttpAuthRequest(std::shared_ptr<HttpAuthenticationChallenge> challenge, std::unique_ptr<ReceivedHttpAuthRequestCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(challenge->toEncodableMap());
    channel->InvokeMethod("onReceivedHttpAuthRequest", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::onReceivedClientCertRequest(std::shared_ptr<ClientCertChallenge> challenge, std::unique_ptr<ReceivedClientCertRequestCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(challenge->toEncodableMap());
    channel->InvokeMethod("onReceivedClientCertRequest", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::onReceivedServerTrustAuthRequest(std::shared_ptr<ServerTrustChallenge> challenge, std::unique_ptr<ReceivedServerTrustAuthRequestCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(challenge->toEncodableMap());
    channel->InvokeMethod("onReceivedServerTrustAuthRequest", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::onRenderProcessGone(const std::shared_ptr<RenderProcessGoneDetail> detail) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(detail->toEncodableMap());
    channel->InvokeMethod("onRenderProcessGone", std::move(arguments));
  }

  void WebViewChannelDelegate::onRenderProcessUnresponsive(const std::optional<std::string>& url) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"url", make_fl_value(url)},
      });
    channel->InvokeMethod("onRenderProcessUnresponsive", std::move(arguments));
  }
  void WebViewChannelDelegate::onWebContentProcessDidTerminate() const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>();
    channel->InvokeMethod("onWebContentProcessDidTerminate", std::move(arguments));
  }

  void WebViewChannelDelegate::onProcessFailed(const std::shared_ptr<ProcessFailedDetail> detail) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(detail->toEncodableMap());
    channel->InvokeMethod("onProcessFailed", std::move(arguments));
  }

  void WebViewChannelDelegate::onDownloadStarting(std::shared_ptr<DownloadStartRequest> request, std::unique_ptr<DownloadStartRequestCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(request->toEncodableMap());
    channel->InvokeMethod("onDownloadStarting", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::onAcceleratorKeyPressed(std::shared_ptr<AcceleratorKeyPressedDetail> detail) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(detail->toEncodableMap());
    channel->InvokeMethod("onAcceleratorKeyPressed", std::move(arguments));
  }

  void WebViewChannelDelegate::onZoomScaleChanged(const double& oldScale, const double& newScale) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{
      {"oldScale", make_fl_value(oldScale)},
      {"newScale", make_fl_value(newScale)},
      });
    channel->InvokeMethod("onZoomScaleChanged", std::move(arguments));
  }

  void WebViewChannelDelegate::onEnterFullscreen() const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{});
    channel->InvokeMethod("onEnterFullscreen", std::move(arguments));
  }

  void WebViewChannelDelegate::onExitFullscreen() const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(flutter::EncodableMap{});
    channel->InvokeMethod("onExitFullscreen", std::move(arguments));
  }

  void WebViewChannelDelegate::onFaviconChanged(std::shared_ptr<FaviconChangedRequest> request) const
  {
    if (!channel) {
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(request->toEncodableMap());
    channel->InvokeMethod("onFaviconChanged", std::move(arguments));
  }

  void WebViewChannelDelegate::onLaunchingExternalUriScheme(std::shared_ptr<LaunchingExternalUriSchemeRequest> request, std::unique_ptr<LaunchingExternalUriSchemeCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(request->toEncodableMap());
    channel->InvokeMethod("onLaunchingExternalUriScheme", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::onNotificationReceived(std::shared_ptr<NotificationReceivedRequest> request, std::unique_ptr<NotificationReceivedCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(request->toEncodableMap());
    channel->InvokeMethod("onNotificationReceived", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::onSaveAsUIShowing(std::shared_ptr<SaveAsUIShowingRequest> request, std::unique_ptr<SaveAsUIShowingCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(request->toEncodableMap());
    channel->InvokeMethod("onSaveAsUIShowing", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::onSaveFileSecurityCheckStarting(std::shared_ptr<SaveFileSecurityCheckStartingRequest> request, std::unique_ptr<SaveFileSecurityCheckStartingCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(request->toEncodableMap());
    channel->InvokeMethod("onSaveFileSecurityCheckStarting", std::move(arguments), std::move(callback));
  }

  void WebViewChannelDelegate::onScreenCaptureStarting(std::shared_ptr<ScreenCaptureStartingRequest> request, std::unique_ptr<ScreenCaptureStartingCallback> callback) const
  {
    if (!channel) {
      callback->defaultBehaviour(std::nullopt);
      return;
    }

    auto arguments = std::make_unique<flutter::EncodableValue>(request->toEncodableMap());
    channel->InvokeMethod("onScreenCaptureStarting", std::move(arguments), std::move(callback));
  }

  WebViewChannelDelegate::~WebViewChannelDelegate()
  {
    debugLog("dealloc WebViewChannelDelegate");
    webView = nullptr;
  }
}