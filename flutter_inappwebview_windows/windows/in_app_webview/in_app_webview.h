#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_

#include <functional>
#include <WebView2.h>
#include <wil/com.h>
#include <windows.ui.composition.desktop.h>
#include <windows.ui.composition.h>
#include <winrt/base.h>

#include "../flutter_inappwebview_windows_plugin.h"
#include "../plugin_scripts_js/plugin_scripts_util.h"
#include "../types/content_world.h"
#include "../types/favicon_image_format.h"
#include "../types/navigation_action.h"
#include "../types/screenshot_configuration.h"
#include "../types/ssl_certificate.h"
#include "../types/url_request.h"
#include "../types/web_history.h"
#include "../utils/uuid.h"
#include "../webview_environment/webview_environment.h"
#include "in_app_webview_settings.h"
#include "user_content_controller.h"
#include "webview_channel_delegate.h"
#include "../web_message/web_message_channel.h"
#include "../web_message/web_message_listener.h"
#include "../find_interaction/find_interaction_controller.h"
#include "../web_notification/web_notification_controller.h"
#include "../print_job/print_job_settings.h"

#include <WebView2EnvironmentOptions.h>

namespace flutter_inappwebview_plugin
{
  class InAppBrowser;
  class PrintJobManager;
  class PrintJobController;

  using namespace Microsoft::WRL;

  // custom_platform_view
  enum class InAppWebViewPointerButton { None, Primary, Secondary, Tertiary };
  enum class InAppWebViewPointerEventKind { Activate, Down, Enter, Leave, Up, Update, Cancel };
  typedef std::function<void(size_t width, size_t height)>
    SurfaceSizeChangedCallback;
  typedef std::function<void(const HCURSOR)> CursorChangedCallback;
  struct VirtualKeyState {
  public:
    inline void setIsLeftButtonDown(bool is_down)
    {
      set(COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS::
        COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS_LEFT_BUTTON,
        is_down);
    }

    inline void setIsRightButtonDown(bool is_down)
    {
      set(COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS::
        COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS_RIGHT_BUTTON,
        is_down);
    }

    inline void setIsMiddleButtonDown(bool is_down)
    {
      set(COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS::
        COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS_MIDDLE_BUTTON,
        is_down);
    }

    inline COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS state() const { return state_; }

  private:
    COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS state_ =
      COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS::
      COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS_NONE;

    inline void set(COREWEBVIEW2_MOUSE_EVENT_VIRTUAL_KEYS key, bool flag)
    {
      if (flag) {
        state_ |= key;
      }
      else {
        state_ &= ~key;
      }
    }
  };

  const std::string CALL_ASYNC_JAVASCRIPT_WRAPPER_JS = "(async function(" + VAR_FUNCTION_ARGUMENT_NAMES + ") { \
        " + VAR_FUNCTION_BODY + " \
    })(" + VAR_FUNCTION_ARGUMENT_VALUES + ");";

  struct InAppWebViewCreationParams {
    const std::variant<std::string, int64_t> id;
    const std::shared_ptr<InAppWebViewSettings> initialSettings;
    const std::optional<std::vector<std::shared_ptr<UserScript>>> initialUserScripts;
  };

  class InAppWebView
  {
  public:
    static inline const std::string METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_inappwebview_";

    const FlutterInappwebviewWindowsPlugin* plugin;
    std::variant<std::string, int64_t> id;
    wil::com_ptr<ICoreWebView2Environment> webViewEnv;
    wil::com_ptr<ICoreWebView2Controller> webViewController;
    wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController;
    wil::com_ptr<ICoreWebView2> webView;
    std::unique_ptr<WebViewChannelDelegate> channelDelegate;
    std::unique_ptr<FindInteractionController> findInteractionController;
    std::unique_ptr<PrintJobManager> printJobManager;
    std::shared_ptr<InAppWebViewSettings> settings;
    InAppBrowser* inAppBrowser = nullptr;
    std::unique_ptr<UserContentController> userContentController;

    InAppWebView(const FlutterInappwebviewWindowsPlugin* plugin, const InAppWebViewCreationParams& params, const HWND parentWindow,
      wil::com_ptr<ICoreWebView2Environment> webViewEnv,
      wil::com_ptr<ICoreWebView2Controller> webViewController,
      wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController);
    InAppWebView(InAppBrowser* inAppBrowser, const FlutterInappwebviewWindowsPlugin* plugin, const InAppWebViewCreationParams& params, const HWND parentWindow,
      wil::com_ptr<ICoreWebView2Environment> webViewEnv,
      wil::com_ptr<ICoreWebView2Controller> webViewController,
      wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController);
    ~InAppWebView();

