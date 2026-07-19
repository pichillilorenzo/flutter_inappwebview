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
  // A single instance is registered per Flutter view window; the composition
  // webviews register themselves and drag events are routed to the webview
  // whose bounds contain the cursor.
  class WebViewDropTarget : public IDropTarget
  {
  public:
    // Registers [webView] for drag routing, installing the drop target on
    // [flutterViewHwnd] on first use.
    static void RegisterWebView(HWND flutterViewHwnd, InAppWebView* webView);
    // Removes [webView]; revokes the drop target when none remain.
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
    explicit WebViewDropTarget(HWND flutterViewHwnd);
    ~WebViewDropTarget() = default;

    InAppWebView* webViewAt(POINTL screenPoint, POINT* webViewPoint) const;
    void forwardLeave();

    HWND flutterViewHwnd_;
    volatile LONG refCount_ = 1;
    std::vector<InAppWebView*> webViews_;
    InAppWebView* currentWebView_ = nullptr;
    IDataObject* currentDataObject_ = nullptr;
  };
}

#endif // FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_DROP_TARGET_H_
