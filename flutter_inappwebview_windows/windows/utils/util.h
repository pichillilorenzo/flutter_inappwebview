#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_

#include <optional>
#include <rpc.h>
#include <string>
#include <variant>
#include <Windows.h>
#include <winrt/Windows.Foundation.h>

#include "string.h"

namespace flutter_inappwebview_plugin
{
  template<typename T>
  static inline std::optional<T> make_pointer_optional(const T* value)
  {
    return value == nullptr ? std::nullopt : std::make_optional<T>(*value);
  }

  static inline std::string variant_to_string(const std::variant<std::string, int64_t>& var)
  {
    return std::visit([](auto&& arg)
      {
        using T = std::decay_t<decltype(arg)>;
        if constexpr (std::is_same_v<T, std::string>)
          return arg;
        else if constexpr (std::is_arithmetic_v<T>)
          return std::to_string(arg);
        else
          static_assert(always_false_v<T>, "non-exhaustive visitor!");
      }, var);
  }

  static inline float get_current_scale_factor(HWND hwnd)
  {
    auto dpi = GetDpiForWindow(hwnd);
    return dpi > 0 ? dpi / 96.0f : 1.0f;
  }

  static inline std::string get_uuid()
  {
    UUID uuid = { 0 };
    std::string guid;

    ::UuidCreate(&uuid);

    RPC_CSTR szUuid = NULL;
    if (::UuidToStringA(&uuid, &szUuid) == RPC_S_OK) {
      guid = (char*)szUuid;
      ::RpcStringFreeA(&szUuid);
    }

    return guid;
  }

  static inline std::string get_origin_from_url(const std::string& url)
  {
    try {
      winrt::Windows::Foundation::Uri const uri{ utf8_to_wide(url) };
      auto scheme = winrt::to_string(uri.SchemeName());
      auto host = winrt::to_string(uri.Host());
      auto uriPort = uri.Port();
      std::string port = "";
      if (uriPort > 0 && ((string_equals(scheme, "http") && uriPort != 80) || (string_equals(scheme, "https") && uriPort != 443))) {
        port = ":" + std::to_string(uriPort);
      }
      return scheme + "://" + host + port;
    }
    catch (...) {
      auto urlSplit = split(url, std::string{ "://" });
      if (urlSplit.size() > 1) {
        auto scheme = urlSplit[0];
        auto afterScheme = urlSplit[1];
        auto afterSchemeSplit = split(afterScheme, std::string{ "/" });
        auto host = afterSchemeSplit[0];
        return scheme + "://" + host;
      }
    }
    return url;
  }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_