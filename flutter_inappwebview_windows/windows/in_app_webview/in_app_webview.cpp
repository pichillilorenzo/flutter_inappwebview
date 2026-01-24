#include <cstring>
#include <filesystem>
#include <nlohmann/json.hpp>
#include <limits>
#include <regex>
#include <set>
#include <Shlwapi.h>
#include <flutter/encodable_value.h>
#include <wil/wrl.h>
#include <winrt/Windows.Foundation.h>

#include "../custom_platform_view/util/composition.desktop.interop.h"
#include "../plugin_scripts_js/javascript_bridge_js.h"
#include "../plugin_scripts_js/web_message_channel_js.h"
#include "../plugin_scripts_js/web_message_listener_js.h"
#include "../types/client_cert_response.h"
#include "../types/create_window_action.h"
#include "../types/favicon_changed_request.h"
#include "../types/favicon_image_format.h"
#include "../types/http_auth_response.h"
#include "../types/javascript_handler_function_data.h"
#include "../types/launching_external_uri_scheme_request.h"
#include "../types/launching_external_uri_scheme_response.h"
#include "../types/text_direction_kind.h"
#include "../types/notification_received_request.h"
#include "../types/notification_received_response.h"
#include "../types/save_as_kind.h"
#include "../types/save_as_ui_showing_request.h"
#include "../types/save_as_ui_showing_response.h"
#include "../types/save_file_security_check_starting_request.h"
#include "../types/save_file_security_check_starting_response.h"
#include "../types/screen_capture_starting_request.h"
#include "../types/screen_capture_starting_response.h"
#include "../types/server_trust_auth_response.h"
#include "../types/ssl_error.h"
#include "../types/url_credential.h"
#include "../types/web_notification.h"
#include "../types/web_resource_error.h"
#include "../types/web_resource_request.h"
#include "../utils/base64.h"
#include "../utils/log.h"
#include "../utils/map.h"
#include "../utils/strconv.h"
#include "../utils/string.h"
#include "../utils/uri.h"
#include "../utils/util.h"
#include "../utils/flutter.h"
#include "../web_notification/web_notification_controller.h"
#include "../print_job/print_job_controller.h"
#include "../print_job/print_job_manager.h"
#include "in_app_webview.h"
#include "in_app_webview_manager.h"

namespace flutter_inappwebview_plugin
{
  using namespace Microsoft::WRL;

  InAppWebView::InAppWebView(const FlutterInappwebviewWindowsPlugin* plugin, const InAppWebViewCreationParams& params, const HWND parentWindow, wil::com_ptr<ICoreWebView2Environment> webViewEnv,
    wil::com_ptr<ICoreWebView2Controller> webViewController,
    wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController)
    : plugin(plugin), id(params.id),
    webViewEnv(std::move(webViewEnv)), webViewController(std::move(webViewController)), webViewCompositionController(std::move(webViewCompositionController)),
    settings(params.initialSettings), userContentController(std::make_unique<UserContentController>(this))
  {
    if (failedAndLog(this->webViewController->get_CoreWebView2(webView.put()))) {
      std::cerr << "Cannot create CoreWebView2." << std::endl;
    }

    if (this->webViewCompositionController) {
      if (!createSurface(parentWindow, plugin->inAppWebViewManager->compositor())) {
        std::cerr << "Cannot create InAppWebView surface." << std::endl;
      }
      registerSurfaceEventHandlers();
    }
    else {
      this->webViewController->put_IsVisible(true);
      // Resize WebView to fit the bounds of the parent window
      RECT bounds;
      GetClientRect(parentWindow, &bounds);
      this->webViewController->put_Bounds(bounds);
    }

    prepare(params);
  }

  InAppWebView::InAppWebView(InAppBrowser* inAppBrowser, const FlutterInappwebviewWindowsPlugin* plugin, const InAppWebViewCreationParams& params, const HWND parentWindow, wil::com_ptr<ICoreWebView2Environment> webViewEnv,
    wil::com_ptr<ICoreWebView2Controller> webViewController,
    wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController)
    : InAppWebView(plugin, params, parentWindow, std::move(webViewEnv), std::move(webViewController), std::move(webViewCompositionController))
  {
    this->inAppBrowser = inAppBrowser;
  }

  void InAppWebView::createInAppWebViewEnv(const HWND parentWindow, const bool& willBeSurface, WebViewEnvironment* webViewEnvironment, const std::shared_ptr<InAppWebViewSettings> initialSettings, std::function<void(wil::com_ptr<ICoreWebView2Environment> webViewEnv,
    wil::com_ptr<ICoreWebView2Controller> webViewController,
    wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController)> completionHandler)
  {
    auto callback = [parentWindow, willBeSurface, completionHandler, initialSettings](HRESULT result, wil::com_ptr<ICoreWebView2Environment> env) -> HRESULT
      {
        if (failedAndLog(result) || !env) {
          completionHandler(nullptr, nullptr, nullptr);
          return E_FAIL;
        }

        wil::com_ptr<ICoreWebView2Environment3> webViewEnv3;
        wil::com_ptr<ICoreWebView2Environment10> webViewEnv10;
        wil::com_ptr<ICoreWebView2ControllerOptions> options;
        if (initialSettings && succeededOrLog(env->QueryInterface(IID_PPV_ARGS(&webViewEnv10))) && succeededOrLog(webViewEnv10->CreateCoreWebView2ControllerOptions(&options))) {
          options->put_IsInPrivateModeEnabled(initialSettings->incognito);
        }
        else {
          webViewEnv10 = nullptr;
          options = nullptr;
          failedLog(env->QueryInterface(IID_PPV_ARGS(&webViewEnv3)));
        }
        if (willBeSurface && (webViewEnv10 || webViewEnv3)) {
          if (webViewEnv10 && options) {
            failedLog(webViewEnv10->CreateCoreWebView2CompositionControllerWithOptions(parentWindow, options.get(), Callback<ICoreWebView2CreateCoreWebView2CompositionControllerCompletedHandler>(
              [completionHandler, env](HRESULT result, wil::com_ptr<ICoreWebView2CompositionController> compositionController) -> HRESULT
              {
                wil::com_ptr<ICoreWebView2Controller3> webViewController = compositionController.try_query<ICoreWebView2Controller3>();

                if (failedAndLog(result) || !webViewController) {
                  completionHandler(nullptr, nullptr, nullptr);
                  return E_FAIL;
                }

                ICoreWebView2Controller3* webViewController3;
                if (succeededOrLog(webViewController->QueryInterface(IID_PPV_ARGS(&webViewController3)))) {
                  webViewController3->put_BoundsMode(COREWEBVIEW2_BOUNDS_MODE_USE_RAW_PIXELS);
                  webViewController3->put_ShouldDetectMonitorScaleChanges(FALSE);
                  webViewController3->put_RasterizationScale(1.0);
                }

                completionHandler(std::move(env), std::move(webViewController), std::move(compositionController));
                return S_OK;
              }
            ).Get()));
          }
          else {
            failedLog(webViewEnv3->CreateCoreWebView2CompositionController(parentWindow, Callback<ICoreWebView2CreateCoreWebView2CompositionControllerCompletedHandler>(
              [completionHandler, env](HRESULT result, wil::com_ptr<ICoreWebView2CompositionController> compositionController) -> HRESULT
              {
                wil::com_ptr<ICoreWebView2Controller3> webViewController = compositionController.try_query<ICoreWebView2Controller3>();

                if (failedAndLog(result) || !webViewController) {
                  completionHandler(nullptr, nullptr, nullptr);
                  return E_FAIL;
                }

                ICoreWebView2Controller3* webViewController3;
                if (succeededOrLog(webViewController->QueryInterface(IID_PPV_ARGS(&webViewController3)))) {
                  webViewController3->put_BoundsMode(COREWEBVIEW2_BOUNDS_MODE_USE_RAW_PIXELS);
                  webViewController3->put_ShouldDetectMonitorScaleChanges(FALSE);
                  webViewController3->put_RasterizationScale(1.0);
                }

                completionHandler(std::move(env), std::move(webViewController), std::move(compositionController));
                return S_OK;
              }
            ).Get()));
          }
        }
        else {
          if (webViewEnv10 && options) {
            failedLog(webViewEnv10->CreateCoreWebView2ControllerWithOptions(parentWindow, options.get(), Callback<ICoreWebView2CreateCoreWebView2ControllerCompletedHandler>(
              [completionHandler, env](HRESULT result, wil::com_ptr<ICoreWebView2Controller> controller) -> HRESULT
              {
                if (failedAndLog(result) || !controller) {
                  completionHandler(nullptr, nullptr, nullptr);
                  return E_FAIL;
                }

                completionHandler(std::move(env), std::move(controller), nullptr);
                return S_OK;
              }).Get()));
          }
          else {
            failedLog(env->CreateCoreWebView2Controller(parentWindow, Callback<ICoreWebView2CreateCoreWebView2ControllerCompletedHandler>(
              [completionHandler, env](HRESULT result, wil::com_ptr<ICoreWebView2Controller> controller) -> HRESULT
              {
                if (failedAndLog(result) || !controller) {
                  completionHandler(nullptr, nullptr, nullptr);
                  return E_FAIL;
                }

                completionHandler(std::move(env), std::move(controller), nullptr);
                return S_OK;
              }).Get()));
          }
        }
        return S_OK;
      };

    HRESULT hr;
    if (webViewEnvironment && webViewEnvironment->getEnvironment()) {
      hr = callback(S_OK, webViewEnvironment->getEnvironment());
    }
    else {
      hr = CreateCoreWebView2EnvironmentWithOptions(
        nullptr, nullptr, nullptr,
        Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>(callback).Get());
    }

    if (failedAndLog(hr)) {
      completionHandler(nullptr, nullptr, nullptr);
    }
  }

  void InAppWebView::initChannel(const std::optional<std::variant<std::string, int64_t>> viewId, const std::optional<std::string> channelName)
  {
    if (viewId.has_value()) {
      id = viewId.value();
    }
    channelDelegate = channelName.has_value() ? std::make_unique<WebViewChannelDelegate>(this, plugin->registrar->messenger(), channelName.value()) :
      std::make_unique<WebViewChannelDelegate>(this, plugin->registrar->messenger());
    findInteractionController = std::make_unique<FindInteractionController>(this, plugin->registrar->messenger());
    printJobManager = std::make_unique<PrintJobManager>(this, plugin->registrar->messenger());
  }

  void InAppWebView::prepare(const InAppWebViewCreationParams& params)
  {
    if (!webView) {
      return;
    }

    javaScriptBridgeEnabled = settings->javaScriptBridgeEnabled;

    wil::com_ptr<ICoreWebView2Settings> webView2Settings;
    auto hrWebView2Settings = webView->get_Settings(&webView2Settings);
    if (succeededOrLog(hrWebView2Settings)) {
      webView2Settings->put_IsScriptEnabled(settings->javaScriptEnabled);
      webView2Settings->put_IsZoomControlEnabled(settings->supportZoom);
      webView2Settings->put_AreDevToolsEnabled(settings->isInspectable);
      webView2Settings->put_AreDefaultContextMenusEnabled(!settings->disableContextMenu);
      webView2Settings->put_IsBuiltInErrorPageEnabled(!settings->disableDefaultErrorPage);
      webView2Settings->put_IsStatusBarEnabled(settings->statusBarEnabled);

      if (auto webView2Settings2 = webView2Settings.try_query<ICoreWebView2Settings2>()) {
        if (!settings->userAgent.empty()) {
          webView2Settings2->put_UserAgent(utf8_to_wide(settings->userAgent).c_str());
        }
      }

      if (auto webView2Settings3 = webView2Settings.try_query<ICoreWebView2Settings3>()) {
        webView2Settings3->put_AreBrowserAcceleratorKeysEnabled(settings->browserAcceleratorKeysEnabled);
      }

      if (auto webView2Settings4 = webView2Settings.try_query<ICoreWebView2Settings4>()) {
        webView2Settings4->put_IsGeneralAutofillEnabled(settings->generalAutofillEnabled);
        webView2Settings4->put_IsPasswordAutosaveEnabled(settings->passwordAutosaveEnabled);
      }

      if (auto webView2Settings5 = webView2Settings.try_query<ICoreWebView2Settings5>()) {
        webView2Settings5->put_IsPinchZoomEnabled(settings->pinchZoomEnabled);
      }

      if (auto webView2Settings6 = webView2Settings.try_query<ICoreWebView2Settings6>()) {
        webView2Settings6->put_IsSwipeNavigationEnabled(settings->allowsBackForwardNavigationGestures);
      }

      if (auto webView2Settings7 = webView2Settings.try_query<ICoreWebView2Settings7>()) {
        webView2Settings7->put_HiddenPdfToolbarItems((COREWEBVIEW2_PDF_TOOLBAR_ITEMS)settings->hiddenPdfToolbarItems);
      }

      if (auto webView2Settings8 = webView2Settings.try_query<ICoreWebView2Settings8>()) {
        webView2Settings8->put_IsReputationCheckingRequired(settings->reputationCheckingRequired);
      }

      if (auto webView2Settings9 = webView2Settings.try_query<ICoreWebView2Settings9>()) {
        webView2Settings9->put_IsNonClientRegionSupportEnabled(settings->nonClientRegionSupportEnabled);
      }
    }

    if (auto webViewController2 = webViewController.try_query<ICoreWebView2Controller2>()) {
      if (settings->transparentBackground) {
        webViewController2->put_DefaultBackgroundColor({ 0, 255, 255, 255 });
      }
    }

    // required to make Runtime events work
    failedLog(webView->CallDevToolsProtocolMethod(L"Runtime.enable", L"{}", Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
      [this](HRESULT errorCode, LPCWSTR returnObjectAsJson)
      {
        failedLog(errorCode);
        return S_OK;
      }
    ).Get()));

