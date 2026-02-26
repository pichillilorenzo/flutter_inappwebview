#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_BROWSER_PROCESS_INFO_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_BROWSER_PROCESS_INFO_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <WebView2.h>
#include <wil/com.h>

#include "../types/frame_info.h"

namespace flutter_inappwebview_plugin
{
  class BrowserProcessInfo
  {
  public:
    const std::optional<int64_t> kind;
    const std::optional<int64_t> processId;
    const std::optional<std::vector<std::shared_ptr<FrameInfo>>> frameInfos;

    BrowserProcessInfo(const std::optional<int64_t>& kind,
      const std::optional<int64_t>& processId,
      const std::optional<std::vector<std::shared_ptr<FrameInfo>>>& frameInfos);
    ~BrowserProcessInfo() = default;

    static std::unique_ptr<BrowserProcessInfo> fromICoreWebView2ProcessInfo(const wil::com_ptr<ICoreWebView2ProcessInfo> processInfo);
    static std::unique_ptr<BrowserProcessInfo> fromICoreWebView2ProcessExtendedInfo(const wil::com_ptr<ICoreWebView2ProcessExtendedInfo> processExtendedInfo);

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_BROWSER_PROCESS_INFO_H_