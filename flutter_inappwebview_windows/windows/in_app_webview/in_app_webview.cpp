#include <cstring>
#include <Shlwapi.h>
#include <WebView2EnvironmentOptions.h>
#include <wil/wrl.h>

#include "../custom_platform_view/util/composition.desktop.interop.h"
#include "../types/web_resource_error.h"
#include "../types/web_resource_request.h"
#include "../utils/strconv.h"
#include "../utils/util.h"
#include "in_app_webview.h"
#include "in_app_webview_manager.h"

namespace flutter_inappwebview_plugin
{
  using namespace Microsoft::WRL;

  InAppWebView::InAppWebView(const FlutterInappwebviewWindowsPlugin* plugin, const InAppWebViewCreationParams& params, const HWND parentWindow, wil::com_ptr<ICoreWebView2Environment> webViewEnv,
    wil::com_ptr<ICoreWebView2Controller> webViewController,
    wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController)
    : plugin(plugin), id(params.id), webViewEnv(std::move(webViewEnv)), webViewController(std::move(webViewController)), webViewCompositionController(std::move(webViewCompositionController)),
    settings(params.initialSettings)
  {
    this->webViewController->get_CoreWebView2(webView.put());

    if (this->webViewCompositionController) {
      if (!createSurface(parentWindow, plugin->inAppWebViewManager->compositor())) {
        std::cerr << "Cannot create InAppWebView surface\n";
      }
      registerSurfaceEventHandlers();
    }
    else {
      // Resize WebView to fit the bounds of the parent window
      RECT bounds;
      GetClientRect(parentWindow, &bounds);
      this->webViewController->put_Bounds(bounds);
    }

    wil::com_ptr<ICoreWebView2Settings> webView2Settings;
    if (SUCCEEDED(webView->get_Settings(&webView2Settings))) {
      webView2Settings->put_IsScriptEnabled(settings->javaScriptEnabled);
      webView2Settings->put_IsZoomControlEnabled(settings->supportZoom);

      wil::com_ptr<ICoreWebView2Settings2> webView2Settings2;
      if (SUCCEEDED(webView2Settings->QueryInterface(IID_PPV_ARGS(&webView2Settings2)))) {
        if (!settings->userAgent.empty()) {
          webView2Settings2->put_UserAgent(ansi_to_wide(settings->userAgent).c_str());
        }
      }
    }

    registerEventHandlers();
  }

  InAppWebView::InAppWebView(InAppBrowser* inAppBrowser, const FlutterInappwebviewWindowsPlugin* plugin, const InAppWebViewCreationParams& params, const HWND parentWindow, wil::com_ptr<ICoreWebView2Environment> webViewEnv,
    wil::com_ptr<ICoreWebView2Controller> webViewController,
    wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController)
    : InAppWebView(plugin, params, parentWindow, std::move(webViewEnv), std::move(webViewController), std::move(webViewCompositionController))
  {
    this->inAppBrowser = inAppBrowser;
  }

