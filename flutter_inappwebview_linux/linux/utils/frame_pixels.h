#ifndef FLUTTER_INAPPWEBVIEW_FRAME_PIXELS_H_
#define FLUTTER_INAPPWEBVIEW_FRAME_PIXELS_H_

#include <cstddef>
#include <cstdint>
#include <limits>
#include <vector>

namespace flutter_inappwebview_plugin {

// Flutter textures need tightly packed RGBA, whereas WPE/GBM rows can be padded.
inline bool PackFramePixels(const uint8_t* source, size_t size, size_t stride, uint32_t width,
                            uint32_t height, bool opaque, std::vector<uint8_t>& result) {
  if (!source || !width || !height || std::numeric_limits<size_t>::max() / width < 4) {
    return false;
  }
  const size_t row_size = static_cast<size_t>(width) * 4;
  if (stride < row_size || height > size / stride ||
      height > std::numeric_limits<size_t>::max() / row_size) {
    return false;
  }
  result.resize(row_size * height);
  for (size_t y = 0; y < height; ++y) {
    const auto* row = source + y * stride;
    auto* output = result.data() + y * row_size;
    for (size_t x = 0; x < row_size; x += 4) {
      output[x] = row[x + 2];
      output[x + 1] = row[x + 1];
      output[x + 2] = row[x];
      output[x + 3] = opaque ? 255 : row[x + 3];
    }
  }
  return true;
}

}  // namespace flutter_inappwebview_plugin
#endif
