#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_NATIVE_FOCUS_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_NATIVE_FOCUS_H_

#include <windows.h>

namespace flutter_inappwebview_plugin
{
  // Whether |focused| is a strict descendant of |host|, the WS_CHILD window a
  // WebView2 controller uses as ParentWindow. Keys reach the page only through
  // the input window WebView2 creates under it: in visual hosting a
  // Chrome_WidgetWin_0 of this process, in HWND mode a window of the browser
  // process (the system attaches their input queues, so GetFocus sees it).
  //
  // The host itself does not count. put_IsVisible(FALSE) moves the focus from
  // the input window onto the host; put_IsVisible(TRUE) then raises GotFocus
  // and the page reports document.hasFocus() == true, yet the focus stays on
  // the host and every keystroke is lost until MoveFocus or a click.
  inline bool focusIsInsideHost(const HWND host, const HWND focused)
  {
    return host && focused && ::IsChild(host, focused);
  }
}

#endif // FLUTTER_INAPPWEBVIEW_PLUGIN_NATIVE_FOCUS_H_
