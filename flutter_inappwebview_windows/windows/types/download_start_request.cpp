#include "../utils/flutter.h"
#include "download_start_request.h"

namespace flutter_inappwebview_plugin
{
  DownloadStartRequest::DownloadStartRequest(const std::optional<std::string>& contentDisposition,
    const int64_t& contentLength,
    const std::optional<std::string>& mimeType,
    const std::optional<std::string>& suggestedFilename,
    const std::string& url)
    : contentDisposition(contentDisposition), contentLength(contentLength), mimeType(mimeType), suggestedFilename(suggestedFilename), url(url)
  {}

  flutter::EncodableMap DownloadStartRequest::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"contentDisposition", make_fl_value(contentDisposition)},
      {"contentLength", make_fl_value(contentLength)},
      {"mimeType", make_fl_value(mimeType)},
      {"suggestedFilename", make_fl_value(suggestedFilename)},
      {"url", make_fl_value(url)}
    };
  }
}