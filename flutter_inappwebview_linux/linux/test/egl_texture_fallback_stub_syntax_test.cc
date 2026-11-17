#include <type_traits>

#include "egl_texture_fallback_webview_stub.h"

using flutter_inappwebview_plugin::InAppWebView;
using flutter_inappwebview_plugin::TextureWebViewApi;

static_assert(std::is_base_of_v<TextureWebViewApi, InAppWebView>);
static_assert(std::is_same_v<
              decltype(&InAppWebView::ReportFlutterEglImageImportFailure),
              void (InAppWebView::*)(bool)>);
static_assert(std::is_same_v<
              decltype(&InAppWebView::ImportCurrentBufferToEglImage),
              void* (InAppWebView::*)(void*, uint32_t*, uint32_t*, bool*) const>);

int main() {}
