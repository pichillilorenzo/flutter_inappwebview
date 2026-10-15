#include <DispatcherQueue.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <cassert>
#include <shlobj.h>
#include <windows.foundation.h>
#include <windows.graphics.capture.h>

#include "../in_app_webview/in_app_webview_settings.h"
#include "../plugin_scripts_js/javascript_bridge_js.h"
#include "../types/url_request.h"
#include "../types/user_script.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/string.h"
#include "../utils/vector.h"
#include "../webview_environment/webview_environment_manager.h"
#include "in_app_webview_manager.h"

namespace flutter_inappwebview_plugin
{
  InAppWebViewManager::InAppWebViewManager(const FlutterInappwebviewWindowsPlugin* plugin)
    : plugin(plugin),
    ChannelDelegate(plugin->registrar->messenger(), InAppWebViewManager::METHOD_CHANNEL_NAME)
  {
    {
      const std::lock_guard<std::mutex> lock(shared_resources_mutex_);
      ++instance_count_;

      if (!rohelper_) {
        rohelper_ = new rx::RoHelper(RO_INIT_SINGLETHREADED);

        if (rohelper_->WinRtAvailable()) {
          DispatcherQueueOptions options{ sizeof(DispatcherQueueOptions),
                                         DQTYPE_THREAD_CURRENT, DQTAT_COM_STA };

          if (FAILED(rohelper_->CreateDispatcherQueueController(
            options, &dispatcher_queue_controller_))) {
            std::cerr << "Creating DispatcherQueueController failed." << std::endl;
            return;
          }

          if (!isGraphicsCaptureSessionSupported()) {
            std::cerr << "Windows::Graphics::Capture::GraphicsCaptureSession is not "
              "supported."
              << std::endl;
            return;
          }

          graphics_context_ = new GraphicsContext(rohelper_);
          auto compositor = graphics_context_->CreateCompositor();
          compositor_ = compositor.detach();
          valid_ = graphics_context_->IsValid();
        }
      }
    }

    windowClass_.lpszClassName = CustomPlatformView::CLASS_NAME;
    windowClass_.lpfnWndProc = &DefWindowProc;
    windowClass_.style |= CS_NOCLOSE;

    RegisterClass(&windowClass_);
  }

  void InAppWebViewManager::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    auto& methodName = method_call.method_name();

