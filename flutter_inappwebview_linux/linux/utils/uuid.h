#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_UUID_UTIL_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_UUID_UTIL_H_

#include <iomanip>
#include <random>
#include <sstream>
#include <string>

namespace flutter_inappwebview_plugin {

// Generate a UUID v4 string using standard C++ random
static inline std::string get_uuid() {
  static std::random_device rd;
  static std::mt19937 gen(rd());
  static std::uniform_int_distribution<uint32_t> dis(0, 0xFFFFFFFF);

  uint32_t data1 = dis(gen);
  uint16_t data2 = static_cast<uint16_t>(dis(gen) & 0xFFFF);
  uint16_t data3 = static_cast<uint16_t>((dis(gen) & 0x0FFF) | 0x4000);  // Version 4
  uint16_t data4 = static_cast<uint16_t>((dis(gen) & 0x3FFF) | 0x8000);  // Variant 1
  uint32_t data5_hi = dis(gen);
  uint16_t data5_lo = static_cast<uint16_t>(dis(gen) & 0xFFFF);

  std::ostringstream oss;
  oss << std::hex << std::setfill('0') << std::setw(8) << data1 << "-" << std::setw(4) << data2
      << "-" << std::setw(4) << data3 << "-" << std::setw(4) << data4 << "-" << std::setw(8)
      << data5_hi << std::setw(4) << data5_lo;

  return oss.str();
}

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_UUID_UTIL_H_
