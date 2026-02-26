#include "../utils/flutter.h"
#include "../utils/vector.h"
#include "browser_process_infos_changed_detail.h"

namespace flutter_inappwebview_plugin
{
  BrowserProcessInfosChangedDetail::BrowserProcessInfosChangedDetail(const std::vector<std::shared_ptr<BrowserProcessInfo>>& infos)
    : infos(infos)
  {}

  std::unique_ptr<BrowserProcessInfosChangedDetail> BrowserProcessInfosChangedDetail::fromICoreWebView2ProcessInfoCollection(const wil::com_ptr<ICoreWebView2ProcessInfoCollection> processCollection)
  {
    std::vector<std::shared_ptr<BrowserProcessInfo>> infos = {};
    UINT count;
    if (SUCCEEDED(processCollection->get_Count(&count))) {
      for (UINT i = 0; i < count; i++) {
        wil::com_ptr<ICoreWebView2ProcessInfo> processInfo;
        if (SUCCEEDED(processCollection->GetValueAtIndex(i, &processInfo))) {
          infos.push_back(BrowserProcessInfo::fromICoreWebView2ProcessInfo(processInfo));
        }
      }
    }
    return std::make_unique<BrowserProcessInfosChangedDetail>(infos);
  }

  std::unique_ptr<BrowserProcessInfosChangedDetail> BrowserProcessInfosChangedDetail::fromICoreWebView2ProcessExtendedInfoCollection(const wil::com_ptr<ICoreWebView2ProcessExtendedInfoCollection> processCollection)
  {
    std::vector<std::shared_ptr<BrowserProcessInfo>> infos = {};
    UINT count;
    if (SUCCEEDED(processCollection->get_Count(&count))) {
      for (UINT i = 0; i < count; i++) {
        wil::com_ptr<ICoreWebView2ProcessExtendedInfo> processInfo;
        if (SUCCEEDED(processCollection->GetValueAtIndex(i, &processInfo))) {
          infos.push_back(BrowserProcessInfo::fromICoreWebView2ProcessExtendedInfo(processInfo));
        }
      }
    }
    return std::make_unique<BrowserProcessInfosChangedDetail>(infos);
  }

  flutter::EncodableMap BrowserProcessInfosChangedDetail::toEncodableMap() const
  {
    return flutter::EncodableMap{
      { "infos", make_fl_value(functional_map(infos, [](const std::shared_ptr<BrowserProcessInfo>& info) { return info->toEncodableMap(); })) }
    };
  }
}