  void InAppWebView::createInAppWebViewEnv(const HWND parentWindow, const bool willBeSurface, std::function<void(wil::com_ptr<ICoreWebView2Environment> webViewEnv,
    wil::com_ptr<ICoreWebView2Controller> webViewController,
    wil::com_ptr<ICoreWebView2CompositionController> webViewCompositionController)> completionHandler)
  {
    CreateCoreWebView2EnvironmentWithOptions(nullptr, nullptr, nullptr,
      Callback<ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler>(
        [parentWindow, completionHandler, willBeSurface](HRESULT result, wil::com_ptr<ICoreWebView2Environment> env) -> HRESULT
        {
          if (FAILED(result) || !env) {
            completionHandler(nullptr, nullptr, nullptr);
            debugLog(getErrorMessage(result));
            return E_FAIL;
          }

          wil::com_ptr<ICoreWebView2Environment3> webViewEnv3;
          if (willBeSurface && SUCCEEDED(env->QueryInterface(IID_PPV_ARGS(&webViewEnv3)))) {
            webViewEnv3->CreateCoreWebView2CompositionController(parentWindow, Callback<ICoreWebView2CreateCoreWebView2CompositionControllerCompletedHandler>(
              [completionHandler, env](HRESULT result, wil::com_ptr<ICoreWebView2CompositionController> compositionController) -> HRESULT
              {
                wil::com_ptr<ICoreWebView2Controller3> webViewController = compositionController.try_query<ICoreWebView2Controller3>();

                if (FAILED(result) || !webViewController) {
                  completionHandler(nullptr, nullptr, nullptr);
                  debugLog(getErrorMessage(result));
                  return E_FAIL;
                }

                ICoreWebView2Controller3* webViewController3;
                HRESULT hr = webViewController->QueryInterface(IID_PPV_ARGS(&webViewController3));
                if (SUCCEEDED(hr)) {
                  webViewController3->put_BoundsMode(COREWEBVIEW2_BOUNDS_MODE_USE_RAW_PIXELS);
                  webViewController3->put_ShouldDetectMonitorScaleChanges(FALSE);
                  webViewController3->put_RasterizationScale(1.0);
                }
                else {
                  debugLog(getErrorMessage(hr));
                }

                completionHandler(std::move(env), std::move(webViewController), std::move(compositionController));
                return S_OK;
              }
            ).Get());
          }
          else {
            env->CreateCoreWebView2Controller(parentWindow, Callback<ICoreWebView2CreateCoreWebView2ControllerCompletedHandler>(
              [completionHandler, env](HRESULT result, wil::com_ptr<ICoreWebView2Controller> controller) -> HRESULT
              {
                if (FAILED(result) || !controller) {
                  completionHandler(nullptr, nullptr, nullptr);
                  debugLog(getErrorMessage(result));
                  return E_FAIL;
                }

                completionHandler(std::move(env), std::move(controller), nullptr);
                return S_OK;
              }).Get());
          }
          return S_OK;
        }).Get());
  }

  void InAppWebView::initChannel(const std::optional<std::variant<std::string, int64_t>> viewId, const std::optional<std::string> channelName)
  {
    if (viewId.has_value()) {
      id = viewId.value();
    }
    channelDelegate = channelName.has_value() ? std::make_unique<WebViewChannelDelegate>(this, plugin->registrar->messenger(), channelName.value()) :
      std::make_unique<WebViewChannelDelegate>(this, plugin->registrar->messenger());
  }

