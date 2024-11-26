#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/strconv.h"
#include "frame_info.h"

#include <winrt/Windows.Foundation.h>

namespace flutter_inappwebview_plugin
{
  FrameInfo::FrameInfo(const bool& isMainFrame,
    const std::optional<std::shared_ptr<URLRequest>> request,
    const std::optional<std::shared_ptr<SecurityOrigin>> securityOrigin,
    const std::optional<std::string>& name,
    const std::optional<int64_t>& frameId,
    const std::optional<int64_t>& kind)
    : isMainFrame(isMainFrame), request(request), securityOrigin(securityOrigin), name(name), frameId(frameId), kind(kind)
  {}

  flutter::EncodableMap FrameInfo::toEncodableMap() const
  {
    return flutter::EncodableMap{
    {"isMainFrame", make_fl_value(isMainFrame)},
    {"request", request.has_value() ? request.value()->toEncodableMap() : make_fl_value()},
    {"securityOrigin", securityOrigin.has_value() ? securityOrigin.value()->toEncodableMap() : make_fl_value()},
    {"name", make_fl_value(name)},
    {"frameId", make_fl_value(frameId)},
    {"kind", make_fl_value(kind)}
    };
  }

  std::unique_ptr<FrameInfo> FrameInfo::fromICoreWebView2FrameInfo(const wil::com_ptr<ICoreWebView2FrameInfo> webViewFrameInfo)
  {
    wil::unique_cotaskmem_string url;
    auto request = std::optional<std::shared_ptr<URLRequest>>{};
    auto securityOrigin = std::optional<std::shared_ptr<SecurityOrigin>>{};
    if (succeededOrLog(webViewFrameInfo->get_Source(&url))) {
      auto sourceUrl = wide_to_utf8(url.get());
      request = std::make_shared<URLRequest>(
        sourceUrl,
        std::optional<std::string>{},
        std::optional<std::map<std::string, std::string>>{},
        std::optional<std::vector<uint8_t>>{}
      );

      if (!sourceUrl.empty()) {
        try {
          winrt::Windows::Foundation::Uri const uri{ url.get() };

          securityOrigin = std::make_shared<SecurityOrigin>(
            wide_to_utf8(uri.Host().c_str()),
            uri.Port(),
            wide_to_utf8(uri.SchemeName().c_str())
          );
        }
        catch (winrt::hresult_error const& ex) {
          debugLog(wide_to_utf8(ex.message().c_str()));
        }
      }
    }

    auto webViewFrameInfo2 = webViewFrameInfo.try_query<ICoreWebView2FrameInfo2>();

    uint32_t frameId;
    wil::unique_cotaskmem_string name;
    COREWEBVIEW2_FRAME_KIND kind = COREWEBVIEW2_FRAME_KIND_UNKNOWN;
    if (webViewFrameInfo2) {
      failedLog(webViewFrameInfo2->get_FrameKind(&kind));
    }

    return std::make_unique<FrameInfo>(
      webViewFrameInfo2 ? kind == COREWEBVIEW2_FRAME_KIND_MAIN_FRAME : false,
      request,
      securityOrigin,
      succeededOrLog(webViewFrameInfo->get_Name(&name)) ? wide_to_utf8(name.get()) : std::optional<std::string>{},
      webViewFrameInfo2 && succeededOrLog(webViewFrameInfo2->get_FrameId(&frameId)) ? frameId : std::optional<int64_t>{},
      webViewFrameInfo2 ? (int64_t)kind : std::optional<int64_t>{}
    );
  }
}