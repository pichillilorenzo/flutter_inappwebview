#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_HEADLESS_IN_APP_WEBVIEW_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_HEADLESS_IN_APP_WEBVIEW_H_

#include "../drago_inappwebview_plugin.h"
#include "../in_app_webview/in_app_webview.h"
#include "../types/size_2d.h"
#include "headless_webview_channel_delegate.h"

namespace drago_inappwebview_plugin
{
  struct HeadlessInAppWebViewCreationParams {
    const std::string id;
    const std::shared_ptr<Size2D> initialSize;
  };

  class HeadlessInAppWebView
  {
  public:
    static inline const wchar_t* CLASS_NAME = L"HeadlessInAppWebView";
    static inline const std::string METHOD_CHANNEL_NAME_PREFIX = "com.pichillilorenzo/flutter_headless_inappwebview_";

    const DragoInappwebviewPlugin* plugin;
    std::string id;
    std::unique_ptr<InAppWebView> webView;
    std::unique_ptr<HeadlessWebViewChannelDelegate> channelDelegate;

    HeadlessInAppWebView(const DragoInappwebviewPlugin* plugin, const HeadlessInAppWebViewCreationParams& params, const HWND parentWindow, std::unique_ptr<InAppWebView> webView);
    ~HeadlessInAppWebView();

    void prepare(const HeadlessInAppWebViewCreationParams& params);
    void setSize(const std::shared_ptr<Size2D> size) const;
    std::shared_ptr<Size2D> getSize() const;
  };
}
#endif //DRAGO_INAPPWEBVIEW_PLUGIN_HEADLESS_IN_APP_WEBVIEW_H_