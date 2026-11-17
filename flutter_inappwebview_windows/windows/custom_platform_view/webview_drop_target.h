#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_DROP_TARGET_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_DROP_TARGET_H_

#include <ole2.h>
#include <functional>
#include <string>
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
    // Reported to the host for a drag carrying OS files. [event] is one of
    // "enter" / "over" / "leave" / "drop"; [x],[y] are client coordinates.
    using FileDropSink = std::function<void(const std::string& event,
      const std::vector<std::string>& paths, double x, double y)>;

    // Registers [webView] for drag routing under [flutterViewHwnd], creating
    // and installing a drop target for that window on first use.
    static void RegisterWebView(HWND flutterViewHwnd, InAppWebView* webView);
    // Removes [webView] from whichever window owns it; revokes and destroys
    // that window's drop target once it has no webviews left.
    static void UnregisterWebView(InAppWebView* webView);

    // Claims OS file drags on [flutterViewHwnd] for the host. Only one IDropTarget
    // may exist per window, so the host cannot register its own alongside this
    // one - it routes them through here instead. Keeps the target alive even
    // while no webview exists.
    static void SetFileDropSink(HWND flutterViewHwnd, FileDropSink sink);
    // Stops reporting file drags, restoring the plain-refusal behaviour.
    static void ClearFileDropSink(HWND flutterViewHwnd);

    // The host's answer to the last reported drag: whether it would accept a
    // drop here. Drives the drag cursor, so the host must answer while the
    // drag is still moving. Resets to refused on every new drag.
    static void SetFileDropAccepted(HWND flutterViewHwnd, bool accepted);

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

    // Creates and registers the window's target on first use, or returns the
    // existing one. Null when RegisterDragDrop failed.
    static WebViewDropTarget* acquire(HWND flutterViewHwnd);
    // Revokes and destroys the window's target once nothing needs it.
    static void releaseIfUnused(HWND flutterViewHwnd);

    bool toClient(POINTL screenPoint, double* x, double* y) const;
    InAppWebView* webViewAt(POINTL screenPoint, POINT* webViewPoint) const;
    void forwardLeave();
    // Emits [event] to the file drop sink; paths are read for "enter"/"drop" only.
    HRESULT reportFileDrag(const char* event, IDataObject* dataObject,
      POINTL point, DWORD* effect);

    HWND flutterViewHwnd_;
    // Whether this target's own OleInitialize succeeded and must be balanced
    // with OleUninitialize when the target is destroyed.
    bool oleInitialized_;
    volatile LONG refCount_ = 1;
    std::vector<InAppWebView*> webViews_;
    InAppWebView* currentWebView_ = nullptr;
    IDataObject* currentDataObject_ = nullptr;
    bool currentDragHasFiles_ = false;
    FileDropSink fileDropSink_;
    bool fileDropAccepted_ = false;
  };
}

#endif // FLUTTER_INAPPWEBVIEW_PLUGIN_WEBVIEW_DROP_TARGET_H_
