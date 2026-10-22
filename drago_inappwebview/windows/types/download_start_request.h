#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_DOWNLOAD_START_REQUEST_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_DOWNLOAD_START_REQUEST_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>

namespace drago_inappwebview_plugin
{
  class DownloadStartRequest
  {
  public:
    const std::optional<std::string> contentDisposition;
    const int64_t contentLength;
    const std::optional<std::string> mimeType;
    const std::optional<std::string> suggestedFilename;
    const std::string url;

    DownloadStartRequest(const std::optional<std::string>& contentDisposition,
      const int64_t& contentLength,
      const std::optional<std::string>& mimeType,
      const std::optional<std::string>& suggestedFilename,
      const std::string& url);
    ~DownloadStartRequest() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //DRAGO_INAPPWEBVIEW_PLUGIN_DOWNLOAD_START_REQUEST_H_