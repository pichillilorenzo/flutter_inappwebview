#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_TYPES_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_TYPES_H_

#include <flutter_linux/flutter_linux.h>

// Use the appropriate WebKit header based on backend
#ifdef USE_WPE_WEBKIT
#include <wpe/webkit.h>
#else
#include <webkit2/webkit2.h>
#endif

#include <cstdint>
#include <optional>
#include <string>

namespace flutter_inappwebview_plugin {

/**
 * Download start response action.
 */
enum class DownloadStartResponseAction {
  CANCEL = 0,
  ALLOW = 1
};

/**
 * Represents a download start request.
 */
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

/**
 * Response to a download start request.
 */
class DownloadStartResponse {
 public:
  DownloadStartResponseAction action;
  std::optional<std::string> destinationPath;

  DownloadStartResponse();
  DownloadStartResponse(FlValue* map);
  ~DownloadStartResponse() = default;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_TYPES_H_