    static void createInAppWebViewEnv(const HWND parentWindow, const bool& willBeSurface, WebViewEnvironment* webViewEnvironment, const std::shared_ptr<InAppWebViewSettings> initialSettings, std::function<void(wil::com_ptr<ICoreWebView2Environment> webViewEnv,
      wil::com_ptr<ICoreWebView2Controller> webViewController,
      wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController)> completionHandler);

    // custom_platform_view
    ABI::Windows::UI::Composition::IVisual* const surface()
    {
      return surface_.get();
    }
    void setSurfaceSize(size_t width, size_t height, float scale_factor);
    void setPosition(size_t x, size_t y, float scale_factor);
    void setCursorPos(double x, double y);
    void setPointerUpdate(int32_t pointer, InAppWebViewPointerEventKind eventKind,
      double x, double y, double size, double pressure);
    void setPointerButtonState(InAppWebViewPointerEventKind kind, InAppWebViewPointerButton button);
    void sendScroll(double offset, bool horizontal);
    void setScrollDelta(double delta_x, double delta_y);
    void onSurfaceSizeChanged(SurfaceSizeChangedCallback callback)
    {
      surfaceSizeChangedCallback_ = std::move(callback);
    }
    void onCursorChanged(CursorChangedCallback callback)
    {
      cursorChangedCallback_ = std::move(callback);
    }
    bool createSurface(const HWND parentWindow,
      winrt::com_ptr<ABI::Windows::UI::Composition::ICompositor> compositor);

    void initChannel(const std::optional<std::variant<std::string, int64_t>> viewId, const std::optional<std::string> channelName);
    void prepare(const InAppWebViewCreationParams& params);
    std::optional<std::string> getUrl() const;
    std::optional<std::string> getTitle() const;
    std::optional<int64_t> getFrameId() const;
    std::optional<int64_t> getMemoryUsageTargetLevel() const;
    void setMemoryUsageTargetLevel(const int64_t& level) const;
    void getFavicon(const std::optional<std::string>& url, const std::optional<FaviconImageFormat>& faviconImageFormat,
      const std::function<void(const std::optional<std::vector<uint8_t>>)> completionHandler) const;
    void showSaveAsUI(const std::function<void(const std::optional<int64_t>)> completionHandler) const;
    void loadUrl(const std::shared_ptr<URLRequest> urlRequest) const;
    void loadFile(const std::string& assetFilePath) const;
    void loadData(const std::string& data) const;
    void reload() const;
    void goBack();
    bool canGoBack() const;
    void goForward();
    bool canGoForward() const;
    void goBackOrForward(const int64_t& steps);
    void canGoBackOrForward(const int64_t& steps, std::function<void(bool)> completionHandler) const;
    bool isLoading() const
    {
      return isLoading_;
    }
    void stopLoading() const;
    void evaluateJavascript(const std::string& source, const std::shared_ptr<ContentWorld> contentWorld, const std::function<void(std::string)> completionHandler) const;
    void callAsyncJavaScript(const std::string& functionBody, const std::string& argumentsAsJson, const std::shared_ptr<ContentWorld> contentWorld, const std::function<void(std::string)> completionHandler) const;
    void getCopyBackForwardList(const std::function<void(std::unique_ptr<WebHistory>)> completionHandler) const;
    void addUserScript(const std::shared_ptr<UserScript> userScript) const;
    void removeUserScript(const int64_t index, const std::shared_ptr<UserScript> userScript) const;
    void removeUserScriptsByGroupName(const std::string& groupName) const;
    void removeAllUserScripts() const;
    void takeScreenshot(const std::optional<std::shared_ptr<ScreenshotConfiguration>> screenshotConfiguration, const std::function<void(const std::optional<std::string>)> completionHandler) const;
    void setSettings(const std::shared_ptr<InAppWebViewSettings> newSettings, const flutter::EncodableMap& newSettingsMap);
    flutter::EncodableValue getSettings() const;
    void openDevTools() const;
    void callDevToolsProtocolMethod(const std::string& methodName, const std::optional<std::string>& parametersAsJson, const std::function<void(const HRESULT& errorCode, const std::optional<std::string>&)> completionHandler) const;
    void addDevToolsProtocolEventListener(const std::string& eventName);
    void removeDevToolsProtocolEventListener(const std::string& eventName);
    void pause() const;
    void resume() const;
    void getCertificate(const std::function<void(const std::optional<std::unique_ptr<SslCertificate>>)> completionHandler) const;
    void clearSslPreferences(const std::function<void()> completionHandler) const;
    bool isInterfaceSupported(const std::string& interfaceName) const;
    double getZoomScale() const;
    int64_t getProgress() const;
    void scrollTo(const int64_t& x, const int64_t& y, const bool& animated) const;
    void scrollBy(const int64_t& x, const int64_t& y, const bool& animated) const;
    void getScrollX(const std::function<void(const std::optional<int64_t>)> completionHandler) const;
    void getScrollY(const std::function<void(const std::optional<int64_t>)> completionHandler) const;
    void getContentHeight(const std::function<void(const std::optional<int64_t>)> completionHandler) const;
    void getContentWidth(const std::function<void(const std::optional<int64_t>)> completionHandler) const;
    void isSecureContext(const std::function<void(const bool)> completionHandler) const;
    void injectCSSCode(const std::string& source) const;
    void injectCSSFileFromUrl(const std::string& urlFile) const;

