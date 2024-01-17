#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_

#include <functional>
#include <WebView2.h>
#include <wil/com.h>
#include <windows.ui.composition.desktop.h>
#include <windows.ui.composition.h>
#include <winrt/base.h>

#include "../flutter_inappwebview_windows_plugin.h"
#include "../types/navigation_action.h"
#include "../types/url_request.h"
#include "../types/web_history.h"
#include "in_app_webview_settings.h"
#include "webview_channel_delegate.h"

namespace flutter_inappwebview_plugin
{
  class InAppBrowser;

  using namespace Microsoft::WRL;

  // custom_platform_view
  enum class InAppWebViewPointerButton { None, Primary, Secondary, Tertiary };
  enum class InAppWebViewPointerEventKind { Activate, Down, Enter, Leave, Up, Update };
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

  struct InAppWebViewCreationParams {
    const std::variant<std::string, int64_t> id;
    const std::shared_ptr<InAppWebViewSettings> initialSettings;
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
    std::map<UINT64, std::shared_ptr<NavigationAction>> navigationActions = {};
    const std::shared_ptr<InAppWebViewSettings> settings;
    InAppBrowser* inAppBrowser = nullptr;

    InAppWebView(const FlutterInappwebviewWindowsPlugin* plugin, const InAppWebViewCreationParams& params, const HWND parentWindow,
      wil::com_ptr<ICoreWebView2Environment> webViewEnv,
      wil::com_ptr<ICoreWebView2Controller> webViewController,
      wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController);
    InAppWebView(InAppBrowser* inAppBrowser, const FlutterInappwebviewWindowsPlugin* plugin, const InAppWebViewCreationParams& params, const HWND parentWindow,
      wil::com_ptr<ICoreWebView2Environment> webViewEnv,
      wil::com_ptr<ICoreWebView2Controller> webViewController,
      wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController);
    ~InAppWebView();

    static void createInAppWebViewEnv(const HWND parentWindow, const bool willBeSurface, std::function<void(wil::com_ptr<ICoreWebView2Environment> webViewEnv,
      wil::com_ptr<ICoreWebView2Controller> webViewController,
      wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController)> completionHandler);

    // custom_platform_view
    ABI::Windows::UI::Composition::IVisual* const surface()
    {
      return surface_.get();
    }
    void setSurfaceSize(size_t width, size_t height, float scale_factor);
    void setCursorPos(double x, double y);
    void setPointerUpdate(int32_t pointer, InAppWebViewPointerEventKind eventKind,
      double x, double y, double size, double pressure);
    void setPointerButtonState(InAppWebViewPointerButton button, bool isDown);
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
    std::optional<std::string> getUrl() const;
    std::optional<std::string> getTitle() const;
    void loadUrl(const URLRequest& urlRequest) const;
    void reload() const;
    void goBack();
    void goForward();
    void evaluateJavascript(const std::string& source, std::function<void(std::string)> completionHanlder) const;
    void getCopyBackForwardList(const std::function<void(std::unique_ptr<WebHistory>)> completionHandler) const;

    static bool isSslError(const COREWEBVIEW2_WEB_ERROR_STATUS& webErrorStatus);
  private:
    // custom_platform_view
    winrt::com_ptr<ABI::Windows::UI::Composition::IVisual> surface_;
    SurfaceSizeChangedCallback surfaceSizeChangedCallback_;
    CursorChangedCallback cursorChangedCallback_;
    float scaleFactor_ = 1.0;
    POINT lastCursorPos_ = { 0, 0 };
    VirtualKeyState virtualKeys_;

    bool callShouldOverrideUrlLoading_ = true;
    void InAppWebView::registerEventHandlers();
    void InAppWebView::registerSurfaceEventHandlers();
  };
}
#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_IN_APP_WEBVIEW_H_