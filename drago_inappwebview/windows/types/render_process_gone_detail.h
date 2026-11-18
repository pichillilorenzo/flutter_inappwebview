#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_RENDER_PROCESS_GONE_DETAIL_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_RENDER_PROCESS_GONE_DETAIL_H_

#include <flutter/standard_method_codec.h>

namespace drago_inappwebview_plugin
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

#endif //DRAGO_INAPPWEBVIEW_PLUGIN_RENDER_PROCESS_GONE_DETAIL_H_