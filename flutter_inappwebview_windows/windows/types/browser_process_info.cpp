#include "../utils/flutter.h"
#include "../utils/vector.h"
#include "browser_process_info.h"

namespace flutter_inappwebview_plugin
{
  BrowserProcessInfo::BrowserProcessInfo(const std::optional<int64_t>& kind, const std::optional<int64_t>& processId, const std::optional<std::vector<std::shared_ptr<FrameInfo>>>& frameInfos)
    : kind(kind), processId(processId), frameInfos(frameInfos)
  {}

  std::unique_ptr<BrowserProcessInfo> BrowserProcessInfo::fromICoreWebView2ProcessInfo(const wil::com_ptr<ICoreWebView2ProcessInfo> processInfo,
    HRESULT* requiredFieldError, std::string* requiredFieldStage)
  {
    COREWEBVIEW2_PROCESS_KIND processKind{};
    auto hr = processInfo ? processInfo->get_Kind(&processKind) : E_POINTER;
    if (requiredFieldError) *requiredFieldError = hr;
    if (requiredFieldStage) *requiredFieldStage = "get_Kind";
    std::optional<int64_t> kind = SUCCEEDED(hr) ? static_cast<int64_t>(processKind) : std::optional<int64_t>{};

    INT32 pid = 0;
    std::optional<int64_t> processId = processInfo && SUCCEEDED(processInfo->get_ProcessId(&pid)) ? static_cast<int64_t>(pid) : std::optional<int64_t>{};

    const std::optional<std::vector<std::shared_ptr<FrameInfo>>> frameInfos = std::optional<std::vector<std::shared_ptr<FrameInfo>>>{};

    return std::make_unique<BrowserProcessInfo>(kind, processId, frameInfos);
  }

  std::unique_ptr<BrowserProcessInfo> BrowserProcessInfo::fromICoreWebView2ProcessExtendedInfo(const wil::com_ptr<ICoreWebView2ProcessExtendedInfo> processExtendedInfo,
    HRESULT* requiredFieldError, std::string* requiredFieldStage)
  {
    wil::com_ptr<ICoreWebView2ProcessInfo> processInfo;
    auto hr = processExtendedInfo ? processExtendedInfo->get_ProcessInfo(&processInfo) : E_POINTER;
    if (SUCCEEDED(hr) && !processInfo) hr = E_POINTER;
    if (requiredFieldStage) *requiredFieldStage = "get_ProcessInfo";

    COREWEBVIEW2_PROCESS_KIND processKind{};
    if (SUCCEEDED(hr)) {
      hr = processInfo->get_Kind(&processKind);
      if (requiredFieldStage) *requiredFieldStage = "get_Kind";
    }
    if (requiredFieldError) *requiredFieldError = hr;
    std::optional<int64_t> kind = SUCCEEDED(hr) ? static_cast<int64_t>(processKind) : std::optional<int64_t>{};

    INT32 pid = 0;
    std::optional<int64_t> processId = processInfo && SUCCEEDED(processInfo->get_ProcessId(&pid)) ? static_cast<int64_t>(pid) : std::optional<int64_t>{};

    std::optional<std::vector<std::shared_ptr<FrameInfo>>> frameInfos = std::optional<std::vector<std::shared_ptr<FrameInfo>>>{};
    wil::com_ptr<ICoreWebView2FrameInfoCollection> frameInfoCollection;
    if (processExtendedInfo && SUCCEEDED(processExtendedInfo->get_AssociatedFrameInfos(&frameInfoCollection)) && frameInfoCollection) {
      wil::com_ptr<ICoreWebView2FrameInfoCollectionIterator> iterator;
      if (SUCCEEDED(frameInfoCollection->GetIterator(&iterator)) && iterator) {
        frameInfos = std::vector<std::shared_ptr<FrameInfo>>{};
        BOOL hasCurrent = FALSE;
        if (SUCCEEDED(iterator->get_HasCurrent(&hasCurrent)) && hasCurrent) {
          wil::com_ptr<ICoreWebView2FrameInfo> frameInfo;
          if (SUCCEEDED(iterator->GetCurrent(&frameInfo)) && frameInfo) {
            frameInfos.value().push_back(FrameInfo::fromICoreWebView2FrameInfo(frameInfo));
          }
        }
      }
    }

    return std::make_unique<BrowserProcessInfo>(kind, processId, frameInfos);
  }

  flutter::EncodableMap BrowserProcessInfo::toEncodableMap() const
  {
    return flutter::EncodableMap{
      {"kind", make_fl_value(kind)},
      {"processId", make_fl_value(processId)},
      {"frameInfos", frameInfos.has_value() ? make_fl_value(functional_map(frameInfos.value(), [](const std::shared_ptr<FrameInfo>& frameInfo) { return frameInfo->toEncodableMap(); })) : make_fl_value()}
    };
  }
}
