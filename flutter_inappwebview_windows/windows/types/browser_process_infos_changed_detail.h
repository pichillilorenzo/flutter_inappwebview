#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_BROWSER_PROCESS_INFOS_CHANGED_DETAIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_BROWSER_PROCESS_INFOS_CHANGED_DETAIL_H_

#include <flutter/standard_method_codec.h>

#include "browser_process_info.h"

namespace flutter_inappwebview_plugin
{
  class BrowserProcessInfosChangedDetail
  {
  public:
    const std::vector<std::shared_ptr<BrowserProcessInfo>> infos;

    BrowserProcessInfosChangedDetail(const std::vector<std::shared_ptr<BrowserProcessInfo>>& infos);
    ~BrowserProcessInfosChangedDetail() = default;

    static std::unique_ptr<BrowserProcessInfosChangedDetail> fromICoreWebView2ProcessInfoCollection(const wil::com_ptr<ICoreWebView2ProcessInfoCollection> processCollection);
    static std::unique_ptr<BrowserProcessInfosChangedDetail> fromICoreWebView2ProcessExtendedInfoCollection(const wil::com_ptr<ICoreWebView2ProcessExtendedInfoCollection> processCollection);

    flutter::EncodableMap toEncodableMap() const;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_BROWSER_PROCESS_INFOS_CHANGED_DETAIL_H_