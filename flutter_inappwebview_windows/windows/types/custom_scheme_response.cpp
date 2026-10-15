#include "../utils/flutter.h"
#include "../utils/string.h"
#include "custom_scheme_response.h"

#include <Shlwapi.h>

namespace flutter_inappwebview_plugin
{
  CustomSchemeResponse::CustomSchemeResponse(const std::vector<uint8_t>& data, const std::string& contentType, const std::string& contentEncoding,
    const std::optional<std::map<std::string, std::string>>& headers)
    : data(data), contentType(contentType), contentEncoding(contentEncoding), headers(headers)
  {}

  CustomSchemeResponse::CustomSchemeResponse(const flutter::EncodableMap& map)
    : CustomSchemeResponse(get_fl_map_value<std::vector<uint8_t>>(map, "data"),
      get_fl_map_value<std::string>(map, "contentType"),
      get_fl_map_value<std::string>(map, "contentEncoding"),
      fl_map_contains_not_null(map, "headers") ? get_optional_fl_map_value<std::map<std::string, std::string>>(map, "headers") : std::nullopt)
  {}

  flutter::EncodableMap CustomSchemeResponse::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"data", make_fl_value(data)},
      {"contentType", make_fl_value(contentType)},
      {"contentEncoding", make_fl_value(contentEncoding)},
      {"headers", make_fl_value(headers)}
    };
  }

  ICoreWebView2WebResourceResponse* CustomSchemeResponse::toWebView2Response(const wil::com_ptr<ICoreWebView2Environment> webViewEnvironment) const
  {
    wil::com_ptr<ICoreWebView2WebResourceResponse> webResourceResponse;

    if (webViewEnvironment) {
      wil::com_ptr<IStream> postDataStream = nullptr;
      if (!data.empty()) {
        auto postData = std::string(data.begin(), data.end());
        postDataStream.attach(SHCreateMemStream(
          reinterpret_cast<const BYTE*>(postData.data()), static_cast<UINT>(postData.length())));
      }

      webViewEnvironment->CreateWebResourceResponse(
        postDataStream.get(),
        200, // Default to 200
        L"OK", // Default to "OK"
        nullptr,
        &webResourceResponse);

      // A Content-Type listed in headers replaces the one derived from contentType.
      auto hasContentTypeHeader = headers.has_value() &&
        std::any_of(headers.value().begin(), headers.value().end(),
          [](auto const& header) { return to_lowercase_copy(header.first) == "content-type"; });

      wil::com_ptr<ICoreWebView2HttpResponseHeaders> responseHeaders;
      if (SUCCEEDED(webResourceResponse->get_Headers(&responseHeaders))) {
        if (!contentType.empty() && !hasContentTypeHeader) {
          responseHeaders->AppendHeader(L"Content-Type", utf8_to_wide(contentType).c_str());
        }
        if (!contentEncoding.empty()) {
          responseHeaders->AppendHeader(L"Content-Encoding", utf8_to_wide(contentEncoding).c_str());
        }
        if (headers.has_value()) {
          for (auto const& [key, value] : headers.value()) {
            responseHeaders->AppendHeader(utf8_to_wide(key).c_str(), utf8_to_wide(value).c_str());
          }
        }
      }

      webResourceResponse->AddRef();
    }

    return webResourceResponse.get();
  }
}
