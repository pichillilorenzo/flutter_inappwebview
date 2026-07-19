#include "webview_drop_target.h"

#include <algorithm>
#include <map>

#include "../in_app_webview/in_app_webview.h"
#include "../utils/log.h"

namespace flutter_inappwebview_plugin
{
  // One drop target per Flutter view window; all access is on the UI thread.
  static std::map<HWND, WebViewDropTarget*> g_targets;

  WebViewDropTarget::WebViewDropTarget(HWND flutterViewHwnd, bool oleInitialized)
    : flutterViewHwnd_(flutterViewHwnd), oleInitialized_(oleInitialized)
  {}

  void WebViewDropTarget::RegisterWebView(HWND flutterViewHwnd, InAppWebView* webView)
  {
    if (!flutterViewHwnd || !webView) {
      return;
    }
    auto it = g_targets.find(flutterViewHwnd);
    if (it == g_targets.end()) {
      // RegisterDragDrop needs an STA. OleInitialize returns S_FALSE when OLE
      // is already initialized on this thread (still balanced by a matching
      // OleUninitialize); RPC_E_CHANGED_MODE means an MTA is active and drag
      // and drop cannot work here.
      const auto oleHr = OleInitialize(nullptr);
      const bool oleInitialized = SUCCEEDED(oleHr);
      auto target = new WebViewDropTarget(flutterViewHwnd, oleInitialized);
      const auto hr = RegisterDragDrop(flutterViewHwnd, target);
      if (FAILED(hr)) {
        // Another plugin may already own the window's drop target
        // (DRAGDROP_E_ALREADYREGISTERED) - drag and drop into webviews is
        // unavailable then, but nothing else breaks.
        failedLog(hr);
        if (oleInitialized) {
          OleUninitialize();
        }
        target->Release();
        return;
      }
      it = g_targets.emplace(flutterViewHwnd, target).first;
    }
    it->second->webViews_.push_back(webView);
  }

  void WebViewDropTarget::UnregisterWebView(InAppWebView* webView)
  {
    for (auto it = g_targets.begin(); it != g_targets.end(); ++it) {
      auto target = it->second;
      auto& webViews = target->webViews_;
      const auto found = std::find(webViews.begin(), webViews.end(), webView);
      if (found == webViews.end()) {
        continue;
      }
      webViews.erase(found);
      if (target->currentWebView_ == webView) {
        target->currentWebView_ = nullptr;
      }
      if (webViews.empty()) {
        RevokeDragDrop(target->flutterViewHwnd_);
        if (target->currentDataObject_) {
          target->currentDataObject_->Release();
          target->currentDataObject_ = nullptr;
        }
        const bool oleInitialized = target->oleInitialized_;
        target->Release();
        if (oleInitialized) {
          OleUninitialize();
        }
        g_targets.erase(it);
      }
      return;
    }
  }

  HRESULT WebViewDropTarget::QueryInterface(REFIID riid, void** ppv)
  {
    if (riid == IID_IUnknown || riid == IID_IDropTarget) {
      *ppv = static_cast<IDropTarget*>(this);
      AddRef();
      return S_OK;
    }
    *ppv = nullptr;
    return E_NOINTERFACE;
  }

  ULONG WebViewDropTarget::AddRef()
  {
    return InterlockedIncrement(&refCount_);
  }

  ULONG WebViewDropTarget::Release()
  {
    const auto count = InterlockedDecrement(&refCount_);
    if (count == 0) {
      delete this;
    }
    return count;
  }

