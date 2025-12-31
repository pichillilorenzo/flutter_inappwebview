#include "download_start_request.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin {

// === DownloadStartRequest ===

DownloadStartRequest::DownloadStartRequest() : contentLength(-1) {}

DownloadStartRequest::DownloadStartRequest(WebKitDownload* download) : contentLength(-1) {
  if (download == nullptr) {
    return;
  }

  WebKitURIRequest* request = webkit_download_get_request(download);
  if (request != nullptr) {
    const gchar* uri = webkit_uri_request_get_uri(request);
    if (uri != nullptr) {
      url = std::string(uri);
    }
  }

  WebKitURIResponse* response = webkit_download_get_response(download);
  if (response != nullptr) {
    const gchar* mimeTypeStr = webkit_uri_response_get_mime_type(response);
    if (mimeTypeStr != nullptr) {
      mimeType = std::string(mimeTypeStr);
    }

    contentLength = webkit_uri_response_get_content_length(response);

    // Try to get suggested filename from response headers
    const gchar* suggestedName = webkit_uri_response_get_suggested_filename(response);
    if (suggestedName != nullptr) {
      suggestedFilename = std::string(suggestedName);
    }
  }

  // If no suggested filename from response, get it from download
  if (!suggestedFilename.has_value()) {
    // WebKitGTK automatically determines a filename
    const gchar* dest = webkit_download_get_destination(download);
    if (dest != nullptr) {
      // Extract filename from path
      std::string destStr(dest);
      size_t lastSlash = destStr.rfind('/');
      if (lastSlash != std::string::npos) {
        suggestedFilename = destStr.substr(lastSlash + 1);
      } else {
        suggestedFilename = destStr;
      }
    }
  }
}

FlValue* DownloadStartRequest::toFlValue() const {
  FlValue* map = fl_value_new_map();

  if (url.has_value()) {
    fl_value_set_string_take(map, "url", fl_value_new_string(url.value().c_str()));
  } else {
    fl_value_set_string_take(map, "url", fl_value_new_null());
  }

  if (suggestedFilename.has_value()) {
    fl_value_set_string_take(map, "suggestedFilename",
                             fl_value_new_string(suggestedFilename.value().c_str()));
  } else {
    fl_value_set_string_take(map, "suggestedFilename", fl_value_new_null());
  }

  if (mimeType.has_value()) {
    fl_value_set_string_take(map, "mimeType", fl_value_new_string(mimeType.value().c_str()));
  } else {
    fl_value_set_string_take(map, "mimeType", fl_value_new_null());
  }

  fl_value_set_string_take(map, "contentLength", fl_value_new_int(contentLength));

  if (contentDisposition.has_value()) {
    fl_value_set_string_take(map, "contentDisposition",
                             fl_value_new_string(contentDisposition.value().c_str()));
  } else {
    fl_value_set_string_take(map, "contentDisposition", fl_value_new_null());
  }

  if (userAgent.has_value()) {
    fl_value_set_string_take(map, "userAgent", fl_value_new_string(userAgent.value().c_str()));
  } else {
    fl_value_set_string_take(map, "userAgent", fl_value_new_null());
  }

  return map;
}

}  // namespace flutter_inappwebview_plugin
