#include "../utils/flutter.h"
#include "../utils/vector.h"
#include "browser_process_info.h"

namespace flutter_inappwebview_plugin
{
  BrowserProcessInfo::BrowserProcessInfo(const std::optional<int64_t>& kind, const std::optional<int64_t>& processId, const std::optional<std::vector<std::shared_ptr<FrameInfo>>>& frameInfos)
    : kind(kind), processId(processId), frameInfos(frameInfos)
  {}

  std::unique_ptr<BrowserProcessInfo> BrowserProcessInfo::fromICoreWebView2ProcessInfo(const wil::com_ptr<ICoreWebView2ProcessInfo> processInfo)
  {
    COREWEBVIEW2_PROCESS_KIND processKind;
    std::optional<int64_t> kind = SUCCEEDED(processInfo->get_Kind(&processKind)) ? static_cast<int64_t>(processKind) : std::optional<int64_t>{};

    INT32 pid;
    std::optional<int64_t> processId = SUCCEEDED(processInfo->get_ProcessId(&pid)) ? static_cast<int64_t>(pid) : std::optional<int64_t>{};

    const std::optional<std::vector<std::shared_ptr<FrameInfo>>> frameInfos = std::optional<std::vector<std::shared_ptr<FrameInfo>>>{};

    return std::make_unique<BrowserProcessInfo>(kind, processId, frameInfos);
  }

  std::unique_ptr<BrowserProcessInfo> BrowserProcessInfo::fromICoreWebView2ProcessExtendedInfo(const wil::com_ptr<ICoreWebView2ProcessExtendedInfo> processExtendedInfo)
  {
    wil::com_ptr<ICoreWebView2ProcessInfo> processInfo;
    processExtendedInfo->get_ProcessInfo(&processInfo);

    COREWEBVIEW2_PROCESS_KIND processKind;
    std::optional<int64_t> kind = processInfo && SUCCEEDED(processInfo->get_Kind(&processKind)) ? static_cast<int64_t>(processKind) : std::optional<int64_t>{};

    INT32 pid;
    std::optional<int64_t> processId = processInfo && SUCCEEDED(processInfo->get_ProcessId(&pid)) ? static_cast<int64_t>(pid) : std::optional<int64_t>{};

    std::optional<std::vector<std::shared_ptr<FrameInfo>>> frameInfos = std::optional<std::vector<std::shared_ptr<FrameInfo>>>{};
    wil::com_ptr<ICoreWebView2FrameInfoCollection> frameInfoCollection;
    if (SUCCEEDED(processExtendedInfo->get_AssociatedFrameInfos(&frameInfoCollection))) {
      wil::com_ptr<ICoreWebView2FrameInfoCollectionIterator> iterator;
      if (SUCCEEDED(frameInfoCollection->GetIterator(&iterator))) {
        frameInfos = std::vector<std::shared_ptr<FrameInfo>>{};
        BOOL hasCurrent = FALSE;
        if (SUCCEEDED(iterator->get_HasCurrent(&hasCurrent)) && hasCurrent) {
          wil::com_ptr<ICoreWebView2FrameInfo> frameInfo;
          if (SUCCEEDED(iterator->GetCurrent(&frameInfo))) {
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