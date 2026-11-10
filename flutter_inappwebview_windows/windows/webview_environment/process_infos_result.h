#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PROCESS_INFOS_RESULT_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PROCESS_INFOS_RESULT_H_

#include <memory>
#include <string>
#include <utility>
#include <vector>

#include "../types/browser_process_info.h"

namespace flutter_inappwebview_plugin
{
  // A successful empty collection is different from an unavailable snapshot.
  // PID and frame details remain optional; the Dart model requires a kind.
  struct ProcessInfosResult
  {
    std::vector<std::shared_ptr<BrowserProcessInfo>> infos;
    HRESULT error = S_OK;
    std::string stage;
    std::string code;

    static ProcessInfosResult failure(HRESULT error, const std::string& stage,
      const std::string& code = "process_info_collection_failed")
    {
      return { {}, error, stage, code };
    }
  };

  // Unlike the best-effort ProcessInfosChanged event decoder, an explicitly
  // requested snapshot must not silently skip unreadable collection entries.
  template <typename TProcessInfo, typename TCollection, typename TConvert>
  ProcessInfosResult readProcessInfoCollection(const wil::com_ptr<TCollection>& collection,
    const std::string& api, TConvert convert)
  {
    if (!collection) {
      return ProcessInfosResult::failure(E_POINTER, api + ".collection");
    }
    UINT count = 0;
    auto hr = collection->get_Count(&count);
    if (FAILED(hr)) {
      return ProcessInfosResult::failure(hr, api + ".get_Count");
    }
    ProcessInfosResult result;
    for (UINT i = 0; i < count; ++i) {
      wil::com_ptr<TProcessInfo> processInfo;
      hr = collection->GetValueAtIndex(i, &processInfo);
      if (FAILED(hr) || !processInfo) {
        return ProcessInfosResult::failure(FAILED(hr) ? hr : E_POINTER,
          api + ".GetValueAtIndex[" + std::to_string(i) + "]");
      }
      std::string requiredFieldStage;
      auto info = convert(processInfo, &hr, &requiredFieldStage);
      if (FAILED(hr)) {
        return ProcessInfosResult::failure(hr,
          api + "[" + std::to_string(i) + "]." + requiredFieldStage);
      }
      result.infos.push_back(std::move(info));
    }
    return result;
  }
}

#endif // FLUTTER_INAPPWEBVIEW_PLUGIN_PROCESS_INFOS_RESULT_H_
