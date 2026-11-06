#include <cassert>
#include <cstdint>
#include <iostream>

namespace flutter_inappwebview_plugin {

#ifdef HAVE_WPE_BACKEND_LEGACY
constexpr uint32_t wpe_view_activity_state_visible = 1 << 0;
constexpr uint32_t wpe_view_activity_state_focused = 1 << 1;
constexpr uint32_t wpe_view_activity_state_in_window = 1 << 2;
constexpr uint32_t visibility_mask =
    wpe_view_activity_state_visible | wpe_view_activity_state_in_window;

struct NativeView {
  uint32_t activity = visibility_mask | wpe_view_activity_state_focused;
  unsigned calls = 0;
};
void wpe_view_backend_add_activity_state(NativeView* view, uint32_t state) {
  view->activity |= state;
  ++view->calls;
}
void wpe_view_backend_remove_activity_state(NativeView* view, uint32_t state) {
  view->activity &= ~state;
  ++view->calls;
}
uint32_t wpe_view_backend_get_activity_state(NativeView* view) {
  return view->activity;
}
#else
struct NativeView {
  bool visible = true;
  bool mapped = true;
  bool focused = true;
  unsigned calls = 0;
};
void wpe_view_focus_in(NativeView* view) {
  view->focused = true;
  ++view->calls;
}
void wpe_view_focus_out(NativeView* view) {
  view->focused = false;
  ++view->calls;
}
void wpe_view_set_visible(NativeView* view, bool visible) {
  view->visible = visible;
  ++view->calls;
}
void wpe_view_map(NativeView* view) {
  view->mapped = true;
  ++view->calls;
}
void wpe_view_unmap(NativeView* view) {
  view->mapped = false;
  ++view->calls;
}
bool wpe_view_get_visible(NativeView* view) { return view->visible; }
#endif

class InAppWebView {
 public:
  NativeView native;
#ifdef HAVE_WPE_BACKEND_LEGACY
  NativeView* wpe_backend_ = &native;
#else
  NativeView* wpe_view_ = &native;
#endif
  void* webview_ = this;
  bool is_focused_ = true;
  bool is_visible_ = true;
  unsigned popup_hides = 0;

  void setFocused(bool focused);
  void setVisible(bool visible);
  uint32_t getActivityState() const;
  bool isVisible() const;
  bool clearFocus();
  bool requestFocus();
  void HideAllPopups() { ++popup_hides; }
};

#include "activity_state_under_test.inc"

void expectState(const InAppWebView& view, bool visible, bool focused) {
  assert(view.isVisible() == visible);
  assert(view.is_visible_ == visible);
  assert(view.is_focused_ == focused);
#ifdef HAVE_WPE_BACKEND_LEGACY
  assert((view.getActivityState() & visibility_mask) ==
         (visible ? visibility_mask : 0));
  assert((view.getActivityState() & wpe_view_activity_state_focused) ==
         (focused ? wpe_view_activity_state_focused : 0));
#else
  assert(view.native.visible == visible);
  assert(view.native.mapped == visible);
  assert(view.native.focused == focused);
#endif
}

void testHiddenFocusRequest() {
  InAppWebView view;
  assert(view.clearFocus());
  view.setVisible(false);
  expectState(view, false, false);
  assert(view.requestFocus());
  expectState(view, false, true);
  view.setVisible(false);
  expectState(view, false, true);
  view.setVisible(true);
  expectState(view, true, true);
  assert(view.popup_hides == 1);
}

void testWindowHideAndRestore() {
  InAppWebView view;
  view.setVisible(false);
  expectState(view, false, true);
  assert(view.clearFocus());
  assert(view.requestFocus());
  expectState(view, false, true);
  assert(view.clearFocus());
  view.setVisible(true);
  expectState(view, true, false);
  assert(view.requestFocus());
  expectState(view, true, true);
  assert(view.popup_hides == 2);
}

void testIdempotentCalls() {
  InAppWebView view;
  view.clearFocus();
  view.setVisible(false);
  const unsigned calls = view.native.calls;
  view.clearFocus();
  view.setVisible(false);
  expectState(view, false, false);
  assert(view.native.calls == calls);
  assert(view.popup_hides == 1);
  view.requestFocus();
  const unsigned focused_calls = view.native.calls;
  view.requestFocus();
  view.setVisible(false);
  expectState(view, false, true);
  assert(view.native.calls == focused_calls);
}

void testRapidTabSwitches() {
  InAppWebView first;
  InAppWebView second;
  second.clearFocus();
  second.setVisible(false);
  for (unsigned i = 0; i < 1000; ++i) {
    first.clearFocus();
    first.setVisible(false);
    second.requestFocus();
    expectState(first, false, false);
    expectState(second, false, true);
    second.setVisible(true);
    expectState(second, true, true);
    second.setVisible(false);
    second.clearFocus();
    first.requestFocus();
    expectState(second, false, false);
    expectState(first, false, true);
    first.setVisible(true);
    expectState(first, true, true);
  }
}

void testMissingNativeView() {
  InAppWebView view;
#ifdef HAVE_WPE_BACKEND_LEGACY
  view.wpe_backend_ = nullptr;
#else
  view.wpe_view_ = nullptr;
#endif
  view.setVisible(false);
  assert(view.clearFocus());
  assert(view.requestFocus());
  assert(!view.isVisible());
  assert(view.native.calls == 0);
  view.webview_ = nullptr;
  assert(!view.clearFocus());
  assert(!view.requestFocus());
  assert(view.popup_hides == 1);
}

}  // namespace flutter_inappwebview_plugin

int main() {
  using namespace flutter_inappwebview_plugin;
  testHiddenFocusRequest();
  testWindowHideAndRestore();
  testIdempotentCalls();
  testRapidTabSwitches();
  testMissingNativeView();
#ifdef HAVE_WPE_BACKEND_LEGACY
  std::cout << "FDO: 5 focus/visibility tests passed\n";
#else
  std::cout << "WPEPlatform: 5 focus/visibility tests passed\n";
#endif
}
