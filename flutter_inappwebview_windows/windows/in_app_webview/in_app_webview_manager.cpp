#include <DispatcherQueue.h>
#include <commctrl.h>
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
#include "../utils/flutter_view_hwnd.h"
#include "../utils/log.h"
#include "../utils/string.h"
#include "../utils/vector.h"
#include "../file_drop/file_drop_manager.h"
#include "../webview_environment/webview_environment_manager.h"
#include "in_app_webview_manager.h"

#pragma comment(lib, "Comctl32.lib")

namespace flutter_inappwebview_plugin
{
  namespace
  {
    // Subclass id for watching Flutter view windows that host webviews.
    constexpr UINT_PTR kFlutterViewSubclassId = 0x49415756;
  }

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
    // Absent for older callers: the implicit view, as before.
    auto flutterViewId = get_optional_fl_map_value<int64_t>(*arguments, "flutterViewId");

    const auto flutterViewHwnd = ResolveFlutterViewHwnd(plugin->registrar, flutterViewId);
    if (!flutterViewHwnd) {
      result_->Error("0", "Cannot create the InAppWebView instance! No Flutter view.");
      return;
    }
    watchFlutterView(flutterViewHwnd);

    if (keepAliveId.has_value() && map_contains(keepAliveWebViews, keepAliveId.value())) {
      // Reuse the existing host window, moved under the requesting view.
      auto webView = std::move(keepAliveWebViews.at(keepAliveId.value())->view);
      keepAliveWebViews.erase(keepAliveId.value());
      webView->reparent(flutterViewHwnd);
      const auto hostHwnd = webView->hostWindow();
      auto customPlatformView = std::make_unique<CustomPlatformView>(plugin->registrar->messenger(),
        plugin->registrar->texture_registrar(),
        graphics_context(),
        hostHwnd,
        std::move(webView),
        flutterViewResolver());
      auto textureId = customPlatformView->texture_id();
      keepAliveWebViews.insert({ keepAliveId.value(), std::move(customPlatformView) });
      result_->Success(textureId);
      return;
    }

    RECT bounds;
    GetClientRect(flutterViewHwnd, &bounds);

    const DWORD windowStyle = WS_CHILD | WS_CLIPSIBLINGS | WS_CLIPCHILDREN;
    auto hwnd = CreateWindowEx(0, windowClass_.lpszClassName, L"", windowStyle, 0,
      0, bounds.right - bounds.left, bounds.bottom - bounds.top,
      flutterViewHwnd,
      nullptr,
      windowClass_.hInstance, nullptr);

    auto webViewEnvironment = webViewEnvironmentId.has_value() && map_contains(plugin->webViewEnvironmentManager->webViewEnvironments, webViewEnvironmentId.value())
      ? plugin->webViewEnvironmentManager->webViewEnvironments.at(webViewEnvironmentId.value()).get() : nullptr;

    pendingWebViewHosts_.insert(hwnd);

