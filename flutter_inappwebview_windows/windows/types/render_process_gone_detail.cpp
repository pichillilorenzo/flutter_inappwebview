#include "../utils/flutter.h"
#include "render_process_gone_detail.h"

namespace flutter_inappwebview_plugin
{
    RenderProcessGoneDetail::RenderProcessGoneDetail(const bool& didCrash)
    : didCrash(didCrash)
  {}

  flutter::EncodableMap RenderProcessGoneDetail::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"didCrash", make_fl_value(didCrash)}
    };
  }
}