    if (string_equals(methodName, "createInAppWebView")) {
      if (isSupported()) {
        createInAppWebView(arguments, std::move(result));
      }
      else {
        result->Error("0", "Creating an InAppWebView instance is not supported! Graphics Context is not valid!");
      }
    }
    else if (string_equals(methodName, "dispose")) {
      auto id = get_fl_map_value<int64_t>(*arguments, "id");
      if (map_contains(webViews, (uint64_t)id)) {
        auto platformView = webViews.at(id).get();
        if (platformView) {
          platformView->UnregisterMethodCallHandler();
        }
        webViews.erase(id);
      }
      result->Success();
    }
    else if (string_equals(methodName, "disposeKeepAlive")) {
      auto keepAliveId = get_fl_map_value<std::string>(*arguments, "keepAliveId");
      disposeKeepAlive(keepAliveId);
      result->Success();
    }
    else if (string_equals(methodName, "setJavaScriptBridgeName")) {
      auto bridgeName = get_fl_map_value<std::string>(*arguments, "bridgeName");
      JavaScriptBridgeJS::set_JAVASCRIPT_BRIDGE_NAME(bridgeName);
      result->Success();
    }
    else if (string_equals(methodName, "getJavaScriptBridgeName")) {
      result->Success(JavaScriptBridgeJS::get_JAVASCRIPT_BRIDGE_NAME());
    }
    else {
      result->NotImplemented();
    }
  }

  void InAppWebViewManager::createInAppWebView(const flutter::EncodableMap* arguments, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));

    if (!plugin) {
      result_->Error("0", "Cannot create the InAppWebView instance!");
      return;
    }

    auto settingsMap = get_fl_map_value<flutter::EncodableMap>(*arguments, "initialSettings");
    auto urlRequestMap = get_optional_fl_map_value<flutter::EncodableMap>(*arguments, "initialUrlRequest");
    auto initialFile = get_optional_fl_map_value<std::string>(*arguments, "initialFile");
    auto initialDataMap = get_optional_fl_map_value<flutter::EncodableMap>(*arguments, "initialData");
    auto initialUserScriptList = get_optional_fl_map_value<flutter::EncodableList>(*arguments, "initialUserScripts");
    auto webViewEnvironmentId = get_optional_fl_map_value<std::string>(*arguments, "webViewEnvironmentId");
    auto keepAliveId = get_optional_fl_map_value<std::string>(*arguments, "keepAliveId");
    auto windowId = get_optional_fl_map_value<int64_t>(*arguments, "windowId");

    RECT bounds;
    GetClientRect(plugin->registrar->GetView()->GetNativeWindow(), &bounds);

    const DWORD windowStyle = WS_CHILD | WS_CLIPSIBLINGS | WS_CLIPCHILDREN;
    auto hwnd = CreateWindowEx(0, windowClass_.lpszClassName, L"", windowStyle, 0,
      0, bounds.right - bounds.left, bounds.bottom - bounds.top,
      plugin->registrar->GetView()->GetNativeWindow(),
      nullptr,
      windowClass_.hInstance, nullptr);

    if (keepAliveId.has_value() && map_contains(keepAliveWebViews, keepAliveId.value())) {
      auto webView = std::move(keepAliveWebViews.at(keepAliveId.value())->view);
      keepAliveWebViews.erase(keepAliveId.value());
      auto customPlatformView = std::make_unique<CustomPlatformView>(plugin->registrar->messenger(),
        plugin->registrar->texture_registrar(),
        graphics_context(),
        hwnd,
        std::move(webView));
      auto textureId = customPlatformView->texture_id();
      keepAliveWebViews.insert({ keepAliveId.value(), std::move(customPlatformView) });
      result_->Success(textureId);
      return;
    }

    auto webViewEnvironment = webViewEnvironmentId.has_value() && map_contains(plugin->webViewEnvironmentManager->webViewEnvironments, webViewEnvironmentId.value())
      ? plugin->webViewEnvironmentManager->webViewEnvironments.at(webViewEnvironmentId.value()).get() : nullptr;

    auto initialSettings = std::make_shared<InAppWebViewSettings>(settingsMap);

    InAppWebView::createInAppWebViewEnv(hwnd, true, webViewEnvironment, initialSettings,
      [=, alive = alive_.weak()](HRESULT errorCode,
        wil::com_ptr<ICoreWebView2Environment> webViewEnv,
        wil::com_ptr<ICoreWebView2Controller> webViewController,
        wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController)
      {
        if (alive.expired()) {
          // The engine was torn down while WebView2 was still creating the
          // controller: this object, the registrar and result_ are all gone.
          if (webViewController) {
            failedLog(webViewController->Close());
          }
          return;
        }
        if (plugin && webViewEnv && webViewController && webViewCompositionController) {
          std::optional<std::vector<std::shared_ptr<UserScript>>> initialUserScripts = initialUserScriptList.has_value() ?
            functional_map(initialUserScriptList.value(), [](const flutter::EncodableValue& map) { return std::make_shared<UserScript>(std::get<flutter::EncodableMap>(map)); }) :
            std::optional<std::vector<std::shared_ptr<UserScript>>>{};

          InAppWebViewCreationParams params = {
            "",
            std::move(initialSettings),
            initialUserScripts
          };

          auto inAppWebView = std::make_unique<InAppWebView>(plugin, params, hwnd,
            std::move(webViewEnv), std::move(webViewController),
            std::move(webViewCompositionController), windowMinimized_);
          if (!inAppWebView->webView || !inAppWebView->surface()) {
            result_->Error("0", "Cannot create the InAppWebView surface!");
            return;
          }

          std::optional<std::shared_ptr<URLRequest>> urlRequest = urlRequestMap.has_value() ? std::make_shared<URLRequest>(urlRequestMap.value()) : std::optional<std::shared_ptr<URLRequest>>{};
          if (urlRequest.has_value()) {
            inAppWebView->loadUrl(urlRequest.value());
          }
          else if (initialFile.has_value()) {
            inAppWebView->loadFile(initialFile.value());
          }
          else if (initialDataMap.has_value()) {
            inAppWebView->loadData(get_fl_map_value<std::string>(initialDataMap.value(), "data"));
          }

          if (windowId.has_value() && map_contains(windowWebViews, windowId.value())) {
            auto windowWebViewArgs = windowWebViews.at(windowId.value()).get();
            windowWebViewArgs->args->put_NewWindow(inAppWebView->webView.get());
            windowWebViewArgs->args->put_Handled(TRUE);
            windowWebViewArgs->deferral->Complete();
            windowWebViews.erase(windowId.value());
          }

          auto customPlatformView = std::make_unique<CustomPlatformView>(plugin->registrar->messenger(),
            plugin->registrar->texture_registrar(),
            graphics_context(),
            hwnd,
            std::move(inAppWebView));

          auto textureId = customPlatformView->texture_id();

          if (keepAliveId.has_value()) {
            customPlatformView->view->initChannel(keepAliveId.value(), std::nullopt);
            keepAliveWebViews.insert({ keepAliveId.value(), std::move(customPlatformView) });
          }
          else {
            customPlatformView->view->initChannel(textureId, std::nullopt);
            webViews.insert({ textureId, std::move(customPlatformView) });
          }
          result_->Success(textureId);
        }
        else {
          DestroyWindow(hwnd);
          result_->Error("0", "Cannot create the InAppWebView instance! HRESULT " + getHRErrorString(errorCode));
        }
      }
    );
  }

  void InAppWebViewManager::disposeKeepAlive(const std::string& keepAliveId)
  {
    if (map_contains(keepAliveWebViews, keepAliveId)) {
      auto platformView = keepAliveWebViews.at(keepAliveId).get();
      if (platformView) {
        platformView->UnregisterMethodCallHandler();
      }
      keepAliveWebViews.erase(keepAliveId);
    }
  }

  // WebView2 keeps its own top-level input window (class Chrome_WidgetWin_1,
  // owned by no window) over the widget area. It has no redirection bitmap, so
  // it is invisible - but it still hit-tests, and minimizing the app leaves it
  // on screen swallowing every mouse click over the region the app occupied.
  // Hiding the controller hides that window. Each WebView keeps its requested
  // pause state separate from this temporary host-window state, so resume()
  // cannot expose it while minimized and restore cannot expose a paused view.
  void InAppWebViewManager::setWindowMinimized(const bool minimized)
  {
    windowMinimized_ = minimized;

    const auto applyWindowState = [minimized](const std::unique_ptr<CustomPlatformView>& platformView)
      {
        const auto webView = platformView ? platformView->view.get() : nullptr;
        if (webView) {
          webView->setHostWindowMinimized(minimized);
        }
      };

    for (const auto& [id, platformView] : webViews) {
      applyWindowState(platformView);
    }
    for (const auto& [keepAliveId, platformView] : keepAliveWebViews) {
      applyWindowState(platformView);
    }
  }

  bool InAppWebViewManager::isGraphicsCaptureSessionSupported()
  {
    HSTRING className;
    HSTRING_HEADER classNameHeader;

    if (FAILED(rohelper_->GetStringReference(
      RuntimeClass_Windows_Graphics_Capture_GraphicsCaptureSession,
      &className, &classNameHeader))) {
      return false;
    }

    ABI::Windows::Graphics::Capture::IGraphicsCaptureSessionStatics*
      capture_session_statics;
    if (FAILED(rohelper_->GetActivationFactory(
      className,
      __uuidof(
        ABI::Windows::Graphics::Capture::IGraphicsCaptureSessionStatics),
      (void**)&capture_session_statics))) {
      return false;
    }

    boolean is_supported = false;
    if (FAILED(capture_session_statics->IsSupported(&is_supported))) {
      return false;
    }

    return !!is_supported;
  }

  ABI::Windows::System::IDispatcherQueueController* InAppWebViewManager::detachSharedResourcesForShutdown()
  {
    // These WinRT/Composition objects are intentionally process-lifetime
    // objects. Releasing them during Flutter engine teardown can call into
    // WinRT DLLs while they are unloading. Null the cached pointers so the
    // plugin won't use them again; the OS will reclaim them at process exit.
    valid_ = false;
    const auto dispatcherQueueController = dispatcher_queue_controller_;
    dispatcher_queue_controller_ = nullptr;
    compositor_ = nullptr;
    graphics_context_ = nullptr;
    rohelper_ = nullptr;
    return dispatcherQueueController;
  }

  void InAppWebViewManager::shutdownDispatcherQueue(ABI::Windows::System::IDispatcherQueueController* dispatcherQueueController)
  {
    if (!dispatcherQueueController) {
      return;
    }

    ABI::Windows::Foundation::IAsyncAction* shutdownOperation = nullptr;
    failedLog(dispatcherQueueController->ShutdownQueueAsync(&shutdownOperation));
    // Do not release the async operation during shutdown; keep it alive for
    // the remaining process lifetime so it cannot race with queue shutdown.
    (void)shutdownOperation;
  }

  InAppWebViewManager::~InAppWebViewManager()
  {
    debugLog("dealloc InAppWebViewManager");
    alive_.expire();
    webViews.clear();
    keepAliveWebViews.clear();
    windowWebViews.clear();
    UnregisterClass(windowClass_.lpszClassName, nullptr);
    plugin = nullptr;

    ABI::Windows::System::IDispatcherQueueController* dispatcherQueueController = nullptr;
    {
      const std::lock_guard<std::mutex> lock(shared_resources_mutex_);
      assert(instance_count_ > 0);
      --instance_count_;
      if (instance_count_ == 0) {
        dispatcherQueueController = detachSharedResourcesForShutdown();
      }
    }

    shutdownDispatcherQueue(dispatcherQueueController);
  }
}
