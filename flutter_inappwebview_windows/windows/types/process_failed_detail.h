#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PROCESS_FAILED_DETAIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PROCESS_FAILED_DETAIL_H_

#include <flutter/standard_method_codec.h>
#include <optional>
#include <string>
#include <vector>

#include "frame_info.h"

namespace flutter_inappwebview_plugin
{

  class ProcessFailedDetail
  {
  public:
    const int64_t kind;
    const std::optional<int64_t> exitCode;
    const std::optional<std::string> processDescription;
    const std::optional<int64_t> reason;
    const std::optional<std::string> failureSourceModulePath;
    const std::optional<std::vector<std::shared_ptr<FrameInfo>>> frameInfos;

    ProcessFailedDetail(const int64_t& kind,
      const std::optional<int64_t>& exitCode,
      const std::optional<std::string>& processDescription,
      const std::optional<int64_t>& reason,
      const std::optional<std::string>& failureSourceModulePath,
      const std::optional<std::vector<std::shared_ptr<FrameInfo>>>& frameInfos);
    ~ProcessFailedDetail() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_PROCESS_FAILED_DETAIL_H_