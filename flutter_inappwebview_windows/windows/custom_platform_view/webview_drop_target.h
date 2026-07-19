#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_DROP_TARGET_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_DROP_TARGET_H_

#include <ole2.h>
#include <vector>

namespace flutter_inappwebview_plugin
{
  class InAppWebView;

  // In visual (composition) hosting WebView2 never receives OLE drag/drop by
  // itself, so HTML5 drag and drop is broken: dragstart fires but dragover
  // and drop never reach the page and the cursor shows no-drop
  // (MicrosoftEdge/WebView2Feedback#5237). The host must register an
  // IDropTarget on the window under the cursor (the Flutter view) and forward
  // the events to ICoreWebView2CompositionController3::DragEnter/DragOver/
  // DragLeave/Drop.
  //
  // One instance is registered per Flutter view window (keyed by HWND), so
  // multi-window / multi-engine apps each get their own drop target; drag
  // events are routed to the webview whose bounds contain the cursor within
  // that window.
  class WebViewDropTarget : public IDropTarget
  {
  public:
    // Registers [webView] for drag routing under [flutterViewHwnd], creating
    // and installing a drop target for that window on first use.
    static void RegisterWebView(HWND flutterViewHwnd, InAppWebView* webView);
    // Removes [webView] from whichever window owns it; revokes and destroys
    // that window's drop target once it has no webviews left.
    static void UnregisterWebView(InAppWebView* webView);

    // IUnknown
    HRESULT STDMETHODCALLTYPE QueryInterface(REFIID riid, void** ppv) override;
    ULONG STDMETHODCALLTYPE AddRef() override;
    ULONG STDMETHODCALLTYPE Release() override;

    // IDropTarget
    HRESULT STDMETHODCALLTYPE DragEnter(IDataObject* dataObject, DWORD keyState,
      POINTL point, DWORD* effect) override;
    HRESULT STDMETHODCALLTYPE DragOver(DWORD keyState, POINTL point,
      DWORD* effect) override;
    HRESULT STDMETHODCALLTYPE DragLeave() override;
    HRESULT STDMETHODCALLTYPE Drop(IDataObject* dataObject, DWORD keyState,
      POINTL point, DWORD* effect) override;

  private:
    explicit WebViewDropTarget(HWND flutterViewHwnd, bool oleInitialized);
    ~WebViewDropTarget() = default;

    InAppWebView* webViewAt(POINTL screenPoint, POINT* webViewPoint) const;
    void forwardLeave();

    HWND flutterViewHwnd_;
    // Whether this target's own OleInitialize succeeded and must be balanced
    // with OleUninitialize when the target is destroyed.
    bool oleInitialized_;
    volatile LONG refCount_ = 1;
    std::vector<InAppWebView*> webViews_;
    InAppWebView* currentWebView_ = nullptr;
    IDataObject* currentDataObject_ = nullptr;
  };
}

#endif // FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_DROP_TARGET_H_
