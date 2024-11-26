#include "../utils/flutter.h"
#include "browser_process_exited_detail.h"

namespace flutter_inappwebview_plugin
{
  BrowserProcessExitedDetail::BrowserProcessExitedDetail(const std::optional<int64_t>& kind, const std::optional<int64_t>& processId)
    : kind(kind), processId(processId)
  {}

  flutter::EncodableMap BrowserProcessExitedDetail::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"kind", make_fl_value(kind)},
      {"processId", make_fl_value(processId)}
    };
  }
}