    auto initialSettings = std::make_shared<InAppWebViewSettings>(settingsMap);
    auto failureStage = std::make_shared<std::string>();

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
        pendingWebViewHosts_.erase(hwnd);
        if (plugin && webViewEnv && webViewController && webViewCompositionController && IsWindow(hwnd)) {
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
            std::move(webViewCompositionController),
            GetParent(hwnd) == parkingWindow_ || isTopLevelMinimized(hwnd));
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
            std::move(inAppWebView),
            flutterViewResolver());

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
          if (webViewController) {
            failedLog(webViewController->Close());
          }
          DestroyWindow(hwnd);
          const std::string stage = failureStage->empty() ? "" : " (" + *failureStage + ")";
          result_->Error("0", "Cannot create the InAppWebView instance" + stage + "! HRESULT " + getHRErrorString(errorCode));
        }
      },
      failureStage
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

  // Hide WebView2's input windows on minimize without changing the requested
  // pause state or affecting webviews hosted by other top-level windows.
  void InAppWebViewManager::setWindowMinimized(const HWND topLevelHwnd, const bool minimized)
  {
    const auto [state, firstEvent] = windowMinimizedStates_.try_emplace(topLevelHwnd, minimized);
    if (!firstEvent && state->second == minimized) return;
    state->second = minimized;

    const auto applyWindowState = [topLevelHwnd, minimized](const std::unique_ptr<CustomPlatformView>& platformView)
      {
        const auto webView = platformView ? platformView->view.get() : nullptr;
        if (webView && webView->topLevelWindow() == topLevelHwnd) {
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

  bool InAppWebViewManager::isTopLevelMinimized(const HWND hwnd)
  {
    const auto topLevel = hwnd ? GetAncestor(hwnd, GA_ROOT) : nullptr;
    return topLevel && IsIconic(topLevel);
  }

  std::function<HWND(int64_t)> InAppWebViewManager::flutterViewResolver()
  {
    return [this](int64_t flutterViewId) -> HWND
      {
        const auto flutterViewHwnd = plugin
          ? ResolveFlutterViewHwnd(plugin->registrar, flutterViewId) : nullptr;
        if (flutterViewHwnd) {
          watchFlutterView(flutterViewHwnd);
        }
        return flutterViewHwnd;
      };
  }

  // A secondary window can be destroyed synchronously while its webviews are
  // only disposed later through the channel; park their hosts so they outlive it.
  void InAppWebViewManager::watchFlutterView(const HWND flutterViewHwnd)
  {
    if (!flutterViewHwnd || watchedFlutterViews_.count(flutterViewHwnd) > 0) {
      return;
    }
    // The implicit view lives as long as the app: keep its teardown as before.
    if (plugin && flutterViewHwnd == ResolveFlutterViewHwnd(plugin->registrar, std::nullopt)) {
      return;
    }
    if (SetWindowSubclass(flutterViewHwnd, &InAppWebViewManager::FlutterViewSubclassProc,
      kFlutterViewSubclassId, reinterpret_cast<DWORD_PTR>(this))) {
      watchedFlutterViews_.insert(flutterViewHwnd);
    }
  }

  LRESULT CALLBACK InAppWebViewManager::FlutterViewSubclassProc(HWND hwnd, UINT message,
    WPARAM wParam, LPARAM lParam, UINT_PTR subclassId, DWORD_PTR refData)
  {
    auto manager = reinterpret_cast<InAppWebViewManager*>(refData);
    if (message == WM_DESTROY && manager) {
      // Children still exist here: move the hosts out before they die with us.
      manager->onFlutterViewDestroyed(hwnd);
    }
    else if (message == WM_NCDESTROY) {
      RemoveWindowSubclass(hwnd, &InAppWebViewManager::FlutterViewSubclassProc, subclassId);
      if (manager) {
        manager->watchedFlutterViews_.erase(hwnd);
      }
    }
    return DefSubclassProc(hwnd, message, wParam, lParam);
  }

  void InAppWebViewManager::onFlutterViewDestroyed(const HWND flutterViewHwnd)
  {
    windowMinimizedStates_.erase(GetAncestor(flutterViewHwnd, GA_ROOT));
    const auto parkIfHosted = [this, flutterViewHwnd](const std::unique_ptr<CustomPlatformView>& platformView)
      {
        const auto webView = platformView ? platformView->view.get() : nullptr;
        const auto host = webView ? webView->hostWindow() : nullptr;
        if (host && GetParent(host) == flutterViewHwnd) {
          webView->park(parkingWindow());
        }
      };

    for (const auto& [id, platformView] : webViews) {
      parkIfHosted(platformView);
    }
    for (const auto& [keepAliveId, platformView] : keepAliveWebViews) {
      parkIfHosted(platformView);
    }
    if (!pendingWebViewHosts_.empty()) {
      ParkPendingWebViewHosts(pendingWebViewHosts_, flutterViewHwnd, parkingWindow());
    }
    if (plugin && plugin->fileDropManager) {
      plugin->fileDropManager->onFlutterViewDestroyed(flutterViewHwnd);
    }
  }

  HWND InAppWebViewManager::parkingWindow()
  {
    if (!parkingWindow_ || !IsWindow(parkingWindow_)) {
      // Never shown; WebView2 does not accept HWND_MESSAGE as a parent.
      parkingWindow_ = CreateWindowEx(WS_EX_TOOLWINDOW, windowClass_.lpszClassName, L"",
        WS_POPUP | WS_CLIPCHILDREN, 0, 0, 0, 0, nullptr, nullptr, windowClass_.hInstance, nullptr);
    }
    return parkingWindow_;
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
    for (const auto host : pendingWebViewHosts_) {
      DestroyWindow(host);
    }
    pendingWebViewHosts_.clear();
    webViews.clear();
    keepAliveWebViews.clear();
    windowWebViews.clear();
    for (const auto flutterViewHwnd : watchedFlutterViews_) {
      RemoveWindowSubclass(flutterViewHwnd, &InAppWebViewManager::FlutterViewSubclassProc, kFlutterViewSubclassId);
    }
    watchedFlutterViews_.clear();
    if (parkingWindow_) {
      DestroyWindow(parkingWindow_);
      parkingWindow_ = nullptr;
    }
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
