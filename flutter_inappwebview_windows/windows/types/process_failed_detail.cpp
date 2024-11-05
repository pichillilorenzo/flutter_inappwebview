#include "../utils/flutter.h"
#include "process_failed_detail.h"

namespace flutter_inappwebview_plugin
{
  ProcessFailedDetail::ProcessFailedDetail(const int64_t& kind,
    const std::optional<int64_t>& exitCode,
    const std::optional<std::string>& processDescription,
    const std::optional<int64_t>& reason,
    const std::optional<std::string>& failureSourceModulePath,
    const std::optional<std::vector<std::shared_ptr<FrameInfo>>>& frameInfos)
    : kind(kind), exitCode(exitCode), processDescription(processDescription), reason(reason), failureSourceModulePath(failureSourceModulePath), frameInfos(frameInfos)
  {}

  flutter::EncodableMap ProcessFailedDetail::toEncodableMap() const
  {
    return flutter::EncodableMap{
    {"kind", make_fl_value(kind)},
    {"exitCode", make_fl_value(exitCode)},
    {"processDescription", make_fl_value(processDescription)},
    {"reason", make_fl_value(reason)},
    {"failureSourceModulePath", make_fl_value(failureSourceModulePath)},
    {"frameInfos", frameInfos.has_value() ? make_fl_value(functional_map(frameInfos.value(), [](const std::shared_ptr<FrameInfo>& item) { return item->toEncodableMap(); })) : make_fl_value()}
    };
  }
}