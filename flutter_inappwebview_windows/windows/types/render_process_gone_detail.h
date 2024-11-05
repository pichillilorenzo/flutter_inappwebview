#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_RENDER_PROCESS_GONE_DETAIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_RENDER_PROCESS_GONE_DETAIL_H_

#include <flutter/standard_method_codec.h>

namespace flutter_inappwebview_plugin
{

  class RenderProcessGoneDetail
  {
  public:
    const bool didCrash;

      RenderProcessGoneDetail(const bool& didCrash);
    ~RenderProcessGoneDetail() = default;

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_RENDER_PROCESS_GONE_DETAIL_H_