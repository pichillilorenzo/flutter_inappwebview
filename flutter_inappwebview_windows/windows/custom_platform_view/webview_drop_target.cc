#include "webview_drop_target.h"

#include <algorithm>
#include <cstring>
#include <map>
#include <shellapi.h>

#include "../in_app_webview/in_app_webview.h"
#include "../utils/log.h"
#include "../utils/strconv.h"

namespace flutter_inappwebview_plugin
{
  // One drop target per Flutter view window; all access is on the UI thread.
  static std::map<HWND, WebViewDropTarget*> g_targets;

  // Drags carrying OS files are refused before reaching WebView2: a file
  // dropped on browser UI (e.g. print preview) bypasses every page-level and
  // navigation guard and opens the file in a new window.
  static bool dataObjectContainsFiles(IDataObject* dataObject)
  {
    if (!dataObject) {
      return false;
    }
    FORMATETC format = { CF_HDROP, nullptr, DVASPECT_CONTENT, -1, TYMED_HGLOBAL };
    if (dataObject->QueryGetData(&format) == S_OK) {
      return true;
    }
    // Virtual files (zip entries, Outlook attachments) arrive as file
    // descriptors instead of CF_HDROP.
    static const CLIPFORMAT descriptorW =
      static_cast<CLIPFORMAT>(RegisterClipboardFormatW(L"FileGroupDescriptorW"));
    static const CLIPFORMAT descriptorA =
      static_cast<CLIPFORMAT>(RegisterClipboardFormatW(L"FileGroupDescriptor"));
    format.cfFormat = descriptorW;
    if (dataObject->QueryGetData(&format) == S_OK) {
      return true;
    }
    format.cfFormat = descriptorA;
    return dataObject->QueryGetData(&format) == S_OK;
  }

  // Real paths of a dragged file set. Virtual files (zip entries, Outlook
  // attachments) carry no path and are reported as an empty list.
  static std::vector<std::string> dataObjectFilePaths(IDataObject* dataObject)
  {
    std::vector<std::string> paths;
    if (!dataObject) {
      return paths;
    }
    FORMATETC format = { CF_HDROP, nullptr, DVASPECT_CONTENT, -1, TYMED_HGLOBAL };
    STGMEDIUM medium = {};
    if (dataObject->GetData(&format, &medium) != S_OK) {
      return paths;
    }
    if (auto drop = static_cast<HDROP>(GlobalLock(medium.hGlobal))) {
      const auto count = DragQueryFileW(drop, 0xFFFFFFFF, nullptr, 0);
      for (UINT i = 0; i < count; i++) {
        const auto length = DragQueryFileW(drop, i, nullptr, 0);
        if (length == 0) {
          continue;
        }
        // DragQueryFileW writes a terminating NUL in addition to the path
        // characters returned by the length query.
        std::wstring path(length + 1, L'\0');
        const auto copied = DragQueryFileW(drop, i, path.data(),
          static_cast<UINT>(path.size()));
        if (copied > 0 && copied <= length) {
          path.resize(copied);
          paths.push_back(wide_to_utf8(path));
        }
      }
      GlobalUnlock(medium.hGlobal);
    }
    ReleaseStgMedium(&medium);
    return paths;
  }

  WebViewDropTarget::WebViewDropTarget(HWND flutterViewHwnd, bool oleInitialized)
    : flutterViewHwnd_(flutterViewHwnd), oleInitialized_(oleInitialized)
  {}

