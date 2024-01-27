#include <Windows.h>

#include "../utils/log.h"
#include "../utils/strconv.h"
#include "../webview_environment/webview_environment_manager.h"
#include "in_app_browser.h"
#include "in_app_browser_manager.h"

namespace flutter_inappwebview_plugin
{
  InAppBrowser::InAppBrowser(const FlutterInappwebviewWindowsPlugin* plugin, const InAppBrowserCreationParams& params)
    : plugin(plugin),
    m_hInstance(GetModuleHandle(nullptr)),
    id(params.id),
    settings(params.initialSettings),
    channelDelegate(std::make_unique<InAppBrowserChannelDelegate>(id, plugin->registrar->messenger()))
  {

    WNDCLASS wndClass = {};
    wndClass.lpszClassName = InAppBrowser::CLASS_NAME;
    wndClass.hInstance = m_hInstance;
    wndClass.hIcon = LoadIcon(NULL, IDI_WINLOGO);
    wndClass.hCursor = LoadCursor(NULL, IDC_ARROW);
    wndClass.lpfnWndProc = InAppBrowser::WndProc;

    RegisterClass(&wndClass);

    m_hWnd = CreateWindowEx(
      0,                        // Optional window styles.
      wndClass.lpszClassName,		// Window class
      L"",							        // Window text
      WS_OVERLAPPEDWINDOW,			// Window style

      // Size and position
      CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,

      NULL,                // Parent window    
      NULL,                // Menu
      wndClass.hInstance,  // Instance handle
      this                 // Additional application data
    );

    ShowWindow(m_hWnd, settings->hidden ? SW_HIDE : SW_SHOW);

    CreateInAppWebViewEnvParams webViewEnvParams = {
      m_hWnd,
      false
    };


    InAppWebViewCreationParams webViewParams = {
      id,
      params.initialWebViewSettings,
      params.initialUserScripts
    };

    auto webViewEnvironment = params.webViewEnvironmentId.has_value() && map_contains(plugin->webViewEnvironmentManager->webViewEnvironments, params.webViewEnvironmentId.value())
      ? plugin->webViewEnvironmentManager->webViewEnvironments.at(params.webViewEnvironmentId.value()).get() : nullptr;

    InAppWebView::createInAppWebViewEnv(webViewEnvParams, webViewEnvironment,
      [this, params, webViewParams](wil::com_ptr<ICoreWebView2Environment> webViewEnv, wil::com_ptr<ICoreWebView2Controller> webViewController, wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController) -> void
      {
        if (webViewEnv && webViewController) {
          webView = std::make_unique<InAppWebView>(this, this->plugin, webViewParams, m_hWnd, std::move(webViewEnv), std::move(webViewController), nullptr);
          webView->initChannel(std::nullopt, InAppBrowser::METHOD_CHANNEL_NAME_PREFIX + id);

          if (channelDelegate) {
            channelDelegate->onBrowserCreated();
          }

          if (params.urlRequest.has_value()) {
            webView->loadUrl(params.urlRequest.value());
          }
          else if (params.assetFilePath.has_value()) {
            webView->loadFile(params.assetFilePath.value());
          }
          else if (params.data.has_value()) {
            webView->loadData(params.data.value());
          }
        }
        else {
          std::cerr << "Cannot create the InAppWebView instance!" << std::endl;
          close();
        }
      });
  }

  void InAppBrowser::close() const
  {
    DestroyWindow(m_hWnd);
  }

  void InAppBrowser::show() const
  {
    ShowWindow(m_hWnd, SW_SHOW);
  }

  void InAppBrowser::hide() const
  {
    ShowWindow(m_hWnd, SW_HIDE);
  }

  bool InAppBrowser::isHidden() const
  {
    return !IsWindowVisible(m_hWnd);
  }

  void InAppBrowser::didChangeTitle(const std::optional<std::string>& title) const
  {
    if (title.has_value()) {
      SetWindowText(m_hWnd, utf8_to_wide(title.value()).c_str());
    }
  }

  LRESULT CALLBACK InAppBrowser::WndProc(
    HWND window,
    UINT message,
    WPARAM wparam,
    LPARAM lparam
  ) noexcept
  {
    if (message == WM_NCCREATE) {
      auto window_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
      SetWindowLongPtr(window, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(window_struct->lpCreateParams));
    }
    else if (InAppBrowser* that = GetThisFromHandle(window)) {
      return that->MessageHandler(window, message, wparam, lparam);
    }

    return DefWindowProc(window, message, wparam, lparam);
  }

  LRESULT InAppBrowser::MessageHandler(
    HWND hwnd,
    UINT message,
    WPARAM wparam,
    LPARAM lparam
  ) noexcept
  {
    switch (message) {
    case WM_DESTROY: {
      // might receive multiple WM_DESTROY messages.
      if (!destroyed_) {
        destroyed_ = true;

        webView.reset();

        if (channelDelegate) {
          channelDelegate->onExit();
        }

        if (plugin && plugin->inAppBrowserManager) {
          plugin->inAppBrowserManager->browsers.erase(id);
        }
      }
      return 0;
    }
    case WM_DPICHANGED: {
      auto newRectSize = reinterpret_cast<RECT*>(lparam);
      LONG newWidth = newRectSize->right - newRectSize->left;
      LONG newHeight = newRectSize->bottom - newRectSize->top;

      SetWindowPos(hwnd, nullptr, newRectSize->left, newRectSize->top, newWidth,
        newHeight, SWP_NOZORDER | SWP_NOACTIVATE);
      return 0;
    }
    case WM_SIZE: {
      RECT bounds;
      GetClientRect(hwnd, &bounds);
      if (webView) {
        webView->webViewController->put_Bounds(bounds);
      }
      return 0;
    }
    case WM_ACTIVATE: {
      return 0;
    }
    }

    return DefWindowProc(hwnd, message, wparam, lparam);
  }

  InAppBrowser* InAppBrowser::GetThisFromHandle(HWND const window) noexcept
  {
    return reinterpret_cast<InAppBrowser*>(
      GetWindowLongPtr(window, GWLP_USERDATA));
  }

  InAppBrowser::~InAppBrowser()
  {
    debugLog("dealloc InAppBrowser");
    webView.reset();
    SetWindowLongPtr(m_hWnd, GWLP_USERDATA, 0);
    plugin = nullptr;
  }

}