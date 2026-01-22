#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_

#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>

#include <limits>
#include <objidl.h>
#include <optional>
#include <rpc.h>
#include <string>
#include <variant>
#include <vector>

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

  static inline std::optional<std::vector<uint8_t>> readStreamBytes(IStream* stream)
  {
    if (!stream) {
      return std::nullopt;
    }

    STATSTG stat = {};
    if (FAILED(stream->Stat(&stat, STATFLAG_NONAME))) {
      return std::nullopt;
    }

    auto size64 = stat.cbSize.QuadPart;
    if (size64 <= 0) {
      return std::nullopt;
    }

    // Use parentheses around max() to prevent Windows macro expansion
    if (size64 > static_cast<ULONGLONG>((std::numeric_limits<ULONG>::max)())) {
      return std::nullopt;
    }

    LARGE_INTEGER pos = {};
    stream->Seek(pos, STREAM_SEEK_SET, nullptr);

    auto size = static_cast<ULONG>(size64);
    std::vector<uint8_t> data(size);
    ULONG bytesRead = 0;
    if (FAILED(stream->Read(data.data(), size, &bytesRead))) {
      return std::nullopt;
    }

    data.resize(bytesRead);
    return data;
  }
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_UTIL_H_