    // required to make Page events work and to add User Scripts
    failedLog(webView->CallDevToolsProtocolMethod(L"Page.enable", L"{}", Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
      [this](HRESULT errorCode, LPCWSTR returnObjectAsJson)
      {
        failedLog(errorCode);
        return S_OK;
      }
    ).Get()));

    // required to use Network domain
    failedLog(webView->CallDevToolsProtocolMethod(L"Network.enable", L"{}", Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
      [this](HRESULT errorCode, LPCWSTR returnObjectAsJson)
      {
        failedLog(errorCode);
        return S_OK;
      }
    ).Get()));

    // required to use Fetch domain and implement the shouldOverrideUrlLoading event correctly
    failedLog(webView->CallDevToolsProtocolMethod(L"Fetch.enable", L"{\"patterns\": [{\"resourceType\": \"Document\", \"requestStage\": \"Request\"}]}", Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
      [this](HRESULT errorCode, LPCWSTR returnObjectAsJson)
      {
        failedLog(errorCode);
        return S_OK;
      }
    ).Get()));

    failedLog(webView->CallDevToolsProtocolMethod(L"Page.getFrameTree", L"{}", Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
      [this](HRESULT errorCode, LPCWSTR returnObjectAsJson)
      {
        if (succeededOrLog(errorCode)) {
          auto treeJson = nlohmann::json::parse(wide_to_utf8(returnObjectAsJson));
          pageFrameId_ = treeJson["frameTree"]["frame"]["id"].get<std::string>();
        }
        return S_OK;
      }
    ).Get()));

    if (userContentController) {
      if (javaScriptBridgeEnabled) {
        auto pluginScriptsOriginAllowList = settings->pluginScriptsOriginAllowList;
        auto pluginScriptsForMainFrameOnly = settings->pluginScriptsForMainFrameOnly;

        auto javaScriptBridgeOriginAllowList = settings->javaScriptBridgeOriginAllowList.has_value() ? settings->javaScriptBridgeOriginAllowList : pluginScriptsOriginAllowList;
        auto javaScriptBridgeForMainFrameOnly = settings->javaScriptBridgeForMainFrameOnly.has_value() ? settings->javaScriptBridgeForMainFrameOnly.value() : pluginScriptsForMainFrameOnly;
        userContentController->addPluginScript(std::move(JavaScriptBridgeJS::JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT(expectedBridgeSecret, javaScriptBridgeOriginAllowList, javaScriptBridgeForMainFrameOnly)));
      }

      if (params.initialUserScripts.has_value()) {
        userContentController->addUserOnlyScripts(params.initialUserScripts.value());
      }
    }

    registerEventHandlers();
  }

  void InAppWebView::registerEventHandlers()
  {
    if (!webView || !webViewController) {
      return;
    }

    auto add_AcceleratorKeyPressed_HResult = webViewController->add_AcceleratorKeyPressed(
      Callback<ICoreWebView2AcceleratorKeyPressedEventHandler>(
        [this](ICoreWebView2Controller* sender, ICoreWebView2AcceleratorKeyPressedEventArgs* args)
        {
          if (channelDelegate) {
            auto handled = settings->handleAcceleratorKeyPressed;
            args->put_Handled(handled);
            if (handled) {
              auto detail = AcceleratorKeyPressedDetail::fromICoreWebView2AcceleratorKeyPressedEventArgs(args);
              channelDelegate->onAcceleratorKeyPressed(std::move(detail));
            }
          }
          return S_OK;
        }
      ).Get(), nullptr);
    failedLog(add_AcceleratorKeyPressed_HResult);

    auto add_ZoomFactorChanged_HResult = webViewController->add_ZoomFactorChanged(
      Callback<ICoreWebView2ZoomFactorChangedEventHandler>(
        [this](ICoreWebView2Controller* sender, IUnknown* args)
        {
          double newScale;
          if (succeededOrLog(sender->get_ZoomFactor(&newScale))) {
            if (channelDelegate) {
              channelDelegate->onZoomScaleChanged(zoomScaleFactor_, newScale);
            }
            zoomScaleFactor_ = newScale;
          }
          return S_OK;
        }
      ).Get(), nullptr);
    failedLog(add_ZoomFactorChanged_HResult);

    wil::com_ptr<ICoreWebView2DevToolsProtocolEventReceiver> fetchRequestPausedEventReceiver;
    if (succeededOrLog(webView->GetDevToolsProtocolEventReceiver(L"Fetch.requestPaused", &fetchRequestPausedEventReceiver))) {
      auto add_DevToolsProtocolEventReceived_HResult = fetchRequestPausedEventReceiver->add_DevToolsProtocolEventReceived(
        Callback<ICoreWebView2DevToolsProtocolEventReceivedEventHandler>(
          [this](
            ICoreWebView2* sender,
            ICoreWebView2DevToolsProtocolEventReceivedEventArgs* args) -> HRESULT
          {
            wil::unique_cotaskmem_string json;
            if (succeededOrLog(args->get_ParameterObjectAsJson(&json))) {
              auto requestPausedData = nlohmann::json::parse(wide_to_utf8(json.get()));

              auto requestId = requestPausedData.at("requestId").get<std::string>();
              auto resourceType = requestPausedData.at("resourceType").get<std::string>();
              auto isResponseStage = requestPausedData.contains("responseStatusCode");
              auto frameId = requestPausedData.at("frameId").get<std::string>();

              auto request = requestPausedData.at("request").get<nlohmann::json>();
              std::optional<std::string> url = request.at("url").is_string() ? request.at("url").get<std::string>() : std::optional<std::string>{};
              std::optional<std::string> urlFragment = request.contains("urlFragment") && request.at("urlFragment").is_string() ? request.at("urlFragment").get<std::string>() : std::optional<std::string>{};
              if (url.has_value() && urlFragment.has_value()) {
                url = url.value() + urlFragment.value();
              }
              auto isForMainFrame = pageFrameId_.empty() || string_equals(pageFrameId_, frameId);

              auto allowRequest = [this, requestId, url, isForMainFrame]()
                {
                  failedAndLog(webView->CallDevToolsProtocolMethod(L"Fetch.continueRequest",
                    utf8_to_wide("{\"requestId\":\"" + requestId + "\"}").c_str(),
                    Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
                      [this](HRESULT errorCode, LPCWSTR returnObjectAsJson)
                      {
                        failedLog(errorCode);
                        return S_OK;
                      }
                    ).Get()));

                  if (channelDelegate && isForMainFrame) {
                    // if shouldOverrideUrlLoading is used, then call onLoadStart and onProgressChanged here
                    // to match the behaviour of the other platforms
                    channelDelegate->onLoadStart(url);
                    progress_ = 0;
                    channelDelegate->onProgressChanged(progress_);
                  }
                };

              auto cancelRequest = [this, requestId]()
                {
                  failedAndLog(webView->CallDevToolsProtocolMethod(L"Fetch.failRequest",
                    utf8_to_wide("{\"requestId\":\"" + requestId + "\", \"errorReason\": \"Aborted\"}").c_str(),
                    Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
                      [this](HRESULT errorCode, LPCWSTR returnObjectAsJson)
                      {
                        failedLog(errorCode);
                        return S_OK;
                      }
                    ).Get()));
                };

              if (!isResponseStage && channelDelegate && settings->useShouldOverrideUrlLoading && string_equals(resourceType, "Document")) {
                std::optional<std::string> method = request.at("method").is_string() ? request.at("method").get<std::string>() : std::optional<std::string>{};
                std::optional<std::map<std::string, std::string>> headers = request.at("headers").is_object() ? request.at("headers").get<std::map<std::string, std::string>>() : std::optional<std::map<std::string, std::string>>{};
                std::optional<std::string> redirectedRequestId = request.contains("redirectedRequestId") && request.at("redirectedRequestId").is_string() ? request.at("redirectedRequestId").get<std::string>() : std::optional<std::string>{};

                std::optional<std::vector<uint8_t>> body = std::optional<std::vector<uint8_t>>{};
                auto hasPostData = request.contains("hasPostData") && request.at("hasPostData").is_boolean() && request.at("hasPostData").get<bool>()
                  && request.contains("postDataEntries") && request.at("postDataEntries").is_array();
                if (hasPostData) {
                  auto postDataEntries = request.at("postDataEntries").get<std::vector<nlohmann::json>>();

                  if (postDataEntries.size() > 0) {
                    body = std::vector<uint8_t>{};
                    for (auto const& entry : postDataEntries) {
                      if (entry.contains("bytes")) {
                        try {
                          auto entryData = base64_decode(entry.at("bytes").get<std::string>());
                          std::vector<uint8_t> bytes(entryData.begin(), entryData.end());
                          body->insert(body->end(), bytes.begin(), bytes.end());
                        }
                        catch (const std::exception& err) {
                          debugLog("Error decoding base64 data");
                          debugLog(err.what());
                          body = std::optional<std::vector<uint8_t>>{};
                          break;
                        }
                      }
                    }
                  }
                }

                BOOL isRedirect = redirectedRequestId.has_value() && !redirectedRequestId.value().empty();

                std::optional<NavigationActionType> navigationType = isRedirect ? NavigationActionType::other : std::optional<NavigationActionType>{};

                auto urlRequest = std::make_shared<URLRequest>(url, method, headers, body);
                auto navigationAction = std::make_shared<NavigationAction>(
                  urlRequest,
                  isForMainFrame,
                  isRedirect,
                  navigationType
                );

                auto callback = std::make_unique<WebViewChannelDelegate::ShouldOverrideUrlLoadingCallback>();
                callback->nonNullSuccess = [this, allowRequest, cancelRequest](const NavigationActionPolicy actionPolicy)
                  {
                    if (actionPolicy == NavigationActionPolicy::allow) {
                      allowRequest();
                    }
                    else {
                      cancelRequest();
                    }
                    return false;
                  };
                auto defaultBehaviour = [this, allowRequest](const std::optional<const NavigationActionPolicy> actionPolicy)
                  {
                    allowRequest();
                  };
                callback->defaultBehaviour = defaultBehaviour;
                callback->error = [defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
                  {
                    debugLog(error_code + ", " + error_message);
                    defaultBehaviour(std::nullopt);
                  };
                channelDelegate->shouldOverrideUrlLoading(std::move(navigationAction), std::move(callback));
              }
              else {
                // check if a custom event listener is found and give back the opportunity to it to handle the request
                // through the Chrome Dev Protocol API
                if (!map_contains(devToolsProtocolEventListener_, std::string("Fetch.requestPaused"))) {
                  // if a custom event listener is not found, continue the request
                  allowRequest();
                }
              }
            }

            return S_OK;
          })
        .Get(), nullptr);
      failedAndLog(add_DevToolsProtocolEventReceived_HResult);
    }

    auto add_NavigationStarting_HResult = webView->add_NavigationStarting(
      Callback<ICoreWebView2NavigationStartingEventHandler>(
        [this](ICoreWebView2* sender, ICoreWebView2NavigationStartingEventArgs* args)
        {
          isLoading_ = true;

          if (!channelDelegate) {
            args->put_Cancel(false);
            return S_OK;
          }

          wil::unique_cotaskmem_string uri = nullptr;
          std::optional<std::string> url = SUCCEEDED(args->get_Uri(&uri)) ? wide_to_utf8(uri.get()) : std::optional<std::string>{};

          wil::unique_cotaskmem_string requestMethod = nullptr;
          wil::com_ptr<ICoreWebView2HttpRequestHeaders> requestHeaders = nullptr;
          std::optional<std::map<std::string, std::string>> headers = std::optional<std::map<std::string, std::string>>{};
          if (SUCCEEDED(args->get_RequestHeaders(&requestHeaders))) {
            headers = std::make_optional<std::map<std::string, std::string>>({});
            wil::com_ptr<ICoreWebView2HttpHeadersCollectionIterator> iterator;
            requestHeaders->GetIterator(&iterator);
            BOOL hasCurrent = FALSE;
            while (SUCCEEDED(iterator->get_HasCurrentHeader(&hasCurrent)) && hasCurrent) {
              wil::unique_cotaskmem_string name;
              wil::unique_cotaskmem_string value;

              if (SUCCEEDED(iterator->GetCurrentHeader(&name, &value))) {
                headers->insert({ wide_to_utf8(name.get()), wide_to_utf8(value.get()) });
              }

              BOOL hasNext = FALSE;
              iterator->MoveNext(&hasNext);
            }

            requestHeaders->GetHeader(L"Flutter-InAppWebView-Request-Method", &requestMethod);
            requestHeaders->RemoveHeader(L"Flutter-InAppWebView-Request-Method");
          }

          std::optional<std::string> method = requestMethod ? wide_to_utf8(requestMethod.get()) : std::optional<std::string>{};

          BOOL isUserInitiated;
          if (FAILED(args->get_IsUserInitiated(&isUserInitiated))) {
            isUserInitiated = FALSE;
          }

          BOOL isRedirect;
          if (FAILED(args->get_IsRedirected(&isRedirect))) {
            isRedirect = FALSE;
          }

          std::optional<NavigationActionType> navigationType = std::nullopt;
          wil::com_ptr<ICoreWebView2NavigationStartingEventArgs3> args3;
          if (SUCCEEDED(args->QueryInterface(IID_PPV_ARGS(&args3)))) {
            COREWEBVIEW2_NAVIGATION_KIND navigationKind;
            if (SUCCEEDED(args3->get_NavigationKind(&navigationKind))) {
              switch (navigationKind) {
              case COREWEBVIEW2_NAVIGATION_KIND_RELOAD:
                navigationType = NavigationActionType::reload;
                break;
              case COREWEBVIEW2_NAVIGATION_KIND_BACK_OR_FORWARD:
                navigationType = NavigationActionType::backForward;
                break;
              case COREWEBVIEW2_NAVIGATION_KIND_NEW_DOCUMENT:
                if (isUserInitiated && !isRedirect) {
                  navigationType = NavigationActionType::linkActivated;
                }
                else {
                  navigationType = NavigationActionType::other;
                }
                break;
              default:
                navigationType = NavigationActionType::other;
              }
            }
          }

          auto urlRequest = std::make_shared<URLRequest>(url, method, headers, std::nullopt);
          auto navigationAction = std::make_shared<NavigationAction>(
            urlRequest,
            true,
            isRedirect,
            navigationType
          );

          lastNavigationAction_ = navigationAction;

          UINT64 navigationId;
          if (SUCCEEDED(args->get_NavigationId(&navigationId))) {
            navigationActions_.insert({ navigationId, navigationAction });
          }

          // if shouldOverrideUrlLoading is not used, then call onLoadStart and onProgressChanged here
          if (!settings->useShouldOverrideUrlLoading) {
            channelDelegate->onLoadStart(url);
            progress_ = 0;
            channelDelegate->onProgressChanged(progress_);
          }
          args->put_Cancel(false);

          return S_OK;
        }
      ).Get(), nullptr);
    failedLog(add_NavigationStarting_HResult);

    auto add_ContentLoading_HResult = webView->add_ContentLoading(
      Callback<ICoreWebView2ContentLoadingEventHandler>(
        [this](ICoreWebView2* sender, ICoreWebView2ContentLoadingEventArgs* args)
        {
          if (channelDelegate) {
            wil::unique_cotaskmem_string uri;
            std::optional<std::string> url = SUCCEEDED(webView->get_Source(&uri)) ? wide_to_utf8(uri.get()) : std::optional<std::string>{};
            channelDelegate->onContentLoading(url);
            progress_ = 33;
            channelDelegate->onProgressChanged(progress_);
          }
          return S_OK;
        }
      ).Get(), nullptr);
    failedLog(add_ContentLoading_HResult);

    auto add_NavigationCompleted_HResult = webView->add_NavigationCompleted(
      Callback<ICoreWebView2NavigationCompletedEventHandler>(
        [this](ICoreWebView2* sender, ICoreWebView2NavigationCompletedEventArgs* args)
        {
          isLoading_ = false;
          previousAuthRequestFailureCount = 0;

          evaluateJavascript(JavaScriptBridgeJS::PLATFORM_READY_JS_SOURCE(), ContentWorld::page(), nullptr);

          std::shared_ptr<NavigationAction> navigationAction;
          UINT64 navigationId;
          if (SUCCEEDED(args->get_NavigationId(&navigationId))) {
            navigationAction = map_at_or_null(navigationActions_, navigationId);
            if (navigationAction) {
              navigationActions_.erase(navigationId);
            }
          }

          COREWEBVIEW2_WEB_ERROR_STATUS webErrorType = COREWEBVIEW2_WEB_ERROR_STATUS_UNKNOWN;
          args->get_WebErrorStatus(&webErrorType);

          BOOL isSuccess;
          args->get_IsSuccess(&isSuccess);

          if (channelDelegate) {
            wil::unique_cotaskmem_string uri;
            std::optional<std::string> url = SUCCEEDED(webView->get_Source(&uri)) ? wide_to_utf8(uri.get()) : std::optional<std::string>{};

            progress_ = 100;
            channelDelegate->onProgressChanged(progress_);
            if (isSuccess) {
              channelDelegate->onLoadStop(url);
            }
            else if (!InAppWebView::isSslError(webErrorType) && navigationAction) {
              auto webResourceRequest = std::make_unique<WebResourceRequest>(url, navigationAction->request->method, navigationAction->request->headers, navigationAction->isForMainFrame);
              int httpStatusCode = 0;
              wil::com_ptr<ICoreWebView2NavigationCompletedEventArgs2> args2;
              if (SUCCEEDED(args->QueryInterface(IID_PPV_ARGS(&args2))) && SUCCEEDED(args2->get_HttpStatusCode(&httpStatusCode)) && httpStatusCode >= 400) {
                auto webResourceResponse = std::make_unique<WebResourceResponse>(std::optional<std::string>{},
                  std::optional<std::string>{},
                  httpStatusCode,
                  std::optional<std::string>{},
                  std::optional<std::map<std::string, std::string>>{},
                  std::optional<std::vector<uint8_t>>{});
                channelDelegate->onReceivedHttpError(std::move(webResourceRequest), std::move(webResourceResponse));
              }
              else if (httpStatusCode < 400) {
                auto webResourceError = std::make_unique<WebResourceError>(WebErrorStatusDescription[webErrorType], webErrorType);
                channelDelegate->onReceivedError(std::move(webResourceRequest), std::move(webResourceError));
              }
            }
          }

          return S_OK;
        }
      ).Get(), nullptr);
    failedLog(add_NavigationCompleted_HResult);

    auto add_DocumentTitleChanged_HResult = webView->add_DocumentTitleChanged(Callback<ICoreWebView2DocumentTitleChangedEventHandler>(
      [this](ICoreWebView2* sender, IUnknown* args)
      {
        if (channelDelegate) {
          wil::unique_cotaskmem_string title;
          sender->get_DocumentTitle(&title);
          channelDelegate->onTitleChanged(title.is_valid() ? wide_to_utf8(title.get()) : std::optional<std::string>{});
        }
        return S_OK;
      }
    ).Get(), nullptr);
    failedLog(add_DocumentTitleChanged_HResult);

    auto add_ContainsFullScreenElementChanged_HResult = webView->add_ContainsFullScreenElementChanged(
      Callback<ICoreWebView2ContainsFullScreenElementChangedEventHandler>(
        [this](ICoreWebView2* sender, IUnknown* args)
        {
          if (!channelDelegate) {
            return S_OK;
          }

          BOOL containsFullScreenElement = FALSE;
          if (succeededOrLog(sender->get_ContainsFullScreenElement(&containsFullScreenElement))) {
            if (containsFullScreenElement) {
              channelDelegate->onEnterFullscreen();
            }
            else {
              channelDelegate->onExitFullscreen();
            }
          }
          return S_OK;
        }
      ).Get(), nullptr);
    failedLog(add_ContainsFullScreenElementChanged_HResult);

    auto add_HistoryChanged_HResult = webView->add_HistoryChanged(Callback<ICoreWebView2HistoryChangedEventHandler>(
      [this](ICoreWebView2* sender, IUnknown* args)
      {
        if (channelDelegate) {
          std::optional<bool> isReload = std::nullopt;
          if (lastNavigationAction_ && lastNavigationAction_->navigationType.has_value()) {
            isReload = lastNavigationAction_->navigationType.value() == NavigationActionType::reload;
          }
          channelDelegate->onUpdateVisitedHistory(getUrl(), isReload);
        }
        return S_OK;
      }
    ).Get(), nullptr);
    failedLog(add_HistoryChanged_HResult);

    auto add_WebMessageReceived_HResult = webView->add_WebMessageReceived(Callback<ICoreWebView2WebMessageReceivedEventHandler>(
      [this](ICoreWebView2* sender, ICoreWebView2WebMessageReceivedEventArgs* args)
      {
        return this->onCallJsHandler(true, args);
      }
    ).Get(), nullptr);
    failedLog(add_WebMessageReceived_HResult);

    wil::com_ptr<ICoreWebView2DevToolsProtocolEventReceiver> consoleMessageReceiver;
    if (succeededOrLog(webView->GetDevToolsProtocolEventReceiver(L"Runtime.consoleAPICalled", &consoleMessageReceiver))) {
      auto consoleMessageReceiver_add_DevToolsProtocolEventReceived_HResult = consoleMessageReceiver->add_DevToolsProtocolEventReceived(
        Callback<ICoreWebView2DevToolsProtocolEventReceivedEventHandler>(
          [this](
            ICoreWebView2* sender,
            ICoreWebView2DevToolsProtocolEventReceivedEventArgs* args) -> HRESULT
          {

            if (!channelDelegate) {
              return S_OK;
            }

            wil::unique_cotaskmem_string json;
            if (succeededOrLog(args->get_ParameterObjectAsJson(&json))) {
              auto consoleMessageJson = nlohmann::json::parse(wide_to_utf8(json.get()));

              auto level = consoleMessageJson.at("type").get<std::string>();
              int64_t messageLevel = 1;
              if (string_equals(level, "log")) {
                messageLevel = 1;
              }
              else if (string_equals(level, "debug")) {
                messageLevel = 0;
              }
              else if (string_equals(level, "error")) {
                messageLevel = 3;
              }
              else if (string_equals(level, "info")) {
                messageLevel = 1;
              }
              else if (string_equals(level, "warn")) {
                messageLevel = 2;
              }

              auto consoleArgs = consoleMessageJson.at("args").get<std::vector<nlohmann::json>>();
              auto message = join(functional_map(consoleArgs, [](const nlohmann::json& json) { return json.contains("value") ? json.at("value").dump() : (json.contains("description") ? json.at("description").dump() : json.dump()); }), std::string{ " " });
              channelDelegate->onConsoleMessage(message, messageLevel);
            }

            return S_OK;
          })
        .Get(), nullptr);
      failedLog(consoleMessageReceiver_add_DevToolsProtocolEventReceived_HResult);
    }

    auto add_NewWindowRequested_HResult = webView->add_NewWindowRequested(
      Callback<ICoreWebView2NewWindowRequestedEventHandler>(
        [this](ICoreWebView2* sender, ICoreWebView2NewWindowRequestedEventArgs* args)
        {
          wil::com_ptr<ICoreWebView2Deferral> deferral;
          if (channelDelegate && plugin && plugin->inAppWebViewManager && succeededOrLog(args->GetDeferral(&deferral))) {
            plugin->inAppWebViewManager->windowAutoincrementId++;
            int64_t windowId = plugin->inAppWebViewManager->windowAutoincrementId;
            auto newWindowRequestedArgs = std::make_unique<NewWindowRequestedArgs>(args, deferral);
            plugin->inAppWebViewManager->windowWebViews.insert({ windowId, std::move(newWindowRequestedArgs) });

            wil::unique_cotaskmem_string uri = nullptr;
            std::optional<std::string> url = SUCCEEDED(args->get_Uri(&uri)) ? wide_to_utf8(uri.get()) : std::optional<std::string>{};

            BOOL hasGesture;
            if (FAILED(args->get_IsUserInitiated(&hasGesture))) {
              hasGesture = FALSE;
            }

            wil::com_ptr<ICoreWebView2WindowFeatures> webviewWindowFeatures;
            std::optional<std::unique_ptr<WindowFeatures>> windowFeatures;
            if (SUCCEEDED(args->get_WindowFeatures(&webviewWindowFeatures))) {
              windowFeatures = std::make_unique<WindowFeatures>(webviewWindowFeatures);
            }

            auto urlRequest = std::make_shared<URLRequest>(url, "GET", std::nullopt, std::nullopt);
            auto createWindowAction = std::make_shared<CreateWindowAction>(
              urlRequest,
              windowId,
              true,
              hasGesture,
              std::move(windowFeatures));

            auto callback = std::make_unique<WebViewChannelDelegate::CreateWindowCallback>();
            auto defaultBehaviour = [this, windowId, urlRequest, deferral, args](const std::optional<const bool> handledByClient)
              {
                if (plugin && plugin->inAppWebViewManager && map_contains(plugin->inAppWebViewManager->windowWebViews, windowId)) {
                  plugin->inAppWebViewManager->windowWebViews.erase(windowId);
                }
                loadUrl(urlRequest);
                failedLog(args->put_Handled(TRUE));
                failedLog(deferral->Complete());
              };
            callback->nonNullSuccess = [this, deferral, args](const bool handledByClient)
              {
                return !handledByClient;
              };
            callback->defaultBehaviour = defaultBehaviour;
            callback->error = [this, defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
              {
                debugLog(error_code + ", " + error_message);
                defaultBehaviour(std::nullopt);
              };
            channelDelegate->onCreateWindow(std::move(createWindowAction), std::move(callback));
          }
          return S_OK;
        }
      ).Get(), nullptr);
    failedLog(add_NewWindowRequested_HResult);

    auto add_WindowCloseRequested_HResult = webView->add_WindowCloseRequested(Callback<ICoreWebView2WindowCloseRequestedEventHandler>(
      [this](ICoreWebView2* sender, IUnknown* args)
      {
        if (channelDelegate) {
          channelDelegate->onCloseWindow();
        }
        return S_OK;
      }
    ).Get(), nullptr);
    failedLog(add_WindowCloseRequested_HResult);

    auto add_PermissionRequested_HResult = webView->add_PermissionRequested(Callback<ICoreWebView2PermissionRequestedEventHandler>(
      [this](ICoreWebView2* sender, ICoreWebView2PermissionRequestedEventArgs* args)
      {
        wil::com_ptr<ICoreWebView2Deferral> deferral;
        if (channelDelegate && succeededOrLog(args->GetDeferral(&deferral))) {
          wil::unique_cotaskmem_string uri;
          std::string url = SUCCEEDED(args->get_Uri(&uri)) ? wide_to_utf8(uri.get()) : "";

          COREWEBVIEW2_PERMISSION_KIND resource = COREWEBVIEW2_PERMISSION_KIND_UNKNOWN_PERMISSION;
          failedLog(args->get_PermissionKind(&resource));

          auto callback = std::make_unique<WebViewChannelDelegate::PermissionRequestCallback>();
          auto defaultBehaviour = [this, deferral, args](const std::optional<const std::shared_ptr<PermissionResponse>> permissionResponse)
            {
              failedLog(args->put_State(COREWEBVIEW2_PERMISSION_STATE_DENY));
              failedLog(deferral->Complete());
            };
          callback->nonNullSuccess = [this, deferral, args](const std::shared_ptr<PermissionResponse> permissionResponse)
            {
              auto action = permissionResponse->action;
              if (action.has_value()) {
                switch (action.value()) {
                case PermissionResponseActionType::grant:
                  failedLog(args->put_State(COREWEBVIEW2_PERMISSION_STATE_ALLOW));
                  break;
                case PermissionResponseActionType::prompt:
                  failedLog(args->put_State(COREWEBVIEW2_PERMISSION_STATE_DEFAULT));
                  break;
                default:
                  failedLog(args->put_State(COREWEBVIEW2_PERMISSION_STATE_DENY));
                  break;
                }
                failedLog(deferral->Complete());
                return false;
              }
              return true;
            };
          callback->defaultBehaviour = defaultBehaviour;
          callback->error = [this, defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
            {
              debugLog(error_code + ", " + error_message);
              defaultBehaviour(std::nullopt);
            };
          channelDelegate->onPermissionRequest(url, { resource }, std::move(callback));
        }
        return S_OK;
      }
    ).Get(), nullptr);
    failedLog(add_PermissionRequested_HResult);

    if (auto webView22 = webView.try_query<ICoreWebView2_22>()) {
      failedLog(webView22->AddWebResourceRequestedFilterWithRequestSourceKinds(
        L"*",
        COREWEBVIEW2_WEB_RESOURCE_CONTEXT_ALL,
        COREWEBVIEW2_WEB_RESOURCE_REQUEST_SOURCE_KINDS_ALL));
    }
    else {
      failedLog(webView->AddWebResourceRequestedFilter(L"*", COREWEBVIEW2_WEB_RESOURCE_CONTEXT_ALL));
    }
    auto add_WebResourceRequested_HResult = webView->add_WebResourceRequested(
      Callback<ICoreWebView2WebResourceRequestedEventHandler>(
        [this](
          ICoreWebView2* sender, ICoreWebView2WebResourceRequestedEventArgs* args)
        {
          wil::com_ptr<ICoreWebView2Deferral> deferral;
          wil::com_ptr<ICoreWebView2WebResourceRequest> webResourceRequest;
          if (channelDelegate && succeededOrLog(args->get_Request(&webResourceRequest)) && succeededOrLog(args->GetDeferral(&deferral))) {
            auto request = std::make_shared<WebResourceRequest>(webResourceRequest);

            // The add_WebResourceRequested event is by default raised for file, http, and https URI schemes.
            // This is also raised for registered custom URI schemes.
            // https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.2792.45#add_webresourcerequested
            auto url = request->url.has_value() ? request->url.value() : "";
            auto isCustomScheme = !url.empty() && !starts_with(url, std::string{ "file://" }) && !starts_with(url, std::string{ "http://" }) && !starts_with(url, std::string{ "https://" });

            auto onLoadResourceWithCustomSchemeCallback = [this, deferral, request, args]()
              {
                if (channelDelegate) {
                  auto callback = std::make_unique<WebViewChannelDelegate::LoadResourceWithCustomSchemeCallback>();
                  auto defaultBehaviour = [this, deferral, args](const std::optional<std::shared_ptr<CustomSchemeResponse>> response)
                    {
                      failedLog(deferral->Complete());
                    };
                  callback->nonNullSuccess = [this, deferral, args](const std::shared_ptr<CustomSchemeResponse> response)
                    {
                      args->put_Response(response->toWebView2Response(webViewEnv));
                      failedLog(deferral->Complete());
                      return false;
                    };
                  callback->defaultBehaviour = defaultBehaviour;
                  callback->error = [this, defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
                    {
                      debugLog(error_code + ", " + error_message);
                      defaultBehaviour(std::nullopt);
                    };
                  channelDelegate->onLoadResourceWithCustomScheme(request, std::move(callback));
                }
                else {
                  failedLog(deferral->Complete());
                }
              };

            if (settings->useShouldInterceptRequest) {
              auto callback = std::make_unique<WebViewChannelDelegate::ShouldInterceptRequestCallback>();
              auto defaultBehaviour = [this, deferral, args](const std::optional<std::shared_ptr<WebResourceResponse>> response)
                {
                  failedLog(deferral->Complete());
                };
              callback->nonNullSuccess = [this, deferral, args](const std::shared_ptr<WebResourceResponse> response)
                {
                  args->put_Response(response->toWebView2Response(webViewEnv));
                  failedLog(deferral->Complete());
                  return false;
                };
              callback->nullSuccess = [this, deferral, args, isCustomScheme, onLoadResourceWithCustomSchemeCallback]()
                {
                  if (isCustomScheme) {
                    onLoadResourceWithCustomSchemeCallback();
                  }
                  else {
                    failedLog(deferral->Complete());
                  }
                  return false;
                };
              callback->defaultBehaviour = defaultBehaviour;
              callback->error = [this, defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
                {
                  debugLog(error_code + ", " + error_message);
                  defaultBehaviour(std::nullopt);
                };
              channelDelegate->shouldInterceptRequest(request, std::move(callback));
            }
            else if (isCustomScheme) {
              onLoadResourceWithCustomSchemeCallback();
            }
            else {
              failedLog(deferral->Complete());
            }
          }
          return S_OK;
        }
      ).Get(), nullptr);
    failedLog(add_WebResourceRequested_HResult);

    auto add_ProcessFailed_HResult = webView->add_ProcessFailed(
      Callback<ICoreWebView2ProcessFailedEventHandler>(
        [this](ICoreWebView2* sender, ICoreWebView2ProcessFailedEventArgs* argsRaw)
        {
          if (!channelDelegate) {
            return S_OK;
          }

          wil::com_ptr<ICoreWebView2ProcessFailedEventArgs> args = argsRaw;
          auto args2 = args.try_query<ICoreWebView2ProcessFailedEventArgs2>();
          auto args3 = args.try_query<ICoreWebView2ProcessFailedEventArgs3>();

          COREWEBVIEW2_PROCESS_FAILED_REASON reason = COREWEBVIEW2_PROCESS_FAILED_REASON_UNEXPECTED;
          if (args2) {
            args2->get_Reason(&reason);
          }

          COREWEBVIEW2_PROCESS_FAILED_KIND kind;
          if (succeededOrLog(args->get_ProcessFailedKind(&kind))) {
            if (kind == COREWEBVIEW2_PROCESS_FAILED_KIND_BROWSER_PROCESS_EXITED) {
              auto didCrash = reason == COREWEBVIEW2_PROCESS_FAILED_REASON_CRASHED;
              auto detail = std::make_unique<RenderProcessGoneDetail>(
                didCrash
              );
              channelDelegate->onRenderProcessGone(std::move(detail));
            }
            else if (kind == COREWEBVIEW2_PROCESS_FAILED_KIND_RENDER_PROCESS_UNRESPONSIVE) {
              channelDelegate->onRenderProcessUnresponsive(getUrl());
            }
            else if (kind == COREWEBVIEW2_PROCESS_FAILED_KIND_RENDER_PROCESS_EXITED) {
              channelDelegate->onWebContentProcessDidTerminate();
            }

            auto frameInfos = std::optional<std::vector<std::shared_ptr<FrameInfo>>>{};
            wil::com_ptr<ICoreWebView2FrameInfoCollection> frameInfoCollection;
            wil::com_ptr<ICoreWebView2FrameInfoCollectionIterator> frameIterator;
            if (args2 && succeededOrLog(args2->get_FrameInfosForFailedProcess(&frameInfoCollection)) && frameInfoCollection && succeededOrLog(frameInfoCollection->GetIterator(&frameIterator))) {
              frameInfos = std::vector<std::shared_ptr<FrameInfo>>{};
              BOOL hasCurrent = FALSE;
              while (SUCCEEDED(frameIterator->MoveNext(&hasCurrent)) && hasCurrent) {
                wil::com_ptr<ICoreWebView2FrameInfo> frameInfo;
                if (SUCCEEDED(frameIterator->GetCurrent(&frameInfo))) {
                  frameInfos.value().push_back(std::move(FrameInfo::fromICoreWebView2FrameInfo(frameInfo)));
                }
                BOOL hasNext = FALSE;
                failedLog(frameIterator->MoveNext(&hasNext));
              }
            }

            wil::unique_cotaskmem_string processDescription;
            int exitCode;
            wil::unique_cotaskmem_string failedModule;

            auto detail = std::make_unique<ProcessFailedDetail>(
              (int64_t)kind,
              args2 && succeededOrLog(args2->get_ExitCode(&exitCode)) ? exitCode : std::optional<int64_t>{},
              args2 && succeededOrLog(args2->get_ProcessDescription(&processDescription)) ? wide_to_utf8(processDescription.get()) : std::optional<std::string>{},
              args2 ? (int64_t)reason : std::optional<int64_t>{},
              args3 && succeededOrLog(args3->get_FailureSourceModulePath(&failedModule)) ? wide_to_utf8(failedModule.get()) : std::optional<std::string>{},
              frameInfos
            );
            channelDelegate->onProcessFailed(std::move(detail));
          }
          return S_OK;
        }
      ).Get(), nullptr);
    failedLog(add_ProcessFailed_HResult);

    wil::com_ptr<ICoreWebView2_2> webView2;
    if (SUCCEEDED(webView->QueryInterface(IID_PPV_ARGS(&webView2)))) {
      auto add_DOMContentLoaded_HResult = webView2->add_DOMContentLoaded(
        Callback<ICoreWebView2DOMContentLoadedEventHandler>(
          [this](ICoreWebView2* sender, ICoreWebView2DOMContentLoadedEventArgs* args)
          {
            if (channelDelegate) {
              wil::unique_cotaskmem_string uri;
              std::optional<std::string> url = SUCCEEDED(webView->get_Source(&uri)) ? wide_to_utf8(uri.get()) : std::optional<std::string>{};
              channelDelegate->onDOMContentLoaded(url);
              progress_ = 66;
              channelDelegate->onProgressChanged(progress_);
            }
            return S_OK;
          }
        ).Get(), nullptr);
      failedLog(add_DOMContentLoaded_HResult);
    }

    wil::com_ptr<ICoreWebView2_4> webView4;
    if (SUCCEEDED(webView->QueryInterface(IID_PPV_ARGS(&webView4)))) {
      auto add_FrameCreated_HResult = webView4->add_FrameCreated(
        Callback<ICoreWebView2FrameCreatedEventHandler>(
          [this](ICoreWebView2* sender, ICoreWebView2FrameCreatedEventArgs* args)
          {
            wil::com_ptr<ICoreWebView2Frame> frame;
            wil::com_ptr<ICoreWebView2Frame2> frame2;
            if (succeededOrLog(args->get_Frame(&frame)) && SUCCEEDED(frame->QueryInterface(IID_PPV_ARGS(&frame2)))) {
              auto frame_add_WebMessageReceived_HResult = frame2->add_WebMessageReceived(Callback<ICoreWebView2FrameWebMessageReceivedEventHandler>(
                [this](ICoreWebView2Frame* sender, ICoreWebView2WebMessageReceivedEventArgs* args)
                {
                  return this->onCallJsHandler(false, args);
                }).Get(), nullptr);
              failedLog(frame_add_WebMessageReceived_HResult);
            }
            return S_OK;
          }
        ).Get(), nullptr);
      failedLog(add_FrameCreated_HResult);

      auto add_DownloadStarting_HResult = webView4->add_DownloadStarting(
        Callback<ICoreWebView2DownloadStartingEventHandler>(
          [this](ICoreWebView2* sender, ICoreWebView2DownloadStartingEventArgs* args)
          {
            wil::com_ptr<ICoreWebView2Deferral> deferral;
            wil::com_ptr<ICoreWebView2DownloadOperation> download;
            if (channelDelegate && settings->useOnDownloadStart && succeededOrLog(args->get_DownloadOperation(&download)) && succeededOrLog(args->GetDeferral(&deferral))) {

              wil::unique_cotaskmem_string uri;
              std::string url = SUCCEEDED(download->get_Uri(&uri)) ? wide_to_utf8(uri.get()) : "";

              INT64 contentLength = 0;
              failedLog(download->get_TotalBytesToReceive(&contentLength));

              wil::unique_cotaskmem_string downloadMimeType;
              std::optional<std::string> mimeType = SUCCEEDED(download->get_MimeType(&downloadMimeType)) ? wide_to_utf8(downloadMimeType.get()) : std::optional<std::string>{};

              wil::unique_cotaskmem_string downloadContentDisposition;
              std::optional<std::string> contentDisposition = SUCCEEDED(download->get_ContentDisposition(&downloadContentDisposition)) ? wide_to_utf8(downloadContentDisposition.get()) : std::optional<std::string>{};

              wil::unique_cotaskmem_string resultFilePath;
              std::optional<std::string> suggestedFilename = SUCCEEDED(download->get_ContentDisposition(&resultFilePath)) ? wide_to_utf8(resultFilePath.get()) : std::optional<std::string>{};

              auto request = std::make_shared<DownloadStartRequest>(
                contentDisposition,
                contentLength,
                mimeType,
                suggestedFilename,
                url
              );

              auto callback = std::make_unique<WebViewChannelDelegate::DownloadStartRequestCallback>();
              auto defaultBehaviour = [this, deferral, args](const std::optional<const std::shared_ptr<DownloadStartResponse>> response)
                {
                  failedLog(deferral->Complete());
                };
              callback->nonNullSuccess = [this, deferral, args](const std::shared_ptr<DownloadStartResponse> response)
                {
                  failedLog(args->put_Handled(response->handled));
                  auto resultFilePath = response->resultFilePath;
                  if (resultFilePath.has_value()) {
                    failedLog(args->put_ResultFilePath(utf8_to_wide(resultFilePath.value()).c_str()));
                  }
                  auto action = response->action;
                  if (action.has_value()) {
                    switch (action.value()) {
                    case DownloadStartResponseAction::cancel:
                      failedLog(args->put_Cancel(true));
                      break;
                    }
                  }
                  failedLog(deferral->Complete());
                  return false;
                };
              callback->defaultBehaviour = defaultBehaviour;
              callback->error = [this, defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
                {
                  debugLog(error_code + ", " + error_message);
                  defaultBehaviour(std::nullopt);
                };
              channelDelegate->onDownloadStarting(std::move(request), std::move(callback));
            }
            return S_OK;
          }
        ).Get(), nullptr);
      failedLog(add_DownloadStarting_HResult);
    }

    if (auto webView5 = webView.try_query<ICoreWebView2_5>()) {
      auto add_ClientCertificateRequested_HResult = webView5->add_ClientCertificateRequested(
        Callback<ICoreWebView2ClientCertificateRequestedEventHandler>(
          [this](
            ICoreWebView2* sender,
            ICoreWebView2ClientCertificateRequestedEventArgs* args)
          {
            wil::com_ptr<ICoreWebView2Deferral> deferral;
            wil::unique_cotaskmem_string host;

            if (channelDelegate && plugin && plugin->inAppWebViewManager &&
              succeededOrLog(args->get_Host(&host)) && succeededOrLog(args->GetDeferral(&deferral))) {

              std::vector<std::shared_ptr<SslCertificate>> mutuallyTrustedCertificates = {};
              wil::com_ptr<ICoreWebView2ClientCertificateCollection> certificateCollection;
              uint32_t certCount = 0;
              if (succeededOrLog(args->get_MutuallyTrustedCertificates(&certificateCollection)) && succeededOrLog(certificateCollection->get_Count(&certCount))) {

                for (uint32_t i = 0; i < certCount; i++) {
                  wil::com_ptr<ICoreWebView2ClientCertificate> clientCert;
                  if (succeededOrLog(certificateCollection->GetValueAtIndex(i, &clientCert))) {
                    wil::unique_cotaskmem_string certPemEncoded;
                    if (succeededOrLog(clientCert->ToPemEncoding(&certPemEncoded))) {
                      mutuallyTrustedCertificates.push_back(std::make_shared<SslCertificate>(wide_to_utf8(certPemEncoded.get())));
                    }
                  }
                }
              }

              std::vector<std::string> allowedCertificateAuthorities = {};
              wil::com_ptr<ICoreWebView2StringCollection> authoritiesCollection;
              uint32_t authoritiesCount = 0;
              if (succeededOrLog(args->get_AllowedCertificateAuthorities(&authoritiesCollection)) && succeededOrLog(authoritiesCollection->get_Count(&authoritiesCount))) {
                for (uint32_t i = 0; i < authoritiesCount; i++) {
                  wil::unique_cotaskmem_string authority;
                  if (succeededOrLog(authoritiesCollection->GetValueAtIndex(i, &authority))) {
                    allowedCertificateAuthorities.push_back(base64_decode(wide_to_utf8(authority.get())));
                  }
                }
              }

              args->get_AllowedCertificateAuthorities(&authoritiesCollection);

              int port = 0;
              args->get_Port(&port);

              BOOL isProxy = false;
              args->get_IsProxy(&isProxy);

              std::string scheme = "";
              auto currentUrl = getUrl();
              if (currentUrl.has_value()) {
                scheme = currentUrl.value().substr(0, currentUrl.value().find(':'));
              }

              auto protectionSpace = std::make_unique<URLProtectionSpace>(
                wide_to_utf8(host.get()),
                scheme,
                std::optional<std::string>{},
                port,
                std::optional<std::shared_ptr<SslCertificate>>{},
                std::optional<std::shared_ptr<SslError>>{}
              );
              auto challenge = std::make_unique<ClientCertChallenge>(
                std::move(protectionSpace),
                allowedCertificateAuthorities,
                isProxy,
                mutuallyTrustedCertificates
              );

              auto callback = std::make_unique<WebViewChannelDelegate::ReceivedClientCertRequestCallback>();
              auto defaultBehaviour = [this, deferral, args](const std::optional<std::shared_ptr<ClientCertResponse>> response)
                {
                  failedLog(deferral->Complete());
                };
              callback->nonNullSuccess = [this, deferral, certCount, certificateCollection, args](const std::shared_ptr<ClientCertResponse> response)
                {
                  auto action = response->action;

                  if (action.has_value()) {
                    switch (action.value()) {
                    case ClientCertResponseAction::proceed:
                      if (certCount > 0 && response->selectedCertificate >= 0) {
                        wil::com_ptr<ICoreWebView2ClientCertificate> selectedClientCert;
                        if (succeededOrLog(certificateCollection->GetValueAtIndex((uint32_t)response->selectedCertificate, &selectedClientCert))) {
                          args->put_SelectedCertificate(selectedClientCert.get());
                        }
                      }
                      args->put_Handled(true);
                      args->put_Cancel(false);
                      break;
                    case ClientCertResponseAction::ignore:
                      args->put_Handled(true);
                      args->put_Cancel(false);
                      break;
                    case ClientCertResponseAction::cancel:
                    default:
                      args->put_Cancel(true);
                      break;
                    }
                    failedLog(deferral->Complete());
                    return false;
                  }
                  return true;
                };
              callback->defaultBehaviour = defaultBehaviour;
              callback->error = [this, defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
                {
                  debugLog(error_code + ", " + error_message);
                  defaultBehaviour(std::nullopt);
                };
              channelDelegate->onReceivedClientCertRequest(std::move(challenge), std::move(callback));
            }
            return S_OK;
          })
        .Get(), nullptr);
      failedLog(add_ClientCertificateRequested_HResult);
    }

    if (auto webView10 = webView.try_query<ICoreWebView2_10>()) {
      auto add_BasicAuthenticationRequested_HResult = webView10->add_BasicAuthenticationRequested(
        Callback<ICoreWebView2BasicAuthenticationRequestedEventHandler>(
          [this](
            ICoreWebView2* sender,
            ICoreWebView2BasicAuthenticationRequestedEventArgs* args)
          {
            wil::com_ptr<ICoreWebView2Deferral> deferral;
            wil::com_ptr<ICoreWebView2BasicAuthenticationResponse> basicAuthenticationResponse;
            wil::unique_cotaskmem_string url;
            wil::unique_cotaskmem_string realmChallenge;

            if (channelDelegate && plugin && plugin->inAppWebViewManager &&
              succeededOrLog(args->get_Uri(&url)) && succeededOrLog(args->get_Challenge(&realmChallenge)) &&
              succeededOrLog(args->get_Response(&basicAuthenticationResponse)) && succeededOrLog(args->GetDeferral(&deferral))) {

              previousAuthRequestFailureCount++;

              try {
                winrt::Windows::Foundation::Uri const uri{ url.get() };

                auto basicRealm = std::string{ "Basic realm=\"" };
                auto basicRealmLength = basicRealm.length();
                auto realm = wide_to_utf8(realmChallenge.get());
                if (starts_with(realm, basicRealm)) {
                  realm = realm.substr(basicRealmLength, realm.length() - basicRealmLength - 1);
                }

                auto protectionSpace = std::make_unique<URLProtectionSpace>(
                  wide_to_utf8(uri.Host().c_str()),
                  wide_to_utf8(uri.SchemeName().c_str()),
                  realm,
                  uri.Port(),
                  std::optional<std::shared_ptr<SslCertificate>>{},
                  std::optional<std::shared_ptr<SslError>>{}
                );
                auto challenge = std::make_unique<HttpAuthenticationChallenge>(
                  std::move(protectionSpace),
                  previousAuthRequestFailureCount,
                  std::optional<std::shared_ptr<URLCredential>>{}
                );

                auto callback = std::make_unique<WebViewChannelDelegate::ReceivedHttpAuthRequestCallback>();
                auto defaultBehaviour = [this, deferral, args](const std::optional<std::shared_ptr<HttpAuthResponse>> response)
                  {
                    failedLog(deferral->Complete());
                  };
                callback->nonNullSuccess = [this, deferral, basicAuthenticationResponse, args](const std::shared_ptr<HttpAuthResponse> response)
                  {
                    auto action = response->action;
                    std::wstring username = utf8_to_wide(response->username);
                    std::wstring password = utf8_to_wide(response->password);

                    if (action.has_value()) {
                      switch (action.value()) {
                      case HttpAuthResponseAction::proceed:
                        failedLog(basicAuthenticationResponse->put_UserName(username.c_str()));
                        failedLog(basicAuthenticationResponse->put_Password(password.c_str()));
                        break;
                      case HttpAuthResponseAction::cancel:
                      default:
                        args->put_Cancel(true);
                        break;
                      }
                      failedLog(deferral->Complete());
                      return false;
                    }
                    return true;
                  };
                callback->defaultBehaviour = defaultBehaviour;
                callback->error = [this, defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
                  {
                    debugLog(error_code + ", " + error_message);
                    defaultBehaviour(std::nullopt);
                  };
                channelDelegate->onReceivedHttpAuthRequest(std::move(challenge), std::move(callback));
              }
              catch (winrt::hresult_error const& ex) {
                debugLog(wide_to_utf8(ex.message().c_str()));
              }
            }
            return S_OK;
          })
        .Get(), nullptr);
      failedLog(add_BasicAuthenticationRequested_HResult);
    }

    if (auto webView14 = webView.try_query<ICoreWebView2_14>()) {
      auto add_ServerCertificateErrorDetected_HResult = webView14->add_ServerCertificateErrorDetected(
        Callback<ICoreWebView2ServerCertificateErrorDetectedEventHandler>(
          [this](ICoreWebView2* sender, ICoreWebView2ServerCertificateErrorDetectedEventArgs* args)
          {
            wil::com_ptr<ICoreWebView2Deferral> deferral;
            wil::unique_cotaskmem_string requestUrl;
            if (succeededOrLog(args->get_RequestUri(&requestUrl)) && succeededOrLog(args->GetDeferral(&deferral))) {

              wil::com_ptr<ICoreWebView2Certificate> serverCert;
              auto sslCert = std::optional<std::shared_ptr<SslCertificate>>{};
              if (succeededOrLog(args->get_ServerCertificate(&serverCert))) {
                wil::unique_cotaskmem_string certPemEncoded;
                if (succeededOrLog(serverCert->ToPemEncoding(&certPemEncoded))) {
                  sslCert = std::make_shared<SslCertificate>(wide_to_utf8(certPemEncoded.get()));
                }
              }

              auto sslError = std::optional<std::shared_ptr<SslError>>{};
              COREWEBVIEW2_WEB_ERROR_STATUS errorStatus;
              if (succeededOrLog(args->get_ErrorStatus(&errorStatus))) {
                sslError = std::make_shared<SslError>(
                  errorStatus,
                  COREWEBVIEW2_WEB_ERROR_STATUS_ToString(errorStatus)
                );
              }

              try {
                winrt::Windows::Foundation::Uri const uri{ requestUrl.get() };

                auto protectionSpace = std::make_unique<URLProtectionSpace>(
                  wide_to_utf8(uri.Host().c_str()),
                  wide_to_utf8(uri.SchemeName().c_str()),
                  std::optional<std::string>{},
                  uri.Port(),
                  sslCert,
                  sslError
                );
                auto challenge = std::make_unique<ServerTrustChallenge>(
                  std::move(protectionSpace)
                );

                auto callback = std::make_unique<WebViewChannelDelegate::ReceivedServerTrustAuthRequestCallback>();
                auto defaultBehaviour = [this, deferral, args](const std::optional<std::shared_ptr<ServerTrustAuthResponse>> response)
                  {
                    failedLog(deferral->Complete());
                  };
                callback->nonNullSuccess = [this, deferral, args](const std::shared_ptr<ServerTrustAuthResponse> response)
                  {
                    auto action = response->action;

                    if (action.has_value()) {
                      switch (action.value()) {
                      case ServerTrustAuthResponseAction::proceed:
                        args->put_Action(COREWEBVIEW2_SERVER_CERTIFICATE_ERROR_ACTION_ALWAYS_ALLOW);
                        break;
                      case ServerTrustAuthResponseAction::cancel:
                        args->put_Action(COREWEBVIEW2_SERVER_CERTIFICATE_ERROR_ACTION_CANCEL);
                        break;
                      default:
                        args->put_Action(COREWEBVIEW2_SERVER_CERTIFICATE_ERROR_ACTION_DEFAULT);
                      }
                      failedLog(deferral->Complete());
                      return false;
                    }
                    return true;
                  };
                callback->defaultBehaviour = defaultBehaviour;
                callback->error = [this, defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
                  {
                    debugLog(error_code + ", " + error_message);
                    defaultBehaviour(std::nullopt);
                  };
                channelDelegate->onReceivedServerTrustAuthRequest(std::move(challenge), std::move(callback));
              }
              catch (winrt::hresult_error const& ex) {
                debugLog(wide_to_utf8(ex.message().c_str()));
              }
            }
            return S_OK;
          }
        ).Get(), nullptr);
      failedLog(add_ServerCertificateErrorDetected_HResult);
    }

    if (auto webView15 = webView.try_query<ICoreWebView2_15>()) {
      auto add_FaviconChanged_HResult = webView15->add_FaviconChanged(
        Callback<ICoreWebView2FaviconChangedEventHandler>(
          [this, webView15](ICoreWebView2* sender, IUnknown* args)
          {
            if (!channelDelegate) {
              return S_OK;
            }

            wil::unique_cotaskmem_string faviconUri;
            std::optional<std::string> faviconUrl = succeededOrLog(webView15->get_FaviconUri(&faviconUri)) && faviconUri ?
              std::optional<std::string>{ wide_to_utf8(faviconUri.get()) } : std::optional<std::string>{};

            auto hr = webView15->GetFavicon(COREWEBVIEW2_FAVICON_IMAGE_FORMAT_PNG,
              Callback<ICoreWebView2GetFaviconCompletedHandler>(
                [this, faviconUrl](HRESULT errorCode, IStream* faviconStream)
                {
                  std::optional<std::vector<uint8_t>> icon = std::nullopt;
                  if (succeededOrLog(errorCode) && faviconStream) {
                    icon = readStreamBytes(faviconStream);
                  }
                  if (channelDelegate) {
                    auto request = std::make_shared<FaviconChangedRequest>(icon, faviconUrl);
                    channelDelegate->onFaviconChanged(std::move(request));
                  }
                  return S_OK;
                })
              .Get());

            if (failedAndLog(hr)) {
              if (channelDelegate) {
                auto request = std::make_shared<FaviconChangedRequest>(std::nullopt, faviconUrl);
                channelDelegate->onFaviconChanged(std::move(request));
              }
            }

            return S_OK;
          })
        .Get(), nullptr);
      failedLog(add_FaviconChanged_HResult);
    }

    if (auto webView18 = webView.try_query<ICoreWebView2_18>()) {
      auto add_LaunchingExternalUriScheme_HResult = webView18->add_LaunchingExternalUriScheme(
        Callback<ICoreWebView2LaunchingExternalUriSchemeEventHandler>(
          [this](ICoreWebView2* sender, ICoreWebView2LaunchingExternalUriSchemeEventArgs* args)
          {
            wil::com_ptr<ICoreWebView2Deferral> deferral;
            failedLog(args->GetDeferral(&deferral));

            if (!channelDelegate) {
              failedLog(args->put_Cancel(FALSE));
              if (deferral) {
                failedLog(deferral->Complete());
              }
              return S_OK;
            }

            wil::unique_cotaskmem_string uri;
            std::string uriValue = SUCCEEDED(args->get_Uri(&uri)) && uri ? wide_to_utf8(uri.get()) : "";

            wil::unique_cotaskmem_string initiatingOrigin;
            std::optional<std::string> origin = SUCCEEDED(args->get_InitiatingOrigin(&initiatingOrigin)) && initiatingOrigin ?
              std::optional<std::string>{ wide_to_utf8(initiatingOrigin.get()) } : std::optional<std::string>{};

            BOOL isUserInitiated = FALSE;
            failedLog(args->get_IsUserInitiated(&isUserInitiated));

            auto request = std::make_shared<LaunchingExternalUriSchemeRequest>(
              uriValue,
              origin,
              static_cast<bool>(isUserInitiated));

            auto callback = std::make_unique<WebViewChannelDelegate::LaunchingExternalUriSchemeCallback>();
            auto defaultBehaviour = [deferral, args](const std::optional<std::shared_ptr<LaunchingExternalUriSchemeResponse>> response)
              {
                failedLog(args->put_Cancel(FALSE));
                if (deferral) {
                  failedLog(deferral->Complete());
                }
              };
            callback->nonNullSuccess = [deferral, args](const std::shared_ptr<LaunchingExternalUriSchemeResponse> response)
              {
                failedLog(args->put_Cancel(response ? response->cancel : FALSE));
                if (deferral) {
                  failedLog(deferral->Complete());
                }
                return false;
              };
            callback->defaultBehaviour = defaultBehaviour;
            callback->error = [defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
              {
                debugLog(error_code + ", " + error_message);
                defaultBehaviour(std::nullopt);
              };
            channelDelegate->onLaunchingExternalUriScheme(std::move(request), std::move(callback));
            return S_OK;
          })
        .Get(), nullptr);
      failedLog(add_LaunchingExternalUriScheme_HResult);
    }

    if (auto webView24 = webView.try_query<ICoreWebView2_24>()) {
      auto add_NotificationReceived_HResult = webView24->add_NotificationReceived(
        Callback<ICoreWebView2NotificationReceivedEventHandler>(
          [this](ICoreWebView2* sender, ICoreWebView2NotificationReceivedEventArgs* args)
          {
            wil::com_ptr<ICoreWebView2Deferral> deferral;
            failedLog(args->GetDeferral(&deferral));

            if (!channelDelegate) {
              failedLog(args->put_Handled(FALSE));
              if (deferral) {
                failedLog(deferral->Complete());
              }
              return S_OK;
            }

            wil::unique_cotaskmem_string senderOrigin;
            std::optional<std::string> senderOriginValue = SUCCEEDED(args->get_SenderOrigin(&senderOrigin)) && senderOrigin ?
              std::optional<std::string>{ wide_to_utf8(senderOrigin.get()) } : std::optional<std::string>{};

            std::shared_ptr<WebNotification> notificationPtr;
            wil::com_ptr<ICoreWebView2Notification> notification;
            if (succeededOrLog(args->get_Notification(&notification)) && notification) {
              wil::unique_cotaskmem_string badgeUri;
              wil::unique_cotaskmem_string body;
              wil::unique_cotaskmem_string bodyImageUri;
              wil::unique_cotaskmem_string iconUri;
              wil::unique_cotaskmem_string language;
              wil::unique_cotaskmem_string tag;
              wil::unique_cotaskmem_string title;

              BOOL isSilent = FALSE;
              BOOL requiresInteraction = FALSE;
              BOOL shouldRenotify = FALSE;
              double timestamp = 0;
              COREWEBVIEW2_TEXT_DIRECTION_KIND direction = COREWEBVIEW2_TEXT_DIRECTION_KIND_DEFAULT;

              notification->get_BadgeUri(&badgeUri);
              notification->get_Body(&body);
              notification->get_BodyImageUri(&bodyImageUri);
              notification->get_IconUri(&iconUri);
              notification->get_IsSilent(&isSilent);
              notification->get_Language(&language);
              notification->get_RequiresInteraction(&requiresInteraction);
              notification->get_ShouldRenotify(&shouldRenotify);
              notification->get_Tag(&tag);
              notification->get_Timestamp(&timestamp);
              notification->get_Title(&title);
              notification->get_Direction(&direction);

              // Get vibration pattern
              UINT32 vibrationPatternCount = 0;
              UINT64* vibrationPatternValues = nullptr;
              std::optional<std::vector<int64_t>> vibrationPattern = std::nullopt;
              if (SUCCEEDED(notification->GetVibrationPattern(&vibrationPatternCount, &vibrationPatternValues)) && vibrationPatternCount > 0) {
                std::vector<int64_t> pattern;
                pattern.reserve(vibrationPatternCount);
                for (UINT32 i = 0; i < vibrationPatternCount; ++i) {
                  pattern.push_back(static_cast<int64_t>(vibrationPatternValues[i]));
                }
                CoTaskMemFree(vibrationPatternValues);
                vibrationPattern = std::move(pattern);
              }

              notificationPtr = std::make_shared<WebNotification>(
                title ? std::optional<std::string>{ wide_to_utf8(title.get()) } : std::optional<std::string>{},
                body ? std::optional<std::string>{ wide_to_utf8(body.get()) } : std::optional<std::string>{},
                TextDirectionKindFromOptionalInteger(std::optional<int64_t>{ static_cast<int64_t>(direction) }),
                language ? std::optional<std::string>{ wide_to_utf8(language.get()) } : std::optional<std::string>{},
                tag ? std::optional<std::string>{ wide_to_utf8(tag.get()) } : std::optional<std::string>{},
                iconUri ? std::optional<std::string>{ wide_to_utf8(iconUri.get()) } : std::optional<std::string>{},
                badgeUri ? std::optional<std::string>{ wide_to_utf8(badgeUri.get()) } : std::optional<std::string>{},
                bodyImageUri ? std::optional<std::string>{ wide_to_utf8(bodyImageUri.get()) } : std::optional<std::string>{},
                static_cast<bool>(shouldRenotify),
                static_cast<bool>(requiresInteraction),
                static_cast<bool>(isSilent),
                timestamp,
                vibrationPattern);
            }

            // Create WebNotificationController with unique ID, passing this InAppWebView pointer
            std::string notificationControllerId = get_uuid();
            auto notificationController = std::make_shared<WebNotificationController>(
              notificationControllerId, notification, notificationPtr, plugin->registrar->messenger(), this);

            // Store the controller in the map to prevent deallocation
            webNotificationControllers_[notificationControllerId] = notificationController;

            auto request = std::make_shared<NotificationReceivedRequest>(senderOriginValue, notificationControllerId, notificationPtr);

            auto callback = std::make_unique<WebViewChannelDelegate::NotificationReceivedCallback>();
            auto defaultBehaviour = [deferral, args, notificationController](const std::optional<std::shared_ptr<NotificationReceivedResponse>> response)
              {
                failedLog(args->put_Handled(FALSE));
                if (deferral) {
                  failedLog(deferral->Complete());
                }
              };
            callback->nonNullSuccess = [deferral, args, notificationController](const std::shared_ptr<NotificationReceivedResponse> response)
              {
                failedLog(args->put_Handled(response ? response->handled : FALSE));
                if (deferral) {
                  failedLog(deferral->Complete());
                }
                return false;
              };
            callback->defaultBehaviour = defaultBehaviour;
            callback->error = [defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
              {
                debugLog(error_code + ", " + error_message);
                defaultBehaviour(std::nullopt);
              };
            channelDelegate->onNotificationReceived(std::move(request), std::move(callback));
            return S_OK;
          })
        .Get(), nullptr);
      failedLog(add_NotificationReceived_HResult);
    }

    if (auto webView25 = webView.try_query<ICoreWebView2_25>()) {
      auto add_SaveAsUIShowing_HResult = webView25->add_SaveAsUIShowing(
        Callback<ICoreWebView2SaveAsUIShowingEventHandler>(
          [this](ICoreWebView2* sender, ICoreWebView2SaveAsUIShowingEventArgs* args)
          {
            wil::com_ptr<ICoreWebView2Deferral> deferral;
            failedLog(args->GetDeferral(&deferral));

            BOOL allowReplace = FALSE;
            BOOL cancel = FALSE;
            BOOL suppressDefaultDialog = FALSE;
            COREWEBVIEW2_SAVE_AS_KIND kind = COREWEBVIEW2_SAVE_AS_KIND_DEFAULT;
            wil::unique_cotaskmem_string contentMimeType;
            wil::unique_cotaskmem_string saveAsFilePath;

            failedLog(args->get_AllowReplace(&allowReplace));
            failedLog(args->get_Cancel(&cancel));
            failedLog(args->get_SuppressDefaultDialog(&suppressDefaultDialog));
            failedLog(args->get_Kind(&kind));
            failedLog(args->get_ContentMimeType(&contentMimeType));
            failedLog(args->get_SaveAsFilePath(&saveAsFilePath));

            if (!channelDelegate) {
              if (deferral) {
                failedLog(deferral->Complete());
              }
              return S_OK;
            }

            auto request = std::make_shared<SaveAsUIShowingRequest>(
              contentMimeType ? std::optional<std::string>{ wide_to_utf8(contentMimeType.get()) } : std::optional<std::string>{},
              static_cast<bool>(cancel),
              static_cast<bool>(suppressDefaultDialog),
              saveAsFilePath ? std::optional<std::string>{ wide_to_utf8(saveAsFilePath.get()) } : std::optional<std::string>{},
              static_cast<bool>(allowReplace),
              SaveAsKindFromOptionalInteger(std::optional<int64_t>{ static_cast<int64_t>(kind) }));

            auto callback = std::make_unique<WebViewChannelDelegate::SaveAsUIShowingCallback>();
            auto defaultBehaviour = [deferral](const std::optional<std::shared_ptr<SaveAsUIShowingResponse>> response)
              {
                if (deferral) {
                  failedLog(deferral->Complete());
                }
              };
            callback->nonNullSuccess = [deferral, args](const std::shared_ptr<SaveAsUIShowingResponse> response)
              {
                if (response && response->allowReplace.has_value()) {
                  failedLog(args->put_AllowReplace(response->allowReplace.value()));
                }
                if (response && response->cancel.has_value()) {
                  failedLog(args->put_Cancel(response->cancel.value()));
                }
                if (response && response->kind.has_value()) {
                  failedLog(args->put_Kind(static_cast<COREWEBVIEW2_SAVE_AS_KIND>(response->kind.value())));
                }
                if (response && response->saveAsFilePath.has_value()) {
                  failedLog(args->put_SaveAsFilePath(utf8_to_wide(response->saveAsFilePath.value()).c_str()));
                }
                if (response && response->suppressDefaultDialog.has_value()) {
                  failedLog(args->put_SuppressDefaultDialog(response->suppressDefaultDialog.value()));
                }
                if (deferral) {
                  failedLog(deferral->Complete());
                }
                return false;
              };
            callback->defaultBehaviour = defaultBehaviour;
            callback->error = [defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
              {
                debugLog(error_code + ", " + error_message);
                defaultBehaviour(std::nullopt);
              };
            channelDelegate->onSaveAsUIShowing(std::move(request), std::move(callback));
            return S_OK;
          })
        .Get(), nullptr);
      failedLog(add_SaveAsUIShowing_HResult);
    }

    if (auto webView26 = webView.try_query<ICoreWebView2_26>()) {
      auto add_SaveFileSecurityCheckStarting_HResult = webView26->add_SaveFileSecurityCheckStarting(
        Callback<ICoreWebView2SaveFileSecurityCheckStartingEventHandler>(
          [this](ICoreWebView2* sender, ICoreWebView2SaveFileSecurityCheckStartingEventArgs* args)
          {
            wil::com_ptr<ICoreWebView2Deferral> deferral;
            failedLog(args->GetDeferral(&deferral));

            BOOL cancelSave = FALSE;
            BOOL suppressDefaultPolicy = FALSE;
            wil::unique_cotaskmem_string documentOriginUri;
            wil::unique_cotaskmem_string fileExtension;
            wil::unique_cotaskmem_string filePath;

            failedLog(args->get_CancelSave(&cancelSave));
            failedLog(args->get_SuppressDefaultPolicy(&suppressDefaultPolicy));
            failedLog(args->get_DocumentOriginUri(&documentOriginUri));
            failedLog(args->get_FileExtension(&fileExtension));
            failedLog(args->get_FilePath(&filePath));

            if (!channelDelegate) {
              if (deferral) {
                failedLog(deferral->Complete());
              }
              return S_OK;
            }

            auto request = std::make_shared<SaveFileSecurityCheckStartingRequest>(
              documentOriginUri ? std::optional<std::string>{ wide_to_utf8(documentOriginUri.get()) } : std::optional<std::string>{},
              fileExtension ? std::optional<std::string>{ wide_to_utf8(fileExtension.get()) } : std::optional<std::string>{},
              filePath ? std::optional<std::string>{ wide_to_utf8(filePath.get()) } : std::optional<std::string>{},
              static_cast<bool>(cancelSave),
              static_cast<bool>(suppressDefaultPolicy));

            auto callback = std::make_unique<WebViewChannelDelegate::SaveFileSecurityCheckStartingCallback>();
            auto defaultBehaviour = [deferral](const std::optional<std::shared_ptr<SaveFileSecurityCheckStartingResponse>> response)
              {
                if (deferral) {
                  failedLog(deferral->Complete());
                }
              };
            callback->nonNullSuccess = [deferral, args](const std::shared_ptr<SaveFileSecurityCheckStartingResponse> response)
              {
                if (response && response->cancelSave.has_value()) {
                  failedLog(args->put_CancelSave(response->cancelSave.value()));
                }
                if (response && response->suppressDefaultPolicy.has_value()) {
                  failedLog(args->put_SuppressDefaultPolicy(response->suppressDefaultPolicy.value()));
                }
                if (deferral) {
                  failedLog(deferral->Complete());
                }
                return false;
              };
            callback->defaultBehaviour = defaultBehaviour;
            callback->error = [defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
              {
                debugLog(error_code + ", " + error_message);
                defaultBehaviour(std::nullopt);
              };
            channelDelegate->onSaveFileSecurityCheckStarting(std::move(request), std::move(callback));
            return S_OK;
          })
        .Get(), nullptr);
      failedLog(add_SaveFileSecurityCheckStarting_HResult);
    }

    if (auto webView27 = webView.try_query<ICoreWebView2_27>()) {
      auto add_ScreenCaptureStarting_HResult = webView27->add_ScreenCaptureStarting(
        Callback<ICoreWebView2ScreenCaptureStartingEventHandler>(
          [this](ICoreWebView2* sender, ICoreWebView2ScreenCaptureStartingEventArgs* args)
          {
            wil::com_ptr<ICoreWebView2Deferral> deferral;
            failedLog(args->GetDeferral(&deferral));

            BOOL cancel = FALSE;
            BOOL handled = FALSE;
            failedLog(args->get_Cancel(&cancel));
            failedLog(args->get_Handled(&handled));

            wil::com_ptr<ICoreWebView2FrameInfo> frameInfo;
            std::optional<std::shared_ptr<FrameInfo>> frame = std::nullopt;
            if (succeededOrLog(args->get_OriginalSourceFrameInfo(&frameInfo)) && frameInfo) {
              auto framePtr = FrameInfo::fromICoreWebView2FrameInfo(frameInfo);
              if (framePtr) {
                frame = std::shared_ptr<FrameInfo>(std::move(framePtr));
              }
            }

            if (!channelDelegate) {
              if (deferral) {
                failedLog(deferral->Complete());
              }
              return S_OK;
            }

            auto request = std::make_shared<ScreenCaptureStartingRequest>(
              frame,
              static_cast<bool>(cancel),
              static_cast<bool>(handled));

            auto callback = std::make_unique<WebViewChannelDelegate::ScreenCaptureStartingCallback>();
            auto defaultBehaviour = [deferral](const std::optional<std::shared_ptr<ScreenCaptureStartingResponse>> response)
              {
                if (deferral) {
                  failedLog(deferral->Complete());
                }
              };
            callback->nonNullSuccess = [deferral, args](const std::shared_ptr<ScreenCaptureStartingResponse> response)
              {
                if (response && response->cancel.has_value()) {
                  failedLog(args->put_Cancel(response->cancel.value()));
                }
                if (response && response->handled.has_value()) {
                  failedLog(args->put_Handled(response->handled.value()));
                }
                if (deferral) {
                  failedLog(deferral->Complete());
                }
                return false;
              };
            callback->defaultBehaviour = defaultBehaviour;
            callback->error = [defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
              {
                debugLog(error_code + ", " + error_message);
                defaultBehaviour(std::nullopt);
              };
            channelDelegate->onScreenCaptureStarting(std::move(request), std::move(callback));
            return S_OK;
          })
        .Get(), nullptr);
      failedLog(add_ScreenCaptureStarting_HResult);
    }

    if (userContentController) {
      userContentController->registerEventHandlers();
    }
  }

  void InAppWebView::registerSurfaceEventHandlers()
  {
    if (!webViewCompositionController) {
      return;
    }

    failedLog(webViewCompositionController->add_CursorChanged(
      Callback<ICoreWebView2CursorChangedEventHandler>(
        [this](ICoreWebView2CompositionController* sender,
          IUnknown* args) -> HRESULT
        {
          HCURSOR cursor;
          if (cursorChangedCallback_ &&
            sender->get_Cursor(&cursor) == S_OK) {
            cursorChangedCallback_(cursor);
          }
          return S_OK;
        })
      .Get(), nullptr));
  }

  std::optional<std::string> InAppWebView::getUrl() const
  {
    wil::unique_cotaskmem_string uri;
    return webView && succeededOrLog(webView->get_Source(&uri)) ? wide_to_utf8(uri.get()) : std::optional<std::string>{};
  }

  std::optional<std::string> InAppWebView::getTitle() const
  {
    wil::unique_cotaskmem_string title;
    return webView && succeededOrLog(webView->get_DocumentTitle(&title)) ? wide_to_utf8(title.get()) : std::optional<std::string>{};
  }

  std::optional<int64_t> InAppWebView::getFrameId() const
  {
    if (auto webView20 = webView.try_query<ICoreWebView2_20>()) {
      UINT32 frameId = 0;
      if (succeededOrLog(webView20->get_FrameId(&frameId))) {
        return static_cast<int64_t>(frameId);
      }
    }
    return std::nullopt;
  }

  std::optional<int64_t> InAppWebView::getMemoryUsageTargetLevel() const
  {
    if (auto webView19 = webView.try_query<ICoreWebView2_19>()) {
      COREWEBVIEW2_MEMORY_USAGE_TARGET_LEVEL level = COREWEBVIEW2_MEMORY_USAGE_TARGET_LEVEL_NORMAL;
      if (succeededOrLog(webView19->get_MemoryUsageTargetLevel(&level))) {
        return static_cast<int64_t>(level);
      }
    }
    return std::nullopt;
  }

  void InAppWebView::setMemoryUsageTargetLevel(const int64_t& level) const
  {
    if (auto webView19 = webView.try_query<ICoreWebView2_19>()) {
      failedLog(webView19->put_MemoryUsageTargetLevel(static_cast<COREWEBVIEW2_MEMORY_USAGE_TARGET_LEVEL>(level)));
    }
  }

  void InAppWebView::getFavicon(const std::optional<std::string>& url, const std::optional<FaviconImageFormat>& faviconImageFormat,
    const std::function<void(const std::optional<std::vector<uint8_t>>)> completionHandler) const
  {
    (void)url;
    if (!completionHandler) {
      return;
    }

    auto webView15 = webView.try_query<ICoreWebView2_15>();
    if (!webView15) {
      completionHandler(std::nullopt);
      return;
    }

    auto format = faviconImageFormat.has_value() ? faviconImageFormat.value() : FaviconImageFormat::png;
    auto hr = webView15->GetFavicon(
      FaviconImageFormatToCoreWebView2(format),
      Callback<ICoreWebView2GetFaviconCompletedHandler>(
        [completionHandler](HRESULT errorCode, IStream* faviconStream)
        {
          if (succeededOrLog(errorCode) && faviconStream) {
            completionHandler(readStreamBytes(faviconStream));
          }
          else {
            completionHandler(std::nullopt);
          }
          return S_OK;
        })
      .Get());

    if (failedAndLog(hr)) {
      completionHandler(std::nullopt);
    }
  }

  void InAppWebView::showSaveAsUI(const std::function<void(const std::optional<int64_t>)> completionHandler) const
  {
    if (!completionHandler) {
      return;
    }

    auto webView25 = webView.try_query<ICoreWebView2_25>();
    if (!webView25) {
      completionHandler(std::nullopt);
      return;
    }

    auto hr = webView25->ShowSaveAsUI(
      Callback<ICoreWebView2ShowSaveAsUICompletedHandler>(
        [completionHandler](HRESULT errorCode, COREWEBVIEW2_SAVE_AS_UI_RESULT result)
        {
          if (succeededOrLog(errorCode)) {
            completionHandler(static_cast<int64_t>(result));
          }
          else {
            completionHandler(std::nullopt);
          }
          return S_OK;
        })
      .Get());

    if (failedAndLog(hr)) {
      completionHandler(std::nullopt);
    }
  }

  void InAppWebView::loadUrl(const std::shared_ptr<URLRequest> urlRequest) const
  {
    if (!webView || !urlRequest->url.has_value()) {
      return;
    }

    std::wstring url = utf8_to_wide(urlRequest->url.value());

    wil::com_ptr<ICoreWebView2Environment2> webViewEnv2;
    wil::com_ptr<ICoreWebView2_2> webView2;
    if (SUCCEEDED(webViewEnv->QueryInterface(IID_PPV_ARGS(&webViewEnv2))) && SUCCEEDED(webView->QueryInterface(IID_PPV_ARGS(&webView2)))) {
      wil::com_ptr<ICoreWebView2WebResourceRequest> webResourceRequest;
      std::wstring method = urlRequest->method.has_value() ? utf8_to_wide(urlRequest->method.value()) : L"GET";

      wil::com_ptr<IStream> postDataStream = nullptr;
      if (urlRequest->body.has_value()) {
        auto postData = std::string(urlRequest->body->begin(), urlRequest->body->end());
        postDataStream = SHCreateMemStream(
          reinterpret_cast<const BYTE*>(postData.data()), static_cast<UINT>(postData.length()));
      }
      if (succeededOrLog(webViewEnv2->CreateWebResourceRequest(
        url.c_str(),
        method.c_str(),
        postDataStream.get(),
        L"",
        &webResourceRequest
      ))) {
        wil::com_ptr<ICoreWebView2HttpRequestHeaders> requestHeaders;
        if (SUCCEEDED(webResourceRequest->get_Headers(&requestHeaders))) {
          if (method.compare(L"GET") != 0) {
            requestHeaders->SetHeader(L"Flutter-InAppWebView-Request-Method", method.c_str());
          }
          if (urlRequest->headers.has_value()) {
            auto& headers = urlRequest->headers.value();
            for (auto const& [key, val] : headers) {
              requestHeaders->SetHeader(utf8_to_wide(key).c_str(), utf8_to_wide(val).c_str());
            }
          }
        }
        failedLog(webView2->NavigateWithWebResourceRequest(webResourceRequest.get()));
      }
      return;
    }
    failedLog(webView->Navigate(url.c_str()));
  }


  void InAppWebView::loadFile(const std::string& assetFilePath) const
  {
    if (!webView) {
      return;
    }

    WCHAR* buf = new WCHAR[32768];
    GetModuleFileName(NULL, buf, 32768);
    std::filesystem::path exeAbsPath = std::wstring(buf);
    delete[] buf;

    std::filesystem::path flutterAssetPath("data/flutter_assets/" + assetFilePath);
    auto absAssetFilePath = exeAbsPath.parent_path() / flutterAssetPath;

    if (!std::filesystem::exists(absAssetFilePath)) {
      debugLog(absAssetFilePath.native() + L" asset file cannot be found!");
      return;
    }
    failedLog(webView->Navigate(absAssetFilePath.c_str()));
  }

  void InAppWebView::loadData(const std::string& data) const
  {
    if (!webView) {
      return;
    }

    failedLog(webView->NavigateToString(utf8_to_wide(data).c_str()));
  }

  void InAppWebView::reload() const
  {
    if (!webView) {
      return;
    }

    failedLog(webView->Reload());
  }

  void InAppWebView::goBack()
  {
    if (!webView) {
      return;
    }

    failedLog(webView->GoBack());
  }

  bool InAppWebView::canGoBack() const
  {
    BOOL canGoBack_;
    return webView && succeededOrLog(webView->get_CanGoBack(&canGoBack_)) ? canGoBack_ : false;
  }

  void InAppWebView::goForward()
  {
    if (!webView) {
      return;
    }

    failedLog(webView->GoForward());
  }

  bool InAppWebView::canGoForward() const
  {
    BOOL canGoForward_;
    return webView && succeededOrLog(webView->get_CanGoForward(&canGoForward_)) ? canGoForward_ : false;
  }

  void InAppWebView::goBackOrForward(const int64_t& steps)
  {
    getCopyBackForwardList(
      [this, steps](std::unique_ptr<WebHistory> webHistory)
      {
        if (webHistory && webHistory->currentIndex.has_value() && webHistory->list.has_value()) {
          auto currentIndex = webHistory->currentIndex.value();
          auto items = &webHistory->list.value();
          auto nextIndex = currentIndex + steps;
          int64_t size = items->size();
          if (nextIndex >= 0 && nextIndex < size) {
            auto entryId = items->at(nextIndex)->entryId;
            if (entryId.has_value()) {
              failedAndLog(webView->CallDevToolsProtocolMethod(L"Page.navigateToHistoryEntry", utf8_to_wide("{\"entryId\": " + std::to_string(entryId.value()) + "}").c_str(), Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
                [this](HRESULT errorCode, LPCWSTR returnObjectAsJson)
                {
                  failedLog(errorCode);
                  return S_OK;
                }
              ).Get()));
            }
          }
        }
      }
    );
  }

  void InAppWebView::canGoBackOrForward(const int64_t& steps, std::function<void(bool)> completionHandler) const
  {
    getCopyBackForwardList(
      [steps, completionHandler](std::unique_ptr<WebHistory> webHistory)
      {
        auto canGoBackOrForward_ = false;
        if (webHistory && webHistory->currentIndex.has_value() && webHistory->list.has_value()) {
          auto currentIndex = webHistory->currentIndex.value();
          auto items = &webHistory->list.value();
          auto nextIndex = currentIndex + steps;
          int64_t size = items->size();
          canGoBackOrForward_ = nextIndex >= 0 && nextIndex < size;
        }

        if (completionHandler) {
          completionHandler(canGoBackOrForward_);
        }
      }
    );
  }

  void InAppWebView::stopLoading() const
  {
    if (!webView) {
      return;
    }

    failedLog(webView->Stop());
  }

  void InAppWebView::getCopyBackForwardList(const std::function<void(std::unique_ptr<WebHistory>)> completionHandler) const
  {
    if (!webView) {
      if (completionHandler) {
        completionHandler(std::make_unique<WebHistory>(std::nullopt, std::nullopt));
      }
      return;
    }

    failedLog(webView->CallDevToolsProtocolMethod(L"Page.getNavigationHistory", L"{}", Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
      [completionHandler](HRESULT errorCode, LPCWSTR returnObjectAsJson)
      {
        if (!completionHandler) {
          return S_OK;
        }

        if (errorCode == S_OK) {
          auto historyJson = nlohmann::json::parse(wide_to_utf8(returnObjectAsJson));

          int64_t currentIndex = historyJson.at("currentIndex").is_number_unsigned() ? historyJson.at("currentIndex").get<int64_t>() : 0;
          std::vector<nlohmann::json> entries = historyJson.at("entries").is_array() ? historyJson.at("entries").get<std::vector<nlohmann::json>>() : std::vector<nlohmann::json>{};

          std::vector<std::shared_ptr<WebHistoryItem>> webHistoryItems;
          webHistoryItems.reserve(entries.size());
          int64_t i = 0;
          for (auto const& entry : entries) {
            int64_t offset = i - currentIndex;
            webHistoryItems.push_back(std::make_shared<WebHistoryItem>(
              entry.at("id").is_number_integer() ? entry.at("id").get<int64_t>() : std::optional<int64_t>{},
              i,
              offset,
              entry.at("userTypedURL").is_string() ? entry.at("userTypedURL").get<std::string>() : std::optional<std::string>{},
              entry.at("title").is_string() ? entry.at("title").get<std::string>() : std::optional<std::string>{},
              entry.at("url").is_string() ? entry.at("url").get<std::string>() : std::optional<std::string>{}
            ));
            i++;
          }

          completionHandler(std::make_unique<WebHistory>(currentIndex, webHistoryItems));
        }
        else {
          debugLog(errorCode);
          completionHandler(std::make_unique<WebHistory>(std::nullopt, std::nullopt));
        }

        return S_OK;
      }
    ).Get()));
  }

  void InAppWebView::evaluateJavascript(const std::string& source, const std::shared_ptr<ContentWorld> contentWorld, const std::function<void(std::string)> completionHandler) const
  {
    if (!webView || !userContentController) {
      if (completionHandler) {
        completionHandler("null");
      }
      return;
    }

    userContentController->createContentWorld(contentWorld,
      [=](const int& contextId)
      {
        nlohmann::json parameters = {
          {"expression", source},
          { "returnByValue", true }
        };

        if (contextId >= 0) {
          parameters["contextId"] = contextId;
        }

        auto hr = webView->CallDevToolsProtocolMethod(L"Runtime.evaluate", utf8_to_wide(parameters.dump()).c_str(), Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
          [this, completionHandler](HRESULT errorCode, LPCWSTR returnObjectAsJson)
          {
            nlohmann::json result;
            if (succeededOrLog(errorCode)) {
              nlohmann::json json = nlohmann::json::parse(wide_to_utf8(returnObjectAsJson));
              result = json["result"].contains("value") ? json["result"]["value"] : nlohmann::json{};
              if (json.contains("exceptionDetails")) {
                nlohmann::json exceptionDetails = json["exceptionDetails"];
                auto errorMessage = exceptionDetails.contains("exception") && exceptionDetails["exception"].contains("value")
                  ? exceptionDetails["exception"]["value"].dump() :
                  (result["value"].is_null() ? exceptionDetails["text"].get<std::string>() : result["value"].dump());
                result = nlohmann::json{};
                debugLog(exceptionDetails.dump());
                if (channelDelegate) {
                  channelDelegate->onConsoleMessage(errorMessage, 3);
                }
              }
            }
            if (completionHandler) {
              completionHandler(result.dump());
            }
            return S_OK;
          }
        ).Get());

        if (failedAndLog(hr) && completionHandler) {
          completionHandler("null");
        }
      });
  }

  void InAppWebView::callAsyncJavaScript(const std::string& functionBody, const std::string& argumentsAsJson, const std::shared_ptr<ContentWorld> contentWorld, const std::function<void(std::string)> completionHandler) const
  {
    if (!webView || !userContentController) {
      if (completionHandler) {
        completionHandler("null");
      }
      return;
    }

    userContentController->createContentWorld(contentWorld,
      [=](const int& contextId)
      {
        std::vector<std::string> functionArgumentNamesList;
        std::vector<std::string> functionArgumentValuesList;

        auto jsonVal = nlohmann::json::parse(argumentsAsJson);
        for (auto const& [key, val] : jsonVal.items()) {
          functionArgumentNamesList.push_back(key);
          functionArgumentValuesList.push_back(val.dump());
        }

        auto source = replace_all_copy(CALL_ASYNC_JAVASCRIPT_WRAPPER_JS, VAR_FUNCTION_ARGUMENT_NAMES, join(functionArgumentNamesList, ", "));
        replace_all(source, VAR_FUNCTION_ARGUMENT_VALUES, join(functionArgumentValuesList, ", "));
        replace_all(source, VAR_FUNCTION_BODY, functionBody);

        nlohmann::json parameters = {
          {"expression", source},
          {"awaitPromise", true},
          { "returnByValue", true }
        };

        if (contextId >= 0) {
          parameters["contextId"] = contextId;
        }

        auto hr = webView->CallDevToolsProtocolMethod(L"Runtime.evaluate", utf8_to_wide(parameters.dump()).c_str(), Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
          [this, completionHandler](HRESULT errorCode, LPCWSTR returnObjectAsJson)
          {
            nlohmann::json result = {
              {"value", nlohmann::json{}},
              {"error", nlohmann::json{}}
            };
            if (succeededOrLog(errorCode)) {
              nlohmann::json json = nlohmann::json::parse(wide_to_utf8(returnObjectAsJson));
              result["value"] = json["result"].contains("value") ? json["result"]["value"] : nlohmann::json{};
              if (json.contains("exceptionDetails")) {
                nlohmann::json exceptionDetails = json["exceptionDetails"];
                auto errorMessage = exceptionDetails.contains("exception") && exceptionDetails["exception"].contains("value")
                  ? exceptionDetails["exception"]["value"].dump() :
                  (result["value"].is_null() ? exceptionDetails["text"].get<std::string>() : result["value"].dump());
                result["value"] = nlohmann::json{};
                result["error"] = errorMessage;
                debugLog(exceptionDetails.dump());
                if (channelDelegate) {
                  channelDelegate->onConsoleMessage(errorMessage, 3);
                }
              }
            }
            if (completionHandler) {
              completionHandler(result.dump());
            }
            return S_OK;
          }
        ).Get());

        if (failedAndLog(hr) && completionHandler) {
          completionHandler("null");
        }
      });
  }

  void InAppWebView::addUserScript(const std::shared_ptr<UserScript> userScript) const
  {
    if (!userContentController) {
      return;
    }

    userContentController->addUserOnlyScript(userScript);
  }

  void InAppWebView::removeUserScript(const int64_t index, const std::shared_ptr<UserScript> userScript) const
  {
    if (!userContentController) {
      return;
    }

    userContentController->removeUserOnlyScriptAt(index, userScript->injectionTime);
  }

  void InAppWebView::removeUserScriptsByGroupName(const std::string& groupName) const
  {
    if (!userContentController) {
      return;
    }

    userContentController->removeUserOnlyScriptsByGroupName(groupName);
  }

  void InAppWebView::removeAllUserScripts() const
  {
    if (!userContentController) {
      return;
    }

    userContentController->removeAllUserOnlyScripts();
  }

  void InAppWebView::addWebMessageListener(const std::string& jsObjectName,
    const std::vector<std::string>& allowedOriginRules,
    const std::string& listenerId)
  {
    if (!webView || jsObjectName.empty() || !plugin || !plugin->registrar) {
      return;
    }

    std::set<std::string> originRulesSet(allowedOriginRules.begin(), allowedOriginRules.end());
    auto listener = std::make_unique<WebMessageListener>(
      plugin->registrar->messenger(), listenerId, jsObjectName, originRulesSet, this);
    webMessageListeners_[jsObjectName] = std::move(listener);

    std::string allowedOriginRulesJs = "[";
    for (size_t i = 0; i < allowedOriginRules.size(); ++i) {
      const std::string& rule = allowedOriginRules[i];
      if (rule == "*") {
        allowedOriginRulesJs += "'*'";
      }
      else {
        std::string scheme, host;
        int port = 0;

        size_t schemeEnd = rule.find("://");
        if (schemeEnd != std::string::npos) {
          scheme = rule.substr(0, schemeEnd);
          std::string rest = rule.substr(schemeEnd + 3);

          size_t portStart = rest.find(':');
          if (portStart != std::string::npos) {
            host = rest.substr(0, portStart);
            try {
              port = std::stoi(rest.substr(portStart + 1));
            }
            catch (...) {
              port = 0;
            }
          }
          else {
            host = rest;
          }
        }

        std::string hostEscaped = host;
        size_t pos = 0;
        while ((pos = hostEscaped.find("'", pos)) != std::string::npos) {
          hostEscaped.replace(pos, 1, "\\'");
          pos += 2;
        }

        allowedOriginRulesJs += "{scheme: '" + scheme + "', host: ";
        if (host.empty()) {
          allowedOriginRulesJs += "null";
        }
        else {
          allowedOriginRulesJs += "'" + hostEscaped + "'";
        }
        allowedOriginRulesJs += ", port: ";
        if (port == 0) {
          allowedOriginRulesJs += "null";
        }
        else {
          allowedOriginRulesJs += std::to_string(port);
        }
        allowedOriginRulesJs += "}";
      }
      if (i < allowedOriginRules.size() - 1) {
        allowedOriginRulesJs += ", ";
      }
    }
    allowedOriginRulesJs += "]";

    std::string jsSource = WebMessageListenerJS::createWebMessageListenerInjectionJs(
      jsObjectName, allowedOriginRulesJs);

    std::string groupName = "WebMessageListener-" + jsObjectName;

    auto userScript = std::make_shared<UserScript>(
      groupName,
      jsSource,
      UserScriptInjectionTime::atDocumentStart,
      true,
      std::nullopt,
      ContentWorld::page()
    );

    if (userContentController) {
      userContentController->addUserOnlyScript(userScript);
    }
  }

  void InAppWebView::createWebMessageChannel(
    const std::function<void(const std::optional<std::string>&)> callback)
  {
    if (!webView || !plugin || !plugin->registrar) {
      if (callback) callback(std::nullopt);
      return;
    }

    std::string channelId = get_uuid();
    std::string js = WebMessageChannelJS::createWebMessageChannelJs(channelId);

    evaluateJavascript(js, ContentWorld::page(), [this, callback, channelId](const std::string& result)
      {
        if (!result.empty() && result != "null") {
          auto channel = std::make_unique<WebMessageChannel>(
            plugin->registrar->messenger(), channelId, this);
          webMessageChannels_[channelId] = std::move(channel);
          if (callback) callback(channelId);
        }
        else {
          if (callback) callback(std::nullopt);
        }
      });
  }

  WebMessageChannel* InAppWebView::getWebMessageChannel(const std::string& channelId) const
  {
    auto it = webMessageChannels_.find(channelId);
    if (it != webMessageChannels_.end()) {
      return it->second.get();
    }
    return nullptr;
  }

  void InAppWebView::postWebMessage(const std::string& messageData,
    const std::string& targetOrigin,
    int64_t messageType)
  {
    if (!webView) return;

    std::string messageDataJs;
    if (messageType == 1) {
      messageDataJs = "new Uint8Array([" + messageData + "]).buffer";
    }
    else {
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

    std::string js = WebMessageChannelJS::postWebMessageJs(messageDataJs, targetOrigin, "");
    evaluateJavascript(js, ContentWorld::page(), nullptr);
  }

  void InAppWebView::setWebMessageCallback(const std::string& channelId, int portIndex)
  {
    if (!webView || channelId.empty()) return;

    std::string js = WebMessageChannelJS::setWebMessageCallbackJs(channelId, portIndex);
    evaluateJavascript(js, ContentWorld::page(), nullptr);
  }

  void InAppWebView::postWebMessageOnPort(const std::string& channelId, int portIndex,
    const std::string& messageData, int64_t messageType)
  {
    if (!webView || channelId.empty()) return;

    std::string messageDataJs;
    if (messageType == 1) {
      messageDataJs = "new Uint8Array([" + messageData + "]).buffer";
    }
    else {
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

    std::string js = WebMessageChannelJS::postMessageJs(channelId, portIndex, messageDataJs);
    evaluateJavascript(js, ContentWorld::page(), nullptr);
  }

  void InAppWebView::closeWebMessagePort(const std::string& channelId, int portIndex)
  {
    if (!webView || channelId.empty()) return;

    std::string js = WebMessageChannelJS::closePortJs(channelId, portIndex);
    evaluateJavascript(js, ContentWorld::page(), nullptr);
  }

  void InAppWebView::disposeWebMessageChannel(const std::string& channelId)
  {
    if (channelId.empty()) return;

    if (webView) {
      std::string js = WebMessageChannelJS::disposeChannelJs(channelId);
      evaluateJavascript(js, ContentWorld::page(), nullptr);
    }

    auto it = webMessageChannels_.find(channelId);
    if (it != webMessageChannels_.end() && it->second) {
      it->second->dispose();
    }
    webMessageChannels_.erase(channelId);
  }

  void InAppWebView::addWebNotificationController(const std::string& id, std::shared_ptr<WebNotificationController> controller)
  {
    if (id.empty() || !controller) return;
    webNotificationControllers_[id] = std::move(controller);
  }

  WebNotificationController* InAppWebView::getWebNotificationController(const std::string& id) const
  {
    auto it = webNotificationControllers_.find(id);
    return it != webNotificationControllers_.end() ? it->second.get() : nullptr;
  }

  void InAppWebView::eraseWebNotificationController(const std::string& id)
  {
    webNotificationControllers_.erase(id);
  }

  void InAppWebView::disposeAllWebNotificationControllers()
  {
    // First pass: invalidate parent pointers to prevent controllers from trying
    // to erase themselves during dispose (since we're destroying the webview)
    for (auto& pair : webNotificationControllers_) {
      if (pair.second) {
        pair.second->invalidateParentWebView();
      }
    }
    // Second pass: now safe to dispose (won't try to access webview)
    for (auto& pair : webNotificationControllers_) {
      if (pair.second) {
        pair.second->dispose();
      }
    }
    webNotificationControllers_.clear();
  }

  void InAppWebView::addPrintJobController(const std::string& id, std::shared_ptr<PrintJobController> controller)
  {
    if (id.empty() || !controller) return;
    printJobControllers_[id] = std::move(controller);
  }

  PrintJobController* InAppWebView::getPrintJobController(const std::string& id) const
  {
    auto it = printJobControllers_.find(id);
    return it != printJobControllers_.end() ? it->second.get() : nullptr;
  }

  void InAppWebView::erasePrintJobController(const std::string& id)
  {
    printJobControllers_.erase(id);
  }

  void InAppWebView::disposeAllPrintJobControllers()
  {
    // First pass: invalidate parent pointers to prevent controllers from trying
    // to erase themselves during dispose (since we're destroying the webview)
    for (auto& pair : printJobControllers_) {
      if (pair.second) {
        pair.second->invalidateParentWebView();
      }
    }
    // Second pass: now safe to dispose (won't try to access webview)
    for (auto& pair : printJobControllers_) {
      if (pair.second) {
        pair.second->dispose();
      }
    }
    printJobControllers_.clear();
  }

  void InAppWebView::printCurrentPage(std::shared_ptr<PrintJobSettings> settings,
    const std::function<void(const std::optional<std::string>&)> completionHandler)
  {
    if (!webView || !webViewEnv) {
      if (completionHandler) {
        completionHandler(std::nullopt);
      }
      return;
    }

    wil::com_ptr<ICoreWebView2_16> webView16;
    if (failedAndLog(webView->QueryInterface(IID_PPV_ARGS(&webView16))) || !webView16) {
      if (completionHandler) {
        completionHandler(std::nullopt);
      }
      return;
    }

    // Check if showUI is true - use ShowPrintUI instead of Print
    bool showUI = settings && settings->showUI.value_or(true);
    
    if (showUI) {
      // Use ShowPrintUI to display the print dialog
      COREWEBVIEW2_PRINT_DIALOG_KIND dialogKind = COREWEBVIEW2_PRINT_DIALOG_KIND_BROWSER;
      if (settings && settings->printDialogKind.has_value()) {
        dialogKind = static_cast<COREWEBVIEW2_PRINT_DIALOG_KIND>(settings->printDialogKind.value());
      }
      
      if (failedAndLog(webView16->ShowPrintUI(dialogKind))) {
        if (completionHandler) {
          completionHandler(std::nullopt);
        }
        return;
      }
      
      // ShowPrintUI is fire-and-forget, return immediately with no job ID
      if (completionHandler) {
        completionHandler(std::nullopt);
      }
      return;
    }

    // Generate print job ID if handledByClient is true
    std::optional<std::string> printJobId = std::nullopt;
    if (settings && settings->handledByClient.value_or(false)) {
      printJobId = get_uuid();
    }

    // Create print settings using PrintJobSettings helper method
    wil::com_ptr<ICoreWebView2Environment6> environment6;
    if (failedAndLog(webViewEnv->QueryInterface(IID_PPV_ARGS(&environment6))) || !environment6) {
      if (completionHandler) {
        completionHandler(std::nullopt);
      }
      return;
    }

    wil::com_ptr<ICoreWebView2PrintSettings> printSettings;
    if (settings) {
      printSettings = settings->createPrintSettings(environment6.get());
    }
    else {
      // Create default print settings if no settings provided
      if (failedAndLog(environment6->CreatePrintSettings(&printSettings))) {
        printSettings = nullptr;
      }
    }

    if (!printSettings) {
      if (completionHandler) {
        completionHandler(std::nullopt);
      }
      return;
    }

    // Create PrintJobController if handledByClient
    std::shared_ptr<PrintJobController> printJobController = nullptr;
    if (printJobId.has_value() && printJobManager) {
      printJobController = printJobManager->createPrintJobController(printJobId.value(), settings);
      if (printJobController) {
        addPrintJobController(printJobId.value(), printJobController);
      }
    }

    // Capture for the async callback
    auto printJobControllerCapture = printJobController;

    HRESULT printHr = webView16->Print(printSettings.get(), Callback<ICoreWebView2PrintCompletedHandler>(
      [this, printJobId, printJobControllerCapture](HRESULT errorCode, COREWEBVIEW2_PRINT_STATUS printStatus) -> HRESULT
      {
        bool success = SUCCEEDED(errorCode) && printStatus == COREWEBVIEW2_PRINT_STATUS_SUCCEEDED;

        if (printJobControllerCapture) {
          // Notify the print job controller of completion
          std::optional<std::string> error = std::nullopt;
          if (!success) {
            if (printStatus == COREWEBVIEW2_PRINT_STATUS_PRINTER_UNAVAILABLE) {
              error = "Printer unavailable";
            }
            else if (errorCode == E_INVALIDARG) {
              error = "Invalid print settings";
            }
            else if (errorCode == E_ABORT) {
              error = "Print operation aborted - another print job in progress";
            }
            else {
              error = "Print operation failed with status " + std::to_string(static_cast<int>(printStatus));
            }
          }
          printJobControllerCapture->onComplete(success, error);
        }

        return S_OK;
      }).Get());

    // Return immediately with the print job ID - don't wait for Print callback
    // The callback will notify completion via PrintJobController.onComplete
    if (failedAndLog(printHr)) {
      if (completionHandler) {
        completionHandler(std::nullopt);
      }
    }
    else {
      if (completionHandler) {
        completionHandler(printJobId);
      }
    }
  }

  void InAppWebView::createPdf(std::shared_ptr<PrintJobSettings> settings,
    const std::function<void(const std::optional<std::vector<uint8_t>>&)> completionHandler)
  {
    if (!webView || !webViewEnv) {
      if (completionHandler) {
        completionHandler(std::nullopt);
      }
      return;
    }

    wil::com_ptr<ICoreWebView2_16> webView16;
    if (failedAndLog(webView->QueryInterface(IID_PPV_ARGS(&webView16))) || !webView16) {
      if (completionHandler) {
        completionHandler(std::nullopt);
      }
      return;
    }

    // Create print settings using PrintJobSettings helper method or default
    wil::com_ptr<ICoreWebView2Environment6> environment6;
    if (failedAndLog(webViewEnv->QueryInterface(IID_PPV_ARGS(&environment6))) || !environment6) {
      if (completionHandler) {
        completionHandler(std::nullopt);
      }
      return;
    }

    wil::com_ptr<ICoreWebView2PrintSettings> printSettings;
    if (settings) {
      printSettings = settings->createPrintSettings(environment6.get());
    }
    else {
      // Create default print settings if no settings provided
      if (failedAndLog(environment6->CreatePrintSettings(&printSettings))) {
        printSettings = nullptr;
      }
    }

    if (!printSettings) {
      if (completionHandler) {
        completionHandler(std::nullopt);
      }
      return;
    }

    // Perform the PrintToPdfStream operation
    auto completionHandlerCapture = completionHandler;

    webView16->PrintToPdfStream(printSettings.get(), Callback<ICoreWebView2PrintToPdfStreamCompletedHandler>(
      [completionHandlerCapture](HRESULT errorCode, IStream* pdfStream) -> HRESULT
      {
        if (FAILED(errorCode) || !pdfStream) {
          if (completionHandlerCapture) {
            completionHandlerCapture(std::nullopt);
          }
          return S_OK;
        }

        // Read the PDF data from the stream using utility function
        auto pdfData = readStreamBytes(pdfStream);

        if (completionHandlerCapture) {
          completionHandlerCapture(pdfData);
        }

        return S_OK;
      }).Get());
  }

  void InAppWebView::takeScreenshot(const std::optional<std::shared_ptr<ScreenshotConfiguration>> screenshotConfiguration, const std::function<void(const std::optional<std::string>)> completionHandler) const
  {
    if (!webView) {
      if (completionHandler) {
        completionHandler(std::nullopt);
      }
      return;
    }

    nlohmann::json parameters = {};
    if (screenshotConfiguration.has_value()) {
      auto& scp = screenshotConfiguration.value();
      parameters["format"] = to_lowercase_copy(CompressFormatToString(scp->compressFormat));
      if (scp->compressFormat == CompressFormat::jpeg) {
        parameters["quality"] = scp->quality;
      }
      if (scp->rect.has_value()) {
        auto& rect = scp->rect.value();
        parameters["clip"] = {
          {"x", rect->x},
          {"y", rect->y},
          {"width", rect->width},
          {"height", rect->height},
          {"scale", scaleFactor_}
        };
      }
    }

    auto hr = webView->CallDevToolsProtocolMethod(L"Page.captureScreenshot", utf8_to_wide(parameters.dump()).c_str(), Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
      [this, completionHandler](HRESULT errorCode, LPCWSTR returnObjectAsJson)
      {
        std::optional<std::string> result = std::nullopt;
        if (succeededOrLog(errorCode)) {
          nlohmann::json json = nlohmann::json::parse(wide_to_utf8(returnObjectAsJson));
          result = json["data"].get<std::string>();
        }
        if (completionHandler) {
          completionHandler(result);
        }
        return S_OK;
      }
    ).Get());
    if (failedAndLog(hr) && completionHandler) {
      completionHandler(std::nullopt);
    }
  }

  void InAppWebView::setSettings(const std::shared_ptr<InAppWebViewSettings> newSettings, const flutter::EncodableMap& newSettingsMap)
  {
    wil::com_ptr<ICoreWebView2Settings> webView2Settings;
    if (succeededOrLog(webView->get_Settings(&webView2Settings))) {
      if (fl_map_contains_not_null(newSettingsMap, "javaScriptEnabled") && settings->javaScriptEnabled != newSettings->javaScriptEnabled) {
        webView2Settings->put_IsScriptEnabled(newSettings->javaScriptEnabled);
      }

      if (fl_map_contains_not_null(newSettingsMap, "supportZoom") && settings->supportZoom != newSettings->supportZoom) {
        webView2Settings->put_IsZoomControlEnabled(newSettings->supportZoom);
      }

      if (fl_map_contains_not_null(newSettingsMap, "isInspectable") && settings->isInspectable != newSettings->isInspectable) {
        webView2Settings->put_AreDevToolsEnabled(newSettings->isInspectable);
      }

      if (fl_map_contains_not_null(newSettingsMap, "disableContextMenu") && settings->disableContextMenu != newSettings->disableContextMenu) {
        webView2Settings->put_AreDefaultContextMenusEnabled(!newSettings->disableContextMenu);
      }

      if (fl_map_contains_not_null(newSettingsMap, "disableDefaultErrorPage") && settings->disableDefaultErrorPage != newSettings->disableDefaultErrorPage) {
        webView2Settings->put_IsBuiltInErrorPageEnabled(!newSettings->disableDefaultErrorPage);
      }

      if (fl_map_contains_not_null(newSettingsMap, "statusBarEnabled") && settings->statusBarEnabled != newSettings->statusBarEnabled) {
        webView2Settings->put_IsStatusBarEnabled(newSettings->statusBarEnabled);
      }

      if (auto webView2Settings2 = webView2Settings.try_query<ICoreWebView2Settings2>()) {
        if (fl_map_contains_not_null(newSettingsMap, "userAgent") && !string_equals(settings->userAgent, newSettings->userAgent)) {
          webView2Settings2->put_UserAgent(utf8_to_wide(newSettings->userAgent).c_str());
        }
      }

      if (auto webView2Settings3 = webView2Settings.try_query<ICoreWebView2Settings3>()) {
        if (fl_map_contains_not_null(newSettingsMap, "browserAcceleratorKeysEnabled") && settings->browserAcceleratorKeysEnabled != newSettings->browserAcceleratorKeysEnabled) {
          webView2Settings3->put_AreBrowserAcceleratorKeysEnabled(newSettings->browserAcceleratorKeysEnabled);
        }
      }

      if (auto webView2Settings4 = webView2Settings.try_query<ICoreWebView2Settings4>()) {
        if (fl_map_contains_not_null(newSettingsMap, "generalAutofillEnabled") && settings->generalAutofillEnabled != newSettings->generalAutofillEnabled) {
          webView2Settings4->put_IsGeneralAutofillEnabled(newSettings->generalAutofillEnabled);
        }
        if (fl_map_contains_not_null(newSettingsMap, "passwordAutosaveEnabled") && settings->passwordAutosaveEnabled != newSettings->passwordAutosaveEnabled) {
          webView2Settings4->put_IsPasswordAutosaveEnabled(newSettings->passwordAutosaveEnabled);
        }
      }

      if (auto webView2Settings5 = webView2Settings.try_query<ICoreWebView2Settings5>()) {
        if (fl_map_contains_not_null(newSettingsMap, "pinchZoomEnabled") && settings->pinchZoomEnabled != newSettings->pinchZoomEnabled) {
          webView2Settings5->put_IsPinchZoomEnabled(newSettings->pinchZoomEnabled);
        }
      }

      if (auto webView2Settings6 = webView2Settings.try_query<ICoreWebView2Settings6>()) {
        if (fl_map_contains_not_null(newSettingsMap, "allowsBackForwardNavigationGestures") && settings->allowsBackForwardNavigationGestures != newSettings->allowsBackForwardNavigationGestures) {
          webView2Settings6->put_IsSwipeNavigationEnabled(newSettings->allowsBackForwardNavigationGestures);
        }
      }

      if (auto webView2Settings7 = webView2Settings.try_query<ICoreWebView2Settings7>()) {
        if (fl_map_contains_not_null(newSettingsMap, "hiddenPdfToolbarItems") && settings->hiddenPdfToolbarItems != newSettings->hiddenPdfToolbarItems) {
          webView2Settings7->put_HiddenPdfToolbarItems((COREWEBVIEW2_PDF_TOOLBAR_ITEMS)newSettings->hiddenPdfToolbarItems);
        }
      }

      if (auto webView2Settings8 = webView2Settings.try_query<ICoreWebView2Settings8>()) {
        if (fl_map_contains_not_null(newSettingsMap, "reputationCheckingRequired") && settings->reputationCheckingRequired != newSettings->reputationCheckingRequired) {
          webView2Settings8->put_IsReputationCheckingRequired(newSettings->reputationCheckingRequired);
        }
      }

      if (auto webView2Settings9 = webView2Settings.try_query<ICoreWebView2Settings9>()) {
        if (fl_map_contains_not_null(newSettingsMap, "nonClientRegionSupportEnabled") && settings->nonClientRegionSupportEnabled != newSettings->nonClientRegionSupportEnabled) {
          webView2Settings9->put_IsNonClientRegionSupportEnabled(newSettings->nonClientRegionSupportEnabled);
        }
      }
    }

    if (auto webViewController2 = webViewController.try_query<ICoreWebView2Controller2>()) {
      if (fl_map_contains_not_null(newSettingsMap, "transparentBackground") && settings->transparentBackground != newSettings->transparentBackground) {
        BYTE alpha = newSettings->transparentBackground ? 0 : 255;
        webViewController2->put_DefaultBackgroundColor({ alpha, 255, 255, 255 });
      }
    }

    settings = newSettings;
  }

  flutter::EncodableValue InAppWebView::getSettings() const
  {
    if (!settings || !webView) {
      return make_fl_value();
    }

    return settings->getRealSettings(this);
  }

  void InAppWebView::openDevTools() const
  {
    if (!webView) {
      return;
    }

    failedLog(webView->OpenDevToolsWindow());
  }

  void InAppWebView::callDevToolsProtocolMethod(const std::string& methodName, const std::optional<std::string>& parametersAsJson, const std::function<void(const HRESULT& errorCode, const std::optional<std::string>&)> completionHandler) const
  {
    if (!webView) {
      if (completionHandler) {
        completionHandler(S_OK, std::nullopt);
      }
      return;
    }

    auto hr = webView->CallDevToolsProtocolMethod(
      utf8_to_wide(methodName).c_str(),
      !parametersAsJson.has_value() || parametersAsJson.value().empty() ? L"{}" : utf8_to_wide(parametersAsJson.value()).c_str(),
      Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
        [completionHandler](HRESULT errorCode, LPCWSTR returnObjectAsJson)
        {
          failedLog(errorCode);
          if (completionHandler) {
            completionHandler(errorCode, wide_to_utf8(returnObjectAsJson));
          }
          return S_OK;
        }
      ).Get());

    if (failedAndLog(hr) && completionHandler) {
      completionHandler(hr, std::nullopt);
    }
  }

  void InAppWebView::addDevToolsProtocolEventListener(const std::string& eventName)
  {
    if (map_contains(devToolsProtocolEventListener_, eventName)) {
      return;
    }

    wil::com_ptr<ICoreWebView2DevToolsProtocolEventReceiver> eventReceiver;
    if (succeededOrLog(webView->GetDevToolsProtocolEventReceiver(utf8_to_wide(eventName).c_str(), &eventReceiver))) {
      EventRegistrationToken token = {};
      auto hr = eventReceiver->add_DevToolsProtocolEventReceived(
        Callback<ICoreWebView2DevToolsProtocolEventReceivedEventHandler>(
          [this, eventName](
            ICoreWebView2* sender,
            ICoreWebView2DevToolsProtocolEventReceivedEventArgs* args) -> HRESULT
          {
            if (!channelDelegate) {
              return S_OK;
            }

            wil::unique_cotaskmem_string json;
            failedLog(args->get_ParameterObjectAsJson(&json));
            channelDelegate->onDevToolsProtocolEventReceived(eventName, wide_to_utf8(json.get()));

            return S_OK;
          })
        .Get(), &token);
      if (succeededOrLog(hr)) {
        devToolsProtocolEventListener_.insert({ eventName, std::make_pair(std::move(eventReceiver), token) });
      }
    }
  }

  void InAppWebView::removeDevToolsProtocolEventListener(const std::string& eventName)
  {
    if (map_contains(devToolsProtocolEventListener_, eventName)) {
      auto eventReceiver = devToolsProtocolEventListener_.at(eventName).first;
      auto token = devToolsProtocolEventListener_.at(eventName).second;
      eventReceiver->remove_DevToolsProtocolEventReceived(token);
      devToolsProtocolEventListener_.erase(eventName);
    }
  }


  void InAppWebView::pause() const
  {
    wil::com_ptr<ICoreWebView2_3> webView3;
    if (SUCCEEDED(webView->QueryInterface(IID_PPV_ARGS(&webView3))) && succeededOrLog(webViewController->put_IsVisible(false))) {
      failedLog(webView3->TrySuspend(Callback<ICoreWebView2TrySuspendCompletedHandler>(
        [this](HRESULT errorCode, BOOL isSuccessful) -> HRESULT
        {
          failedLog(errorCode);
          return S_OK;
        })
        .Get()));
    }
  }

  void InAppWebView::resume() const
  {
    wil::com_ptr<ICoreWebView2_3> webView3;
    if (SUCCEEDED(webView->QueryInterface(IID_PPV_ARGS(&webView3))) && succeededOrLog(webViewController->put_IsVisible(true))) {
      failedLog(webView3->Resume());
    }
  }


  void InAppWebView::getCertificate(const std::function<void(const std::optional<std::unique_ptr<SslCertificate>>)> completionHandler) const
  {
    auto url = getUrl();
    if (!webView || !url.has_value()) {
      if (completionHandler) {
        completionHandler(std::nullopt);
      }
      return;
    }

    nlohmann::json parameters = {
      {"origin", url.value()}
    };

    auto hr = webView->CallDevToolsProtocolMethod(L"Network.getCertificate", utf8_to_wide(parameters.dump()).c_str(), Callback<ICoreWebView2CallDevToolsProtocolMethodCompletedHandler>(
      [this, completionHandler](HRESULT errorCode, LPCWSTR returnObjectAsJson)
      {
        std::optional<std::unique_ptr<SslCertificate>> result = std::nullopt;
        if (succeededOrLog(errorCode)) {
          nlohmann::json json = nlohmann::json::parse(wide_to_utf8(returnObjectAsJson));
          if (json.at("tableNames").is_array()) {
            auto tableNames = json.at("tableNames").get<std::vector<std::string>>();
            if (tableNames.size() > 0) {
              result = std::make_unique<SslCertificate>(tableNames.at(0));
            }
          }
        }
        if (completionHandler) {
          completionHandler(std::move(result));
        }
        return S_OK;
      }
    ).Get());
    if (failedAndLog(hr) && completionHandler) {
      completionHandler(std::nullopt);
    }
  }

  void InAppWebView::clearSslPreferences(const std::function<void()> completionHandler) const
  {
    if (!webView) {
      if (completionHandler) {
        completionHandler();
      }
      return;
    }

    if (auto webView14 = webView.try_query<ICoreWebView2_14>()) {
      auto hr = webView14->ClearServerCertificateErrorActions(Callback<ICoreWebView2ClearServerCertificateErrorActionsCompletedHandler>(
        [completionHandler](HRESULT errorCode)
        {
          failedAndLog(errorCode);
          if (completionHandler) {
            completionHandler();
          }
          return S_OK;
        }
      ).Get());

      if (failedAndLog(hr) && completionHandler) {
        completionHandler();
      }
      return;
    }

    if (completionHandler) {
      completionHandler();
    }
  }

  bool InAppWebView::isInterfaceSupported(const std::string& interfaceName) const
  {
    if (!webView) {
      return false;
    }

    if (string_equals(interfaceName, "ICoreWebView2") || starts_with(interfaceName, std::string{ "ICoreWebView2_" })) {
      switch (string_hash(interfaceName)) {
      case string_hash("ICoreWebView2"):
        return webView.try_query<ICoreWebView2>() != nullptr;
      case string_hash("ICoreWebView2_2"):
        return webView.try_query<ICoreWebView2_2>() != nullptr;
      case string_hash("ICoreWebView2_3"):
        return webView.try_query<ICoreWebView2_3>() != nullptr;
      case string_hash("ICoreWebView2_4"):
        return webView.try_query<ICoreWebView2_4>() != nullptr;
      case string_hash("ICoreWebView2_5"):
        return webView.try_query<ICoreWebView2_5>() != nullptr;
      case string_hash("ICoreWebView2_6"):
        return webView.try_query<ICoreWebView2_6>() != nullptr;
      case string_hash("ICoreWebView2_7"):
        return webView.try_query<ICoreWebView2_7>() != nullptr;
      case string_hash("ICoreWebView2_8"):
        return webView.try_query<ICoreWebView2_8>() != nullptr;
      case string_hash("ICoreWebView2_9"):
        return webView.try_query<ICoreWebView2_9>() != nullptr;
      case string_hash("ICoreWebView2_10"):
        return webView.try_query<ICoreWebView2_10>() != nullptr;
      case string_hash("ICoreWebView2_11"):
        return webView.try_query<ICoreWebView2_11>() != nullptr;
      case string_hash("ICoreWebView2_12"):
        return webView.try_query<ICoreWebView2_12>() != nullptr;
      case string_hash("ICoreWebView2_13"):
        return webView.try_query<ICoreWebView2_13>() != nullptr;
      case string_hash("ICoreWebView2_14"):
        return webView.try_query<ICoreWebView2_14>() != nullptr;
      case string_hash("ICoreWebView2_15"):
        return webView.try_query<ICoreWebView2_15>() != nullptr;
      case string_hash("ICoreWebView2_16"):
        return webView.try_query<ICoreWebView2_16>() != nullptr;
      case string_hash("ICoreWebView2_17"):
        return webView.try_query<ICoreWebView2_17>() != nullptr;
      case string_hash("ICoreWebView2_18"):
        return webView.try_query<ICoreWebView2_18>() != nullptr;
      case string_hash("ICoreWebView2_19"):
        return webView.try_query<ICoreWebView2_19>() != nullptr;
      case string_hash("ICoreWebView2_20"):
        return webView.try_query<ICoreWebView2_20>() != nullptr;
      case string_hash("ICoreWebView2_21"):
        return webView.try_query<ICoreWebView2_21>() != nullptr;
      case string_hash("ICoreWebView2_22"):
        return webView.try_query<ICoreWebView2_22>() != nullptr;
      case string_hash("ICoreWebView2_23"):
        return webView.try_query<ICoreWebView2_23>() != nullptr;
      case string_hash("ICoreWebView2_24"):
        return webView.try_query<ICoreWebView2_24>() != nullptr;
      case string_hash("ICoreWebView2_25"):
        return webView.try_query<ICoreWebView2_25>() != nullptr;
      case string_hash("ICoreWebView2_26"):
        return webView.try_query<ICoreWebView2_26>() != nullptr;
      case string_hash("ICoreWebView2_27"):
        return webView.try_query<ICoreWebView2_27>() != nullptr;
      case string_hash("ICoreWebView2_28"):
        return webView.try_query<ICoreWebView2_28>() != nullptr;
      default:
        return false;
      }
    }

    wil::com_ptr<ICoreWebView2Settings> webView2Settings;
    if (succeededOrLog(webView->get_Settings(&webView2Settings))) {
      if (starts_with(interfaceName, std::string{ "ICoreWebView2Settings" })) {
        switch (string_hash(interfaceName)) {
        case string_hash("ICoreWebView2Settings"):
          return webView2Settings.try_query<ICoreWebView2Settings>() != nullptr;
        case string_hash("ICoreWebView2Settings2"):
          return webView2Settings.try_query<ICoreWebView2Settings2>() != nullptr;
        case string_hash("ICoreWebView2Settings3"):
          return webView2Settings.try_query<ICoreWebView2Settings3>() != nullptr;
        case string_hash("ICoreWebView2Settings4"):
          return webView2Settings.try_query<ICoreWebView2Settings4>() != nullptr;
        case string_hash("ICoreWebView2Settings5"):
          return webView2Settings.try_query<ICoreWebView2Settings5>() != nullptr;
        case string_hash("ICoreWebView2Settings6"):
          return webView2Settings.try_query<ICoreWebView2Settings6>() != nullptr;
        case string_hash("ICoreWebView2Settings7"):
          return webView2Settings.try_query<ICoreWebView2Settings7>() != nullptr;
        case string_hash("ICoreWebView2Settings8"):
          return webView2Settings.try_query<ICoreWebView2Settings8>() != nullptr;
        case string_hash("ICoreWebView2Settings9"):
          return webView2Settings.try_query<ICoreWebView2Settings9>() != nullptr;
        default:
          return false;
        }
      }
    }

    if (starts_with(interfaceName, std::string{ "ICoreWebView2Controller" }) && webViewController) {
      switch (string_hash(interfaceName)) {
      case string_hash("ICoreWebView2Controller"):
        return webViewController.try_query<ICoreWebView2Controller>() != nullptr;
      case string_hash("ICoreWebView2Controller2"):
        return webViewController.try_query<ICoreWebView2Controller2>() != nullptr;
      case string_hash("ICoreWebView2Controller3"):
        return webViewController.try_query<ICoreWebView2Controller3>() != nullptr;
      case string_hash("ICoreWebView2Controller4"):
        return webViewController.try_query<ICoreWebView2Controller4>() != nullptr;
      default:
        return false;
      }
    }

    if (starts_with(interfaceName, std::string{ "ICoreWebView2CompositionController" }) && webViewCompositionController) {
      switch (string_hash(interfaceName)) {
      case string_hash("ICoreWebView2CompositionController"):
        return webViewCompositionController.try_query<ICoreWebView2CompositionController>() != nullptr;
      case string_hash("ICoreWebView2CompositionController2"):
        return webViewCompositionController.try_query<ICoreWebView2CompositionController2>() != nullptr;
      case string_hash("ICoreWebView2CompositionController3"):
        return webViewCompositionController.try_query<ICoreWebView2CompositionController3>() != nullptr;
      case string_hash("ICoreWebView2CompositionController4"):
        return webViewCompositionController.try_query<ICoreWebView2CompositionController4>() != nullptr;
      default:
        return false;
      }
    }

    if (starts_with(interfaceName, std::string{ "ICoreWebView2Environment" }) && webViewEnv) {
      switch (string_hash(interfaceName)) {
      case string_hash("ICoreWebView2Environment"):
        return webViewEnv.try_query<ICoreWebView2Environment>() != nullptr;
      case string_hash("ICoreWebView2Environment2"):
        return webViewEnv.try_query<ICoreWebView2Environment2>() != nullptr;
      case string_hash("ICoreWebView2Environment3"):
        return webViewEnv.try_query<ICoreWebView2Environment3>() != nullptr;
      case string_hash("ICoreWebView2Environment4"):
        return webViewEnv.try_query<ICoreWebView2Environment4>() != nullptr;
      case string_hash("ICoreWebView2Environment5"):
        return webViewEnv.try_query<ICoreWebView2Environment5>() != nullptr;
      case string_hash("ICoreWebView2Environment6"):
        return webViewEnv.try_query<ICoreWebView2Environment6>() != nullptr;
      case string_hash("ICoreWebView2Environment7"):
        return webViewEnv.try_query<ICoreWebView2Environment7>() != nullptr;
      case string_hash("ICoreWebView2Environment8"):
        return webViewEnv.try_query<ICoreWebView2Environment8>() != nullptr;
      case string_hash("ICoreWebView2Environment9"):
        return webViewEnv.try_query<ICoreWebView2Environment9>() != nullptr;
      case string_hash("ICoreWebView2Environment10"):
        return webViewEnv.try_query<ICoreWebView2Environment10>() != nullptr;
      case string_hash("ICoreWebView2Environment11"):
        return webViewEnv.try_query<ICoreWebView2Environment11>() != nullptr;
      case string_hash("ICoreWebView2Environment12"):
        return webViewEnv.try_query<ICoreWebView2Environment12>() != nullptr;
      case string_hash("ICoreWebView2Environment13"):
        return webViewEnv.try_query<ICoreWebView2Environment13>() != nullptr;
      case string_hash("ICoreWebView2Environment14"):
        return webViewEnv.try_query<ICoreWebView2Environment14>() != nullptr;
      case string_hash("ICoreWebView2Environment15"):
        return webViewEnv.try_query<ICoreWebView2Environment15>() != nullptr;
      default:
        return false;
      }
    }

    return false;
  }

  double InAppWebView::getZoomScale() const
  {
    return zoomScaleFactor_;
  }

  int64_t InAppWebView::getProgress() const
  {
    // Return the progress value tracked natively through navigation events:
    // NavigationStarting (0), ContentLoading (33), DOMContentLoaded (66), NavigationCompleted (100)
    return progress_;
  }

  void InAppWebView::scrollTo(const int64_t& x, const int64_t& y, const bool& animated) const
  {
    if (!webView) {
      return;
    }

    std::string script = animated
      ? "window.scrollTo({top: " + std::to_string(y) + ", left: " + std::to_string(x) + ", behavior: 'smooth'});"
      : "window.scrollTo(" + std::to_string(x) + ", " + std::to_string(y) + ");";
    evaluateJavascript(script, ContentWorld::page(), nullptr);
  }

  void InAppWebView::scrollBy(const int64_t& x, const int64_t& y, const bool& animated) const
  {
    if (!webView) {
      return;
    }

    std::string script = animated
      ? "window.scrollBy({top: " + std::to_string(y) + ", left: " + std::to_string(x) + ", behavior: 'smooth'});"
      : "window.scrollBy(" + std::to_string(x) + ", " + std::to_string(y) + ");";
    evaluateJavascript(script, ContentWorld::page(), nullptr);
  }

  void InAppWebView::getScrollX(const std::function<void(const std::optional<int64_t>)> completionHandler) const
  {
    if (!webView || !completionHandler) {
      if (completionHandler) completionHandler(std::nullopt);
      return;
    }

    evaluateJavascript(
      "window.scrollX || window.pageXOffset || document.documentElement.scrollLeft || 0",
      ContentWorld::page(),
      [completionHandler](const std::string& value) {
        try {
          auto scrollX = std::stoll(value);
          completionHandler(scrollX);
        }
        catch (...) {
          completionHandler(0);
        }
      }
    );
  }

  void InAppWebView::getScrollY(const std::function<void(const std::optional<int64_t>)> completionHandler) const
  {
    if (!webView || !completionHandler) {
      if (completionHandler) completionHandler(std::nullopt);
      return;
    }

    evaluateJavascript(
      "window.scrollY || window.pageYOffset || document.documentElement.scrollTop || 0",
      ContentWorld::page(),
      [completionHandler](const std::string& value) {
        try {
          auto scrollY = std::stoll(value);
          completionHandler(scrollY);
        }
        catch (...) {
          completionHandler(0);
        }
      }
    );
  }

  void InAppWebView::getContentHeight(const std::function<void(const std::optional<int64_t>)> completionHandler) const
  {
    if (!webView || !completionHandler) {
      if (completionHandler) completionHandler(std::nullopt);
      return;
    }

    evaluateJavascript(
      "Math.max(document.body.scrollHeight, document.documentElement.scrollHeight)",
      ContentWorld::page(),
      [completionHandler](const std::string& value) {
        try {
          auto height = std::stoll(value);
          completionHandler(height);
        }
        catch (...) {
          completionHandler(0);
        }
      }
    );
  }

  void InAppWebView::getContentWidth(const std::function<void(const std::optional<int64_t>)> completionHandler) const
  {
    if (!webView || !completionHandler) {
      if (completionHandler) completionHandler(std::nullopt);
      return;
    }

    evaluateJavascript(
      "Math.max(document.body.scrollWidth, document.documentElement.scrollWidth)",
      ContentWorld::page(),
      [completionHandler](const std::string& value) {
        try {
          auto width = std::stoll(value);
          completionHandler(width);
        }
        catch (...) {
          completionHandler(0);
        }
      }
    );
  }

  void InAppWebView::isSecureContext(const std::function<void(const bool)> completionHandler) const
  {
    if (!webView || !completionHandler) {
      if (completionHandler) completionHandler(false);
      return;
    }

    evaluateJavascript(
      "window.isSecureContext",
      ContentWorld::page(),
      [completionHandler](const std::string& value) {
        completionHandler(value == "true");
      }
    );
  }

  void InAppWebView::injectCSSCode(const std::string& source) const
  {
    if (!webView) {
      return;
    }

    // Escape single quotes and newlines in CSS
    std::string escaped_source = source;
    escaped_source = replace_all_copy(escaped_source, "\\", "\\\\");
    escaped_source = replace_all_copy(escaped_source, "'", "\\'");
    escaped_source = replace_all_copy(escaped_source, "\n", "\\n");
    escaped_source = replace_all_copy(escaped_source, "\r", "\\r");

    std::string script =
      "(function() {"
      "  var style = document.createElement('style');"
      "  style.textContent = '" + escaped_source + "';"
      "  document.head.appendChild(style);"
      "})();";
    evaluateJavascript(script, ContentWorld::page(), nullptr);
  }

  void InAppWebView::injectCSSFileFromUrl(const std::string& urlFile) const
  {
    if (!webView) {
      return;
    }

    std::string script =
      "(function() {"
      "  var link = document.createElement('link');"
      "  link.rel = 'stylesheet';"
      "  link.href = '" + urlFile + "';"
      "  document.head.appendChild(link);"
      "})();";
    evaluateJavascript(script, ContentWorld::page(), nullptr);
  }

  // flutter_view
  void InAppWebView::setSurfaceSize(size_t width, size_t height, float scale_factor)
  {
    if (!webViewController) {
      return;
    }

    if (surface_ && width > 0 && height > 0) {
      scaleFactor_ = scale_factor;
      auto scaled_width = width * scale_factor;
      auto scaled_height = height * scale_factor;

      RECT bounds;
      bounds.left = 0;
      bounds.top = 0;
      bounds.right = static_cast<LONG>(scaled_width);
      bounds.bottom = static_cast<LONG>(scaled_height);

      surface_->put_Size({ scaled_width, scaled_height });

      wil::com_ptr<ICoreWebView2Controller3> webViewController3;
      if (SUCCEEDED(webViewController->QueryInterface(IID_PPV_ARGS(&webViewController3)))) {
        webViewController3->put_RasterizationScale(scale_factor);
      }

      if (webViewController->put_Bounds(bounds) != S_OK) {
        std::cerr << "Setting webview bounds failed." << std::endl;
      }

      if (surfaceSizeChangedCallback_) {
        surfaceSizeChangedCallback_(width, height);
      }
    }
  }

  void InAppWebView::setPosition(size_t x, size_t y, float scale_factor)
  {
    if (!webViewController || !plugin || !plugin->registrar) {
      return;
    }

    if (x >= 0 && y >= 0) {
      scaleFactor_ = scale_factor;
      auto scaled_x = static_cast<int>(x * scale_factor);
      auto scaled_y = static_cast<int>(y * scale_factor);

      auto titleBarHeight = ((GetSystemMetrics(SM_CYCAPTION) + GetSystemMetrics(SM_CYFRAME)) * scale_factor) + GetSystemMetrics(SM_CXPADDEDBORDER);
      auto borderWidth = (GetSystemMetrics(SM_CXBORDER) + GetSystemMetrics(SM_CXPADDEDBORDER)) * scale_factor;

      RECT flutterWindowRect;
      HWND flutterWindowHWnd = plugin->registrar->GetView()->GetNativeWindow();
      GetWindowRect(flutterWindowHWnd, &flutterWindowRect);

      HWND webViewHWnd;
      if (succeededOrLog(webViewController->get_ParentWindow(&webViewHWnd))) {
        ::SetWindowPos(webViewHWnd,
          nullptr,
          static_cast<int>(flutterWindowRect.left + scaled_x - borderWidth),
          static_cast<int>(flutterWindowRect.top + scaled_y - titleBarHeight),
          0, 0,
          SWP_NOZORDER | SWP_NOSIZE | SWP_NOACTIVATE);
      }
    }
  }

  void InAppWebView::setCursorPos(double x, double y)
  {
    if (!webViewCompositionController) {
      return;
    }

    POINT point;
    point.x = static_cast<LONG>(x * scaleFactor_);
    point.y = static_cast<LONG>(y * scaleFactor_);
    lastCursorPos_ = point;

    // https://docs.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2?view=webview2-1.0.774.44
    webViewCompositionController->SendMouseInput(
      COREWEBVIEW2_MOUSE_EVENT_KIND::COREWEBVIEW2_MOUSE_EVENT_KIND_MOVE,
      virtualKeys_.state(), 0, point);
  }

  void InAppWebView::setPointerUpdate(int32_t pointer,
    InAppWebViewPointerEventKind eventKind, double x,
    double y, double size, double pressure)
  {
    if (!webViewEnv || !webViewCompositionController) {
      return;
    }

    COREWEBVIEW2_POINTER_EVENT_KIND event =
      COREWEBVIEW2_POINTER_EVENT_KIND_UPDATE;
    UINT32 pointerFlags = POINTER_FLAG_NONE;
    switch (eventKind) {
    case InAppWebViewPointerEventKind::Activate:
      event = COREWEBVIEW2_POINTER_EVENT_KIND_ACTIVATE;
      break;
    case InAppWebViewPointerEventKind::Down:
      event = COREWEBVIEW2_POINTER_EVENT_KIND_DOWN;
      pointerFlags =
        POINTER_FLAG_DOWN | POINTER_FLAG_INRANGE | POINTER_FLAG_INCONTACT;
      break;
    case InAppWebViewPointerEventKind::Enter:
      event = COREWEBVIEW2_POINTER_EVENT_KIND_ENTER;
      break;
    case InAppWebViewPointerEventKind::Leave:
      event = COREWEBVIEW2_POINTER_EVENT_KIND_LEAVE;
      break;
    case InAppWebViewPointerEventKind::Up:
      event = COREWEBVIEW2_POINTER_EVENT_KIND_UP;
      pointerFlags = POINTER_FLAG_UP;
      break;
    case InAppWebViewPointerEventKind::Update:
      event = COREWEBVIEW2_POINTER_EVENT_KIND_UPDATE;
      pointerFlags =
        POINTER_FLAG_UPDATE | POINTER_FLAG_INRANGE | POINTER_FLAG_INCONTACT;
      break;
    }

    POINT point;
    point.x = static_cast<LONG>(x * scaleFactor_);
    point.y = static_cast<LONG>(y * scaleFactor_);

    RECT rect;
    rect.left = point.x - 2;
    rect.right = point.x + 2;
    rect.top = point.y - 2;
    rect.bottom = point.y + 2;

    wil::com_ptr<ICoreWebView2Environment3> webViewEnv3;
    if (SUCCEEDED(webViewEnv->QueryInterface(IID_PPV_ARGS(&webViewEnv3)))) {
      wil::com_ptr<ICoreWebView2PointerInfo> pInfo;
      if (SUCCEEDED(webViewEnv3->CreateCoreWebView2PointerInfo(&pInfo))) {
        if (pInfo) {
          pInfo->put_PointerId(pointer);
          pInfo->put_PointerKind(PT_TOUCH);
          pInfo->put_PointerFlags(pointerFlags);
          pInfo->put_TouchFlags(TOUCH_FLAG_NONE);
          pInfo->put_TouchMask(TOUCH_MASK_CONTACTAREA | TOUCH_MASK_PRESSURE);
          pInfo->put_TouchPressure(
            std::clamp((UINT32)(pressure == 0.0 ? 1024 : 1024 * pressure),
              (UINT32)0, (UINT32)1024));
          pInfo->put_PixelLocationRaw(point);
          pInfo->put_TouchContactRaw(rect);
          webViewCompositionController->SendPointerInput(event, pInfo.get());
        }
      }
    }
  }

  void InAppWebView::setPointerButtonState(InAppWebViewPointerEventKind kind, InAppWebViewPointerButton button)
  {
    if (!webViewCompositionController) {
      return;
    }

    COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS eventVirtualKeys_ = COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS_NONE;
    COREWEBVIEW2_MOUSE_EVENT_KIND eventKind;
    UINT32 mouseData = 0;
    POINT point = { 0, 0 };;

    switch (kind) {
    case InAppWebViewPointerEventKind::Down:
      switch (button) {
      case InAppWebViewPointerButton::Primary:
        virtualKeys_.setIsLeftButtonDown(true);
        eventKind = COREWEBVIEW2_MOUSE_EVENT_KIND_LEFT_BUTTON_DOWN;
        break;
      case InAppWebViewPointerButton::Secondary:
        virtualKeys_.setIsRightButtonDown(true);
        eventKind = COREWEBVIEW2_MOUSE_EVENT_KIND_RIGHT_BUTTON_DOWN;
        break;
      case InAppWebViewPointerButton::Tertiary:
        virtualKeys_.setIsMiddleButtonDown(true);
        eventKind = COREWEBVIEW2_MOUSE_EVENT_KIND_MIDDLE_BUTTON_DOWN;
        break;
      default:
        eventKind = static_cast<COREWEBVIEW2_MOUSE_EVENT_KIND>(0);
      }
      eventVirtualKeys_ = virtualKeys_.state();
      point = lastCursorPos_;
      break;
    case InAppWebViewPointerEventKind::Up:
      switch (button) {
      case InAppWebViewPointerButton::Primary:
        virtualKeys_.setIsLeftButtonDown(false);
        eventKind = COREWEBVIEW2_MOUSE_EVENT_KIND_LEFT_BUTTON_UP;
        break;
      case InAppWebViewPointerButton::Secondary:
        virtualKeys_.setIsRightButtonDown(false);
        eventKind = COREWEBVIEW2_MOUSE_EVENT_KIND_RIGHT_BUTTON_UP;
        break;
      case InAppWebViewPointerButton::Tertiary:
        virtualKeys_.setIsMiddleButtonDown(false);
        eventKind = COREWEBVIEW2_MOUSE_EVENT_KIND_MIDDLE_BUTTON_UP;
        break;
      default:
        eventKind = static_cast<COREWEBVIEW2_MOUSE_EVENT_KIND>(0);
      }
      eventVirtualKeys_ = virtualKeys_.state();
      point = lastCursorPos_;
      break;
    case InAppWebViewPointerEventKind::Leave:
      eventKind = COREWEBVIEW2_MOUSE_EVENT_KIND_LEAVE;
      break;
    default:
      eventKind = static_cast<COREWEBVIEW2_MOUSE_EVENT_KIND>(0);
    }

    webViewCompositionController->SendMouseInput(eventKind, eventVirtualKeys_, mouseData, point);
  }

  void InAppWebView::sendScroll(double delta, bool horizontal)
  {
    if (!webViewCompositionController) {
      return;
    }

    auto offset = static_cast<short>(delta * settings->scrollMultiplier);

    if (horizontal) {
      webViewCompositionController->SendMouseInput(
        COREWEBVIEW2_MOUSE_EVENT_KIND_HORIZONTAL_WHEEL, virtualKeys_.state(),
        offset, lastCursorPos_);
    }
    else {
      webViewCompositionController->SendMouseInput(COREWEBVIEW2_MOUSE_EVENT_KIND_WHEEL,
        virtualKeys_.state(), offset,
        lastCursorPos_);
    }
  }

  void InAppWebView::setScrollDelta(double delta_x, double delta_y)
  {
    if (!webViewCompositionController) {
      return;
    }

    if (delta_x != 0.0) {
      sendScroll(delta_x, true);
    }
    if (delta_y != 0.0) {
      sendScroll(delta_y, false);
    }
  }

  bool InAppWebView::createSurface(const HWND parentWindow,
    winrt::com_ptr<ABI::Windows::UI::Composition::ICompositor> compositor)
  {
    if (!webViewCompositionController || !webViewController) {
      return false;
    }

    winrt::com_ptr<ABI::Windows::UI::Composition::IContainerVisual> root;
    if (FAILED(compositor->CreateContainerVisual(root.put()))) {
      return false;
    }
    surface_ = root.try_as<ABI::Windows::UI::Composition::IVisual>();
    assert(surface_);

    // initial size. doesn't matter as we resize the surface anyway.
    surface_->put_Size({ 1280, 720 });
    surface_->put_IsVisible(true);

    winrt::com_ptr<ABI::Windows::UI::Composition::IVisual> webview_visual;
    compositor->CreateContainerVisual(
      reinterpret_cast<ABI::Windows::UI::Composition::IContainerVisual**>(
        webview_visual.put()));

    auto webview_visual2 =
      webview_visual.try_as<ABI::Windows::UI::Composition::IVisual2>();
    if (webview_visual2) {
      webview_visual2->put_RelativeSizeAdjustment({ 1.0f, 1.0f });
    }

    winrt::com_ptr<ABI::Windows::UI::Composition::IVisualCollection> children;
    root->get_Children(children.put());
    children->InsertAtTop(webview_visual.get());
    webViewCompositionController->put_RootVisualTarget(webview_visual2.get());

    webViewController->put_IsVisible(true);

    return true;
  }

  bool InAppWebView::isSslError(const COREWEBVIEW2_WEB_ERROR_STATUS& webErrorStatus)
  {
    return webErrorStatus >= COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_COMMON_NAME_IS_INCORRECT && webErrorStatus <= COREWEBVIEW2_WEB_ERROR_STATUS_CERTIFICATE_IS_INVALID;
  }

  HRESULT InAppWebView::onCallJsHandler(const bool& isMainFrame, ICoreWebView2WebMessageReceivedEventArgs* args)
  {
    if (!channelDelegate) {
      return S_OK;
    }

    wil::unique_cotaskmem_string json;
    if (succeededOrLog(args->get_WebMessageAsJson(&json))) {
      nlohmann::basic_json<> message;
      try {
        message = nlohmann::json::parse(wide_to_utf8(json.get()));
      }
      catch (nlohmann::json::parse_error& ex) {
        debugLog("Error parsing JSON message of callHandler method: " + std::string(ex.what()));
        return S_OK;
      }

      if (message.is_object() && message.contains("name") && message.at("name").is_string() && message.contains("body") && message.at("body").is_object()) {
        auto name = message.at("name").get<std::string>();
        auto body = message.at("body").get<nlohmann::json>();

        if (name.compare("callHandler") == 0) {
          if (!body.contains("handlerName") || !body.at("handlerName").is_string()) {
            debugLog("handlerName is null or undefined");
            return S_OK;
          }

          auto handlerName = body.at("handlerName").get<std::string>();
          auto bridgeSecret = body.contains("_bridgeSecret") && body.at("_bridgeSecret").is_string() ? body.at("_bridgeSecret").get<std::string>() : "";
          auto callHandlerID = body.contains("_callHandlerID") && body.at("_callHandlerID").is_number_integer() ? body.at("_callHandlerID").get<int64_t>() : 0;
          auto origin = body.contains("origin") && body.at("origin").is_string() ? body.at("origin").get<std::string>() : "";
          auto requestUrl = body.contains("requestUrl") && body.at("requestUrl").is_string() ? body.at("requestUrl").get<std::string>() : "";
          auto handlerArgs = body.contains("args") && body.at("args").is_string() ? body.at("args").get<std::string>() : "";

          wil::unique_cotaskmem_string sourceUrl;
          if (succeededOrLog(args->get_Source(&sourceUrl))) {
            requestUrl = wide_to_utf8(sourceUrl.get());
            origin = get_origin_from_url(requestUrl);
          }

          if (!string_equals(expectedBridgeSecret, bridgeSecret)) {
            debugLog("Bridge access attempt with wrong secret token, possibly from malicious code from origin: " + origin);
            return S_OK;
          }

          auto resolveInternalHandler = [this, callHandlerID]()
            {
              evaluateJavascript("if (window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + "[" + std::to_string(callHandlerID) + "] != null) { \
                      window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + "[" + std::to_string(callHandlerID) + "].resolve(null); \
                      delete window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + "[" + std::to_string(callHandlerID) + "]; \
                    }", ContentWorld::page(), nullptr);
            };

          if (handlerName == "onWebMessagePortMessageReceived") {
            std::string webMessageChannelId = "";
            int portIndex = 0;
            std::string messageData = "";
            int64_t messageType = 0;

            if (!handlerArgs.empty()) {
              try {
                auto argsJson = nlohmann::json::parse(handlerArgs);
                if (argsJson.is_array() && !argsJson.empty()) {
                  auto firstArg = argsJson[0];
                  if (firstArg.contains("webMessageChannelId") && firstArg["webMessageChannelId"].is_string()) {
                    webMessageChannelId = firstArg["webMessageChannelId"].get<std::string>();
                  }
                  if (firstArg.contains("index") && firstArg["index"].is_number()) {
                    portIndex = firstArg["index"].get<int>();
                  }
                  if (firstArg.contains("message") && firstArg["message"].is_object()) {
                    auto messageObj = firstArg["message"];
                    if (messageObj.contains("type") && messageObj["type"].is_number()) {
                      messageType = messageObj["type"].get<int64_t>();
                    }
                    if (messageObj.contains("data")) {
                      if (messageType == 1 && messageObj["data"].is_array()) {
                        std::string bytes;
                        for (auto& byte : messageObj["data"]) {
                          if (!bytes.empty()) bytes += ",";
                          bytes += std::to_string(byte.get<int>());
                        }
                        messageData = bytes;
                      }
                      else if (messageObj["data"].is_string()) {
                        messageData = messageObj["data"].get<std::string>();
                      }
                      else if (!messageObj["data"].is_null()) {
                        messageData = messageObj["data"].dump();
                      }
                    }
                  }
                }
              }
              catch (nlohmann::json::parse_error&) {}
            }

            if (!webMessageChannelId.empty()) {
              auto channel = getWebMessageChannel(webMessageChannelId);
              if (channel != nullptr) {
                channel->onMessage(portIndex, messageData.empty() ? nullptr : &messageData, messageType);
              }
            }
            resolveInternalHandler();
            return S_OK;
          }

          if (handlerName == "onWebMessageListenerPostMessageReceived") {
            std::string jsObjectName = "";
            std::string messageData = "";
            int64_t messageType = 0;
            std::string sourceOriginStr = "";
            bool isMainFrameMsg = true;

            if (!handlerArgs.empty()) {
              try {
                auto argsJson = nlohmann::json::parse(handlerArgs);
                if (argsJson.is_array() && !argsJson.empty()) {
                  auto firstArg = argsJson[0];
                  if (firstArg.contains("jsObjectName") && firstArg["jsObjectName"].is_string()) {
                    jsObjectName = firstArg["jsObjectName"].get<std::string>();
                  }
                  if (firstArg.contains("sourceOrigin") && firstArg["sourceOrigin"].is_string()) {
                    sourceOriginStr = firstArg["sourceOrigin"].get<std::string>();
                  }
                  if (firstArg.contains("isMainFrame") && firstArg["isMainFrame"].is_boolean()) {
                    isMainFrameMsg = firstArg["isMainFrame"].get<bool>();
                  }
                  if (firstArg.contains("message") && firstArg["message"].is_object()) {
                    auto messageObj = firstArg["message"];
                    if (messageObj.contains("type") && messageObj["type"].is_number()) {
                      messageType = messageObj["type"].get<int64_t>();
                    }
                    if (messageObj.contains("data")) {
                      if (messageType == 1 && messageObj["data"].is_array()) {
                        std::string bytes;
                        for (auto& byte : messageObj["data"]) {
                          if (!bytes.empty()) bytes += ",";
                          bytes += std::to_string(byte.get<int>());
                        }
                        messageData = bytes;
                      }
                      else if (messageObj["data"].is_string()) {
                        messageData = messageObj["data"].get<std::string>();
                      }
                      else if (!messageObj["data"].is_null()) {
                        messageData = messageObj["data"].dump();
                      }
                    }
                  }
                }
              }
              catch (nlohmann::json::parse_error&) {}
            }

            if (!jsObjectName.empty()) {
              auto it = webMessageListeners_.find(jsObjectName);
              if (it != webMessageListeners_.end() && it->second) {
                it->second->onPostMessage(
                  messageData.empty() ? nullptr : &messageData,
                  messageType,
                  sourceOriginStr,
                  isMainFrameMsg);
              }
            }
            resolveInternalHandler();
            return S_OK;
          }

          bool isOriginAllowed = false;
          if (settings->javaScriptHandlersOriginAllowList.has_value()) {
            for (auto& allowedOrigin : settings->javaScriptHandlersOriginAllowList.value()) {
              if (std::regex_match(origin, std::regex(allowedOrigin))) {
                isOriginAllowed = true;
                break;
              }
            }
          }
          else {
            // origin is by default allowed if the allow list is null
            isOriginAllowed = true;
          }
          if (!isOriginAllowed) {
            debugLog("Bridge access attempt from an origin not allowed: " + origin);
            return S_OK;
          }

          if (settings->javaScriptHandlersForMainFrameOnly && !isMainFrame) {
            debugLog("Bridge access attempt from a sub-frame origin: " + origin);
            return S_OK;
          }

          /*
          boolean isInternalHandler = true;
          switch (handlerName) {
          default:
            isInternalHandler = false;
            break;
          }

          if (isInternalHandler) {
            evaluateJavascript("if (window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + "[" + std::to_string(callHandlerID) + "] != null) { \
                window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + "[" + std::to_string(callHandlerID) + "].resolve(); \
                delete window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + "[" + std::to_string(callHandlerID) + "]; \
              }", ContentWorld::page(), nullptr);
            return S_OK;
          }
          */

          auto callback = std::make_unique<WebViewChannelDelegate::CallJsHandlerCallback>();
          callback->defaultBehaviour = [this, callHandlerID](const std::optional<const flutter::EncodableValue*> response)
            {
              std::string json = "null";
              if (response.has_value() && !response.value()->IsNull()) {
                json = std::get<std::string>(*(response.value()));
              }

              evaluateJavascript("if (window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + "[" + std::to_string(callHandlerID) + "] != null) { \
                      window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + "[" + std::to_string(callHandlerID) + "].resolve(" + json + "); \
                      delete window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + "[" + std::to_string(callHandlerID) + "]; \
                    }", ContentWorld::page(), nullptr);
            };
          callback->error = [this, callHandlerID](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
            {
              auto errorMessage = error_code + ", " + error_message;
              debugLog(errorMessage);

              evaluateJavascript("if (window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + "[" + std::to_string(callHandlerID) + "] != null) { \
                      window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + "[" + std::to_string(callHandlerID) + "].reject(new Error('" + replace_all_copy(errorMessage, "\'", "\\'") + "')); \
                      delete window." + JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME() + "[" + std::to_string(callHandlerID) + "]; \
                    }", ContentWorld::page(), nullptr);
            };

          auto data = std::make_unique<JavaScriptHandlerFunctionData>(origin, requestUrl, isMainFrame, handlerArgs);
          channelDelegate->onCallJsHandler(handlerName, std::move(data), std::move(callback));
        }
      }
      else {
        debugLog("Invalid JSON message of callHandler method");
      }
    }

    return S_OK;
  }

  InAppWebView::~InAppWebView()
  {
    debugLog("dealloc InAppWebView");
    userContentController = nullptr;
    if (webView) {
      failedLog(webView->Stop());
    }
    HWND parentWindow = nullptr;
    if (webViewCompositionController && webViewController && succeededOrLog(webViewController->get_ParentWindow(&parentWindow))) {
      // if it's an InAppWebView (so webViewCompositionController will be not a nullptr!),
      // then destroy the Window created with it
      DestroyWindow(parentWindow);
    }
    if (webViewController) {
      failedLog(webViewController->Close());
    }
    for (auto& [id, channel] : webMessageChannels_) {
      if (channel) {
        channel->dispose();
      }
    }
    webMessageChannels_.clear();
    for (auto& [name, listener] : webMessageListeners_) {
      if (listener) {
        listener->dispose();
      }
    }
    webMessageListeners_.clear();
    if (printJobManager) {
      printJobManager->dispose();
      printJobManager.reset();
    }
    disposeAllWebNotificationControllers();
    if (findInteractionController) {
      findInteractionController->dispose();
      findInteractionController.reset();
    }
    navigationActions_.clear();
    inAppBrowser = nullptr;
    plugin = nullptr;
  }
}
