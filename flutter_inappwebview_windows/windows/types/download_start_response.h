#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_START_RESPONSE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_START_RESPONSE_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>

namespace flutter_inappwebview_plugin
{
  enum class DownloadStartResponseAction {
    cancel = 0
  };

  inline std::optional<DownloadStartResponseAction> DownloadStartResponseActionFromInteger(const std::optional<int64_t>& action)
  {
    if (action.has_value()) {
      switch (action.value()) {
      case 0:
        return DownloadStartResponseAction::cancel;
      default:
        return DownloadStartResponseAction::cancel;
      }
    }
    return std::optional<DownloadStartResponseAction>{};
  }

  inline std::optional<int64_t> DownloadStartResponseActionToInteger(const std::optional<DownloadStartResponseAction>& action)
  {
    return action.has_value() ? static_cast<int64_t>(action.value()) : std::optional<int64_t>{};
  }

  class DownloadStartResponse
  {
  public:
    const bool handled;
    const std::optional<DownloadStartResponseAction> action;
    const std::optional<std::string> resultFilePath;

    DownloadStartResponse(const bool& handled,
      const std::optional<DownloadStartResponseAction>& action,
      const std::optional<std::string>& resultFilePath);
    DownloadStartResponse(const flutter::EncodableMap& map);
    ~DownloadStartResponse() = default;

    bool DownloadStartResponse::operator==(const DownloadStartResponse& other)
    {
      return handled == other.handled &&
        action == other.action &&
        resultFilePath == other.resultFilePath;
    }
    bool DownloadStartResponse::operator!=(const DownloadStartResponse& other)
    {
      return !(*this == other);
    }

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_DOWNLOAD_START_RESPONSE_H_