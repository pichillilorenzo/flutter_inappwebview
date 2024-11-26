#include "../utils/flutter.h"
#include "physical_key_status.h"

namespace flutter_inappwebview_plugin
{
  PhysicalKeyStatus::PhysicalKeyStatus(const int64_t& repeatCount,
    const int64_t& scanCode,
    const bool& isExtendedKey,
    const bool& isMenuKeyDown,
    const bool& wasKeyDown,
    const bool& isKeyReleased)
    : repeatCount(repeatCount), scanCode(scanCode), isExtendedKey(isExtendedKey), isMenuKeyDown(isMenuKeyDown), wasKeyDown(wasKeyDown), isKeyReleased(isKeyReleased)
  {}

  std::unique_ptr<PhysicalKeyStatus> PhysicalKeyStatus::fromCOREWEBVIEW2_PHYSICAL_KEY_STATUS(const COREWEBVIEW2_PHYSICAL_KEY_STATUS& status)
  {
    return std::make_unique<PhysicalKeyStatus>(status.RepeatCount, status.ScanCode, status.IsExtendedKey, status.IsMenuKeyDown, status.WasKeyDown, status.IsKeyReleased);
  }

  flutter::EncodableMap PhysicalKeyStatus::toEncodableMap() const
  {
    return flutter::EncodableMap{
      { "repeatCount", make_fl_value(repeatCount) },
      { "scanCode", make_fl_value(scanCode) },
      { "isExtendedKey", make_fl_value(isExtendedKey) },
      { "isMenuKeyDown", make_fl_value(isMenuKeyDown) },
      { "wasKeyDown", make_fl_value(wasKeyDown) },
      { "isKeyReleased", make_fl_value(isKeyReleased) }
    };
  }
}