  InAppWebView* WebViewDropTarget::webViewAt(POINTL screenPoint,
    POINT* webViewPoint) const
  {
    RECT client;
    if (!GetClientRect(flutterViewHwnd_, &client) || client.right == 0) {
      return nullptr;
    }
    // Mapping through both client corners stays correct on RTL-mirrored
    // windows (WS_EX_LAYOUTRTL), where ClientToScreen(0,0) is the top-RIGHT.
    POINT p0 = { 0, 0 };
    POINT p1 = { client.right, client.bottom };
    ClientToScreen(flutterViewHwnd_, &p0);
    ClientToScreen(flutterViewHwnd_, &p1);
    if (p1.x == p0.x || p1.y == p0.y) {
      return nullptr;
    }
    const auto localX = static_cast<double>(screenPoint.x - p0.x) *
      client.right / (p1.x - p0.x);
    const auto localY = static_cast<double>(screenPoint.y - p0.y) *
      client.bottom / (p1.y - p0.y);

    for (const auto webView : webViews_) {
      const auto offset = webView->widgetOffset();
      const auto size = webView->surfaceSize();
      if (localX >= offset.x && localX < offset.x + size.cx &&
        localY >= offset.y && localY < offset.y + size.cy) {
        webViewPoint->x = static_cast<LONG>(localX - offset.x);
        webViewPoint->y = static_cast<LONG>(localY - offset.y);
        return webView;
      }
    }
    return nullptr;
  }

  void WebViewDropTarget::forwardLeave()
  {
    if (currentWebView_) {
      auto controller = currentWebView_->webViewCompositionController
        .try_query<ICoreWebView2CompositionController3>();
      if (controller) {
        failedLog(controller->DragLeave());
      }
      currentWebView_ = nullptr;
    }
  }

  HRESULT WebViewDropTarget::DragEnter(IDataObject* dataObject, DWORD keyState,
    POINTL point, DWORD* effect)
  {
    if (currentDataObject_) {
      currentDataObject_->Release();
    }
    currentDataObject_ = dataObject;
    if (currentDataObject_) {
      currentDataObject_->AddRef();
    }
    currentWebView_ = nullptr;
    return DragOver(keyState, point, effect);
  }

  HRESULT WebViewDropTarget::DragOver(DWORD keyState, POINTL point,
    DWORD* effect)
  {
    // On entry *effect holds the effects the drop source allows; forward it so
    // WebView2 can pick one. Zeroing it here would make WebView2 return NONE
    // and OLE would never call Drop.
    const DWORD allowedEffects = *effect;
    POINT webViewPoint;
    const auto webView = webViewAt(point, &webViewPoint);
    if (webView != currentWebView_) {
      forwardLeave();
    }
    auto controller = webView
      ? webView->webViewCompositionController
        .try_query<ICoreWebView2CompositionController3>()
      : nullptr;
    if (!controller) {
      *effect = DROPEFFECT_NONE;
      return S_OK;
    }
    if (webView != currentWebView_) {
      currentWebView_ = webView;
      *effect = allowedEffects;
      failedLog(controller->DragEnter(currentDataObject_, keyState,
        webViewPoint, effect));
      return S_OK;
    }
    *effect = allowedEffects;
    failedLog(controller->DragOver(keyState, webViewPoint, effect));
    return S_OK;
  }

  HRESULT WebViewDropTarget::DragLeave()
  {
    forwardLeave();
    if (currentDataObject_) {
      currentDataObject_->Release();
      currentDataObject_ = nullptr;
    }
    return S_OK;
  }

  HRESULT WebViewDropTarget::Drop(IDataObject* dataObject, DWORD keyState,
    POINTL point, DWORD* effect)
  {
    const DWORD allowedEffects = *effect;
    POINT webViewPoint;
    const auto webView = webViewAt(point, &webViewPoint);
    auto controller = webView
      ? webView->webViewCompositionController
        .try_query<ICoreWebView2CompositionController3>()
      : nullptr;
    if (controller) {
      *effect = allowedEffects;
      failedLog(controller->Drop(dataObject, keyState, webViewPoint, effect));
    } else {
      *effect = DROPEFFECT_NONE;
    }
    currentWebView_ = nullptr;
    if (currentDataObject_) {
      currentDataObject_->Release();
      currentDataObject_ = nullptr;
    }
    return S_OK;
  }
}
