#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_START_REQUEST_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_START_REQUEST_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>

// Use the appropriate WebKit header based on backend
#ifdef USE_WPE_WEBKIT
#include <wpe/webkit.h>
#else
#include <webkit2/webkit2.h>
#endif

namespace flutter_inappwebview_plugin {

class DownloadStartRequest {
 public:
  std::optional<std::string> url;
  std::optional<std::string> suggestedFilename;
  std::optional<std::string> mimeType;
  int64_t contentLength;
  std::optional<std::string> contentDisposition;
  std::optional<std::string> userAgent;

  DownloadStartRequest();
  DownloadStartRequest(WebKitDownload* download);
  ~DownloadStartRequest() = default;

  FlValue* toFlValue() const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_START_REQUEST_H_