  void InAppWebView::registerEventHandlers()
  {
    if (!webView) {
      return;
    }

    webView->add_NavigationStarting(
      Callback<ICoreWebView2NavigationStartingEventHandler>(
        [this](ICoreWebView2* sender, ICoreWebView2NavigationStartingEventArgs* args)
        {
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

          auto urlRequest = std::make_shared<URLRequest>(url, method, headers, std::nullopt);
          auto navigationAction = std::make_shared<NavigationAction>(
            urlRequest,
            true
          );

          UINT64 navigationId;
          if (SUCCEEDED(args->get_NavigationId(&navigationId))) {
            navigationActions.insert({ navigationId, navigationAction }); callShouldOverrideUrlLoading_ =
          }

          if (callShouldOverrideUrlLoading_ && requestMethod == nullptr) {
            // for some reason, we can't cancel and load an URL with other HTTP methods than GET,
            // so ignore the shouldOverrideUrlLoading event.

            auto callback = std::make_unique<WebViewChannelDelegate::ShouldOverrideUrlLoadingCallback>();
            callback->nonNullSuccess = [this, urlRequest](const NavigationActionPolicy actionPolicy)
              {
                callShouldOverrideUrlLoading_ = false;
                if (actionPolicy == allow) {
                  loadUrl(*urlRequest);
                }
                return false;
              };
            auto defaultBehaviour = [this, urlRequest](const std::optional<NavigationActionPolicy> actionPolicy)
              {
                callShouldOverrideUrlLoading_ = false;
                loadUrl(*urlRequest);
              };
            callback->defaultBehaviour = defaultBehaviour;
            callback->error = [defaultBehaviour](const std::string& error_code, const std::string& error_message, const flutter::EncodableValue* error_details)
              {
                debugLog(error_code + ", " + error_message);
                defaultBehaviour(std::nullopt);
              };
            channelDelegate->shouldOverrideUrlLoading(std::move(navigationAction), std::move(callback));
            args->put_Cancel(true);
          }
          else {
            callShouldOverrideUrlLoading_ = true;
            channelDelegate->onLoadStart(url);
            args->put_Cancel(false);
          }

          return S_OK;
        }
    ).Get(), nullptr);

    webView->add_NavigationCompleted(
      Callback<ICoreWebView2NavigationCompletedEventHandler>(
        [this](ICoreWebView2* sender, ICoreWebView2NavigationCompletedEventArgs* args)
        {
          std::shared_ptr<NavigationAction> navigationAction;
          UINT64 navigationId;
          if (SUCCEEDED(args->get_NavigationId(&navigationId))) {
            navigationAction = map_at_or_null(navigationActions, navigationId);
            if (navigationAction) {
              navigationActions.erase(navigationId);
            }
          }

          COREWEBVIEW2_WEB_ERROR_STATUS webErrorType = COREWEBVIEW2_WEB_ERROR_STATUS_UNKNOWN;
          args->get_WebErrorStatus(&webErrorType);

          BOOL isSuccess;
          args->get_IsSuccess(&isSuccess);

          if (channelDelegate) {
            LPWSTR uri = nullptr;
            std::optional<std::string> url = SUCCEEDED(webView->get_Source(&uri)) ? wide_to_utf8(std::wstring(uri)) : std::optional<std::string>{};
            if (isSuccess) {
              channelDelegate->onLoadStop(url);
            }
            else if (!InAppWebView::isSslError(webErrorType) && navigationAction) {
              auto webResourceRequest = std::make_unique<WebResourceRequest>(url, navigationAction->request->method, navigationAction->request->headers, navigationAction->isForMainFrame);
              int httpStatusCode = 0;
              wil::com_ptr<ICoreWebView2NavigationCompletedEventArgs2> args2;
              if (SUCCEEDED(args->QueryInterface(IID_PPV_ARGS(&args2))) && SUCCEEDED(args2->get_HttpStatusCode(&httpStatusCode)) && httpStatusCode >= 400) {
                auto webResourceResponse = std::make_unique<WebResourceResponse>(httpStatusCode);
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

    webView->add_DocumentTitleChanged(Callback<ICoreWebView2DocumentTitleChangedEventHandler>(
      [this](ICoreWebView2* sender, IUnknown* args)
      {
        if (channelDelegate) {
          wil::unique_cotaskmem_string title;
          sender->get_DocumentTitle(&title);
          channelDelegate->onTitleChanged(title.is_valid() ? wide_to_ansi(title.get()) : std::optional<std::string>{});
        }
        return S_OK;
      }
    ).Get(), nullptr);
  }

  void InAppWebView::registerSurfaceEventHandlers()
  {
    if (!webViewCompositionController) {
      return;
    }

    webViewCompositionController->add_CursorChanged(
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
      .Get(), nullptr);
  }

  std::optional<std::string> InAppWebView::getUrl() const
  {
    LPWSTR uri;
    return SUCCEEDED(webView->get_Source(&uri)) ? wide_to_utf8(uri) : std::optional<std::string>{};
  }

  std::optional<std::string> InAppWebView::getTitle() const
  {
    LPWSTR title;
    return SUCCEEDED(webView->get_DocumentTitle(&title)) ? wide_to_utf8(title) : std::optional<std::string>{};
  }

  void InAppWebView::loadUrl(const URLRequest& urlRequest) const
  {
    if (!webView || !urlRequest.url.has_value()) {
      return;
    }

    std::wstring url = ansi_to_wide(urlRequest.url.value());

    wil::com_ptr<ICoreWebView2Environment2> webViewEnv2;
    wil::com_ptr<ICoreWebView2_2> webView2;
    if (SUCCEEDED(webViewEnv->QueryInterface(IID_PPV_ARGS(&webViewEnv2))) && SUCCEEDED(webView->QueryInterface(IID_PPV_ARGS(&webView2)))) {
      wil::com_ptr<ICoreWebView2WebResourceRequest> webResourceRequest;
      std::wstring method = urlRequest.method.has_value() ? ansi_to_wide(urlRequest.method.value()) : L"GET";

      wil::com_ptr<IStream> postDataStream = nullptr;
      if (urlRequest.body.has_value()) {
        auto postData = std::string(urlRequest.body->begin(), urlRequest.body->end());
        postDataStream = SHCreateMemStream(
          reinterpret_cast<const BYTE*>(postData.data()), static_cast<UINT>(postData.length()));
      }
      webViewEnv2->CreateWebResourceRequest(
        url.c_str(),
        method.c_str(),
        postDataStream.get(),
        L"",
        &webResourceRequest
      );
      wil::com_ptr<ICoreWebView2HttpRequestHeaders> requestHeaders;
      if (SUCCEEDED(webResourceRequest->get_Headers(&requestHeaders))) {
        if (method.compare(L"GET") != 0) {
          requestHeaders->SetHeader(L"Flutter-InAppWebView-Request-Method", method.c_str());
        }
        if (urlRequest.headers.has_value()) {
          auto& headers = urlRequest.headers.value();
          for (auto const& [key, val] : headers) {
            requestHeaders->SetHeader(ansi_to_wide(key).c_str(), ansi_to_wide(val).c_str());
          }
        }
      }
      webView2->NavigateWithWebResourceRequest(webResourceRequest.get());
    }
    else {
      webView->Navigate(url.c_str());
    }
  }

  void InAppWebView::reload() const
  {
    webView->Reload();
  }

  void InAppWebView::goBack() const
  {
    webView->GoBack();
  }

  void InAppWebView::goForward() const
  {
    webView->GoForward();
  }

  void InAppWebView::evaluateJavascript(const std::string& source, std::function<void(std::string)> completionHanlder) const
  {
    webView->ExecuteScript(ansi_to_wide(source).c_str(),
      Callback<ICoreWebView2ExecuteScriptCompletedHandler>(
        [completionHanlder = std::move(completionHanlder)](HRESULT error, PCWSTR result) -> HRESULT
        {
          if (error != S_OK) {
            debugLog(getErrorMessage(error));
          }
          completionHanlder(wide_to_ansi(result));
          return S_OK;
        }).Get());
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

  void InAppWebView::setPointerButtonState(InAppWebViewPointerButton button, bool is_down)
  {
    if (!webViewCompositionController) {
      return;
    }

    COREWEBVIEW2_MOUSE_EVENT_KIND kind;
    switch (button) {
    case InAppWebViewPointerButton::Primary:
      virtualKeys_.setIsLeftButtonDown(is_down);
      kind = is_down ? COREWEBVIEW2_MOUSE_EVENT_KIND_LEFT_BUTTON_DOWN
        : COREWEBVIEW2_MOUSE_EVENT_KIND_LEFT_BUTTON_UP;
      break;
    case InAppWebViewPointerButton::Secondary:
      virtualKeys_.setIsRightButtonDown(is_down);
      kind = is_down ? COREWEBVIEW2_MOUSE_EVENT_KIND_RIGHT_BUTTON_DOWN
        : COREWEBVIEW2_MOUSE_EVENT_KIND_RIGHT_BUTTON_UP;
      break;
    case InAppWebViewPointerButton::Tertiary:
      virtualKeys_.setIsMiddleButtonDown(is_down);
      kind = is_down ? COREWEBVIEW2_MOUSE_EVENT_KIND_MIDDLE_BUTTON_DOWN
        : COREWEBVIEW2_MOUSE_EVENT_KIND_MIDDLE_BUTTON_UP;
      break;
    default:
      kind = static_cast<COREWEBVIEW2_MOUSE_EVENT_KIND>(0);
    }

    webViewCompositionController->SendMouseInput(kind, virtualKeys_.state(), 0,
      lastCursorPos_);
  }

  void InAppWebView::sendScroll(double delta, bool horizontal)
  {
    if (!webViewCompositionController) {
      return;
    }

    // delta * 6 gives me a multiple of WHEEL_DELTA (120)
    constexpr auto kScrollMultiplier = 6;

    auto offset = static_cast<short>(delta * kScrollMultiplier);

    /*
    // For some reason,
    // setting the point other than (x: 0, y: 0)
    // will not make the scroll work.
    // Unfortunately, this will break the scroll event
    // for nested HTML scrollable elements.
    POINT point;
    point.x = 0;
    point.y = 0;


    if (horizontal) {
      webViewCompositionController->SendMouseInput(
        COREWEBVIEW2_MOUSE_EVENT_KIND_HORIZONTAL_WHEEL, virtual_keys_.state(),
        offset, point);
    }
    else {
      webViewCompositionController->SendMouseInput(COREWEBVIEW2_MOUSE_EVENT_KIND_WHEEL,
        virtual_keys_.state(), offset,
        point);
    }
    */

    // Workaround for scroll events
    auto workaroundScrollJS = "(function(horizontal, offset, x, y) { \
  function elemCanScrollY(elem) { \
    if (elem.scrollTop > 0) { \
      return elem; \
    } else { \
      elem.scrollTop++; \
      const top = elem.scrollTop; \
      top && (elem.scrollTop = 0); \
      if (top > 0) { \
        return elem; \
      } else { \
        return elemCanScrollY(elem.parentElement); \
      } \
    } \
  } \
  function elemCanScrollX(elem) { \
    if (elem.scrollLeft > 0) { \
      return elem; \
    } else { \
      elem.scrollLeft++; \
      const left = elem.scrollLeft; \
      left && (elem.scrollLeft = 0); \
      if (left > 0) { \
        return elem; \
      } else { \
        return elemCanScrollX(elem.parentElement); \
      } \
    } \
  } \
  const elem = document.elementFromPoint(x, y); \
  const elem2 = horizontal ? elemCanScrollX(elem) : elemCanScrollY(elem); \
  const handled = elem2 != null && elem2 != document.documentElement && elem2 != document.body; \
  if (handled) { \
    elem2.scrollBy({left: horizontal ? offset : 0, top: horizontal ? 0 : offset}); \
  } \
  return handled; \
})(" + std::to_string(horizontal) + ", " + std::to_string(offset) + ", " + std::to_string(lastCursorPos_.x) + ", " + std::to_string(lastCursorPos_.y) + ");";

    webView->ExecuteScript(ansi_to_wide(workaroundScrollJS).c_str(), Callback<ICoreWebView2ExecuteScriptCompletedHandler>(
      [this, horizontal, offset](HRESULT error, PCWSTR result) -> HRESULT
      {
        if (webViewCompositionController && (error != S_OK || wide_to_ansi(result).compare("false") == 0)) {
          // try to use native mouse wheel handler

          POINT point;
          point.x = 0;
          point.y = 0;

          if (horizontal) {
            webViewCompositionController->SendMouseInput(
              COREWEBVIEW2_MOUSE_EVENT_KIND_HORIZONTAL_WHEEL, virtualKeys_.state(),
              offset, point);
          }
          else {
            webViewCompositionController->SendMouseInput(COREWEBVIEW2_MOUSE_EVENT_KIND_WHEEL,
              virtualKeys_.state(), offset,
              point);
          }
        }

        return S_OK;
      }).Get());
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

  InAppWebView::~InAppWebView()
  {
    debugLog("dealloc InAppWebView");
    if (webView) {
      webView->Stop();
    }
    if (webViewController) {
      webViewController->Close();
    }
    navigationActions.clear();
    inAppBrowser = nullptr;
    plugin = nullptr;
  }
}