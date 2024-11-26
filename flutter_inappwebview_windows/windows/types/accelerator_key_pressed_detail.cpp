#include "../utils/flutter.h"
#include "accelerator_key_pressed_detail.h"

namespace flutter_inappwebview_plugin
{
  AcceleratorKeyPressedDetail::AcceleratorKeyPressedDetail(const std::optional<int64_t>& keyEventKind,
    const std::optional<std::shared_ptr<PhysicalKeyStatus>> physicalKeyStatus,
    const std::optional<int64_t>& virtualKey)
    : keyEventKind(keyEventKind), physicalKeyStatus(physicalKeyStatus), virtualKey(virtualKey)
  {}

  std::unique_ptr<AcceleratorKeyPressedDetail> AcceleratorKeyPressedDetail::fromICoreWebView2AcceleratorKeyPressedEventArgs(const wil::com_ptr<ICoreWebView2AcceleratorKeyPressedEventArgs> args)
  {
    COREWEBVIEW2_KEY_EVENT_KIND kind;
    std::optional<int64_t> keyEventKind = SUCCEEDED(args->get_KeyEventKind(&kind)) ? (int64_t)kind : std::optional<int64_t>{};

    COREWEBVIEW2_PHYSICAL_KEY_STATUS status;
    std::optional<std::shared_ptr<PhysicalKeyStatus>> physicalKeyStatus = SUCCEEDED(args->get_PhysicalKeyStatus(&status)) ? PhysicalKeyStatus::fromCOREWEBVIEW2_PHYSICAL_KEY_STATUS(status) : std::optional<std::shared_ptr<PhysicalKeyStatus>>{};

    UINT vKey;
    std::optional<int64_t> virtualKey = SUCCEEDED(args->get_VirtualKey(&vKey)) ? (int64_t)vKey : std::optional<int64_t>{};

    return std::make_unique<AcceleratorKeyPressedDetail>(keyEventKind, physicalKeyStatus, virtualKey);
  }

  flutter::EncodableMap AcceleratorKeyPressedDetail::toEncodableMap() const
  {
    return flutter::EncodableMap{
      { "keyEventKind", make_fl_value(keyEventKind) },
      { "physicalKeyStatus", physicalKeyStatus.has_value() ? make_fl_value(physicalKeyStatus.value()->toEncodableMap()) : make_fl_value() },
      { "virtualKey", make_fl_value(virtualKey) }
    };
  }
}