    void addWebMessageListener(const std::string& jsObjectName,
      const std::vector<std::string>& allowedOriginRules,
      const std::string& listenerId);
    void createWebMessageChannel(
      const std::function<void(const std::optional<std::string>&)> callback);
    WebMessageChannel* getWebMessageChannel(const std::string& channelId) const;
    void postWebMessage(const std::string& messageData,
      const std::string& targetOrigin,
      int64_t messageType);
    void setWebMessageCallback(const std::string& channelId, int portIndex);
    void postWebMessageOnPort(const std::string& channelId, int portIndex,
      const std::string& messageData, int64_t messageType);
    void closeWebMessagePort(const std::string& channelId, int portIndex);
    void disposeWebMessageChannel(const std::string& channelId);

    void addWebNotificationController(const std::string& id, std::shared_ptr<WebNotificationController> controller);
    WebNotificationController* getWebNotificationController(const std::string& id) const;
    void eraseWebNotificationController(const std::string& id);
    void disposeAllWebNotificationControllers();

    void addPrintJobController(const std::string& id, std::shared_ptr<PrintJobController> controller);
    PrintJobController* getPrintJobController(const std::string& id) const;
    void erasePrintJobController(const std::string& id);
    void disposeAllPrintJobControllers();

    void printCurrentPage(std::shared_ptr<PrintJobSettings> settings,
      const std::function<void(const std::optional<std::string>&)> completionHandler);

    void createPdf(std::shared_ptr<PrintJobSettings> settings,
      const std::function<void(const std::optional<std::vector<uint8_t>>&)> completionHandler);

    std::string pageFrameId() const
    {
      return pageFrameId_;
    }

    static bool isSslError(const COREWEBVIEW2_WEB_ERROR_STATUS& webErrorStatus);
  private:
    // custom_platform_view
    winrt::com_ptr<ABI::Windows::UI::Composition::IVisual> surface_;
    SurfaceSizeChangedCallback surfaceSizeChangedCallback_;
    CursorChangedCallback cursorChangedCallback_;
    float scaleFactor_ = 1.0;
    POINT lastCursorPos_ = { 0, 0 };
    VirtualKeyState virtualKeys_;

    const std::string expectedBridgeSecret = get_uuid();
    bool javaScriptBridgeEnabled = true;
    std::map<UINT64, std::shared_ptr<NavigationAction>> navigationActions_ = {};
    std::shared_ptr<NavigationAction> lastNavigationAction_;
    bool isLoading_ = false;
    std::string pageFrameId_;
    std::map<std::string, std::pair<wil::com_ptr<ICoreWebView2DevToolsProtocolEventReceiver>, EventRegistrationToken>> devToolsProtocolEventListener_ = {};
    int64_t previousAuthRequestFailureCount = 0;
    double zoomScaleFactor_ = 1.0;
    int64_t progress_ = 0;
    std::map<std::string, std::unique_ptr<WebMessageChannel>> webMessageChannels_;
    std::map<std::string, std::unique_ptr<WebMessageListener>> webMessageListeners_;
    std::map<std::string, std::shared_ptr<WebNotificationController>> webNotificationControllers_;
    std::map<std::string, std::shared_ptr<PrintJobController>> printJobControllers_;

    void registerEventHandlers();
    void registerSurfaceEventHandlers();
    HRESULT onCallJsHandler(const bool& isMainFrame, ICoreWebView2WebMessageReceivedEventArgs* args);
  };
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_