  WebViewDropTarget* WebViewDropTarget::acquire(HWND flutterViewHwnd)
  {
    auto it = g_targets.find(flutterViewHwnd);
    if (it != g_targets.end()) {
      return it->second;
    }
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
      return nullptr;
    }
    return g_targets.emplace(flutterViewHwnd, target).first->second;
  }

  void WebViewDropTarget::releaseIfUnused(HWND flutterViewHwnd)
  {
    const auto it = g_targets.find(flutterViewHwnd);
    if (it == g_targets.end()) {
      return;
    }
    auto target = it->second;
    if (!target->webViews_.empty() || target->fileDropSink_) {
      return;
    }
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

  void WebViewDropTarget::RegisterWebView(HWND flutterViewHwnd, InAppWebView* webView)
  {
    if (!flutterViewHwnd || !webView) {
      return;
    }
    if (auto target = acquire(flutterViewHwnd)) {
      target->webViews_.push_back(webView);
    }
  }

  void WebViewDropTarget::SetFileDropSink(HWND flutterViewHwnd, FileDropSink sink)
  {
    if (!flutterViewHwnd || !sink) {
      return;
    }
    if (auto target = acquire(flutterViewHwnd)) {
      target->fileDropSink_ = std::move(sink);
    }
  }

  void WebViewDropTarget::ClearFileDropSink(HWND flutterViewHwnd)
  {
    const auto it = g_targets.find(flutterViewHwnd);
    if (it == g_targets.end()) {
      return;
    }
    it->second->fileDropSink_ = nullptr;
    it->second->fileDropAccepted_ = false;
    releaseIfUnused(flutterViewHwnd);
  }

  void WebViewDropTarget::SetFileDropAccepted(HWND flutterViewHwnd, bool accepted)
  {
    const auto it = g_targets.find(flutterViewHwnd);
    if (it != g_targets.end()) {
      it->second->fileDropAccepted_ = accepted;
    }
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
      releaseIfUnused(target->flutterViewHwnd_);
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

  bool WebViewDropTarget::toClient(POINTL screenPoint, double* x, double* y) const
  {
    RECT client;
    if (!GetClientRect(flutterViewHwnd_, &client) || client.right == 0) {
      return false;
    }
    // Mapping through both client corners stays correct on RTL-mirrored
    // windows (WS_EX_LAYOUTRTL), where ClientToScreen(0,0) is the top-RIGHT.
    POINT p0 = { 0, 0 };
    POINT p1 = { client.right, client.bottom };
    ClientToScreen(flutterViewHwnd_, &p0);
    ClientToScreen(flutterViewHwnd_, &p1);
    if (p1.x == p0.x || p1.y == p0.y) {
      return false;
    }
    *x = static_cast<double>(screenPoint.x - p0.x) * client.right / (p1.x - p0.x);
    *y = static_cast<double>(screenPoint.y - p0.y) * client.bottom / (p1.y - p0.y);
    return true;
  }

  InAppWebView* WebViewDropTarget::webViewAt(POINTL screenPoint,
    POINT* webViewPoint) const
  {
    double localX = 0;
    double localY = 0;
    if (!toClient(screenPoint, &localX, &localY)) {
      return nullptr;
    }

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

  HRESULT WebViewDropTarget::reportFileDrag(const char* event,
    IDataObject* dataObject, POINTL point, DWORD* effect)
  {
    // Files never reach WebView2: a file dropped on browser UI (e.g. print
    // preview) bypasses every page-level and navigation guard.
    forwardLeave();
    if (!fileDropSink_) {
      *effect = DROPEFFECT_NONE;
      return S_OK;
    }
    double x = 0;
    double y = 0;
    toClient(point, &x, &y);
    const bool needsPaths = strcmp(event, "over") != 0;
    fileDropSink_(event, needsPaths ? dataObjectFilePaths(dataObject)
      : std::vector<std::string>(), x, y);
    // The host answers asynchronously, so this reflects the previous report -
    // one drag event of lag, which the continuous DragOver stream absorbs.
    // A target may only select an effect offered by the drag source. The host
    // consumes a file as a copy, so reject sources that do not permit COPY.
    *effect = fileDropAccepted_ && (*effect & DROPEFFECT_COPY)
      ? DROPEFFECT_COPY : DROPEFFECT_NONE;
    return S_OK;
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
    currentDragHasFiles_ = dataObjectContainsFiles(dataObject);
    currentWebView_ = nullptr;
    if (currentDragHasFiles_) {
      fileDropAccepted_ = false;
      return reportFileDrag("enter", dataObject, point, effect);
    }
    return DragOver(keyState, point, effect);
  }

  HRESULT WebViewDropTarget::DragOver(DWORD keyState, POINTL point,
    DWORD* effect)
  {
    // On entry *effect holds the effects the drop source allows; forward it so
    // WebView2 can pick one. Zeroing it here would make WebView2 return NONE
    // and OLE would never call Drop.
    const DWORD allowedEffects = *effect;
    if (currentDragHasFiles_) {
      return reportFileDrag("over", currentDataObject_, point, effect);
    }
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
    if (currentDragHasFiles_ && fileDropSink_) {
      fileDropSink_("leave", {}, 0, 0);
    }
    currentDragHasFiles_ = false;
    fileDropAccepted_ = false;
    if (currentDataObject_) {
      currentDataObject_->Release();
      currentDataObject_ = nullptr;
    }
    return S_OK;
  }

  HRESULT WebViewDropTarget::Drop(IDataObject* dataObject, DWORD keyState,
    POINTL point, DWORD* effect)
  {
    if (currentDragHasFiles_ || dataObjectContainsFiles(dataObject)) {
      const auto hr = reportFileDrag("drop", dataObject, point, effect);
      currentDragHasFiles_ = false;
      if (currentDataObject_) {
        currentDataObject_->Release();
        currentDataObject_ = nullptr;
      }
      return hr;
    }
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
