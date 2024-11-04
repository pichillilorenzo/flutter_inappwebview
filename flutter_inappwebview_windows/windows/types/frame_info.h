#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_FRAME_INFO_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_FRAME_INFO_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>
#include <WebView2.h>
#include <wil/com.h>

#include "security_origin.h"
#include "url_request.h"

namespace flutter_inappwebview_plugin
{

  class FrameInfo
  {
  public:
    const bool isMainFrame;
    const std::optional<std::shared_ptr<URLRequest>> request;
    const std::optional<std::shared_ptr<SecurityOrigin>> securityOrigin;
    const std::optional<std::string> name;
    const std::optional<int64_t> frameId;
    const std::optional<int64_t> kind;

    FrameInfo(const bool& isMainFrame,
      const std::optional<std::shared_ptr<URLRequest>> request,
      const std::optional<std::shared_ptr<SecurityOrigin>> securityOrigin,
      const std::optional<std::string>& name,
      const std::optional<int64_t>& frameId,
      const std::optional<int64_t>& kind);
    ~FrameInfo() = default;

    flutter::EncodableMap toEncodableMap() const;
    static std::unique_ptr<FrameInfo> fromICoreWebView2FrameInfo(const wil::com_ptr<ICoreWebView2FrameInfo> webViewFrameInfo);
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_FRAME_INFO_H_