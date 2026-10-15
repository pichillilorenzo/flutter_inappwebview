#include <cassert>
#include <cstdint>
#include <limits>
#include <vector>

#include "../in_app_webview/simd_convert.h"

using flutter_inappwebview_plugin::ConvertARGB32ToRGBA;
using flutter_inappwebview_plugin::ConvertARGB32ToRGBAVector;

int main() {
  constexpr size_t width = 5;  // Odd width also exercises the scalar tail.
  constexpr size_t height = 3;
  constexpr size_t stride = 24;  // Four padding bytes per source row.
  std::vector<uint8_t> source(stride * height, 0xEE);
  for (size_t y = 0; y < height; ++y) {
    for (size_t x = 0; x < width; ++x) {
      const size_t offset = y * stride + x * 4;
      source[offset] = static_cast<uint8_t>(10 + x + y);      // B
      source[offset + 1] = static_cast<uint8_t>(30 + x + y);  // G
      source[offset + 2] = static_cast<uint8_t>(50 + x + y);  // R
      source[offset + 3] = (x + y) % 3 == 0 ? 255 : 96;      // A
    }
  }

  std::vector<uint8_t> expected(width * height * 4);
  ConvertARGB32ToRGBA(source.data(), expected.data(), width, height, stride);
  std::vector<uint8_t> converted;
  assert(ConvertARGB32ToRGBAVector(source.data(), source.size(), converted,
                                   width, height, stride));
  assert(converted == expected);

  // A short source and invalid row pitch must be rejected without replacing
  // the last good frame in the destination vector.
  const std::vector<uint8_t> last_good = converted;
  const size_t required_source_size = (height - 1) * stride + width * 4;
  assert(required_source_size == 68);
  assert(!ConvertARGB32ToRGBAVector(source.data(), required_source_size - 1,
                                    converted, width, height, stride));
  assert(converted == last_good);
  assert(!ConvertARGB32ToRGBAVector(source.data(), source.size(), converted,
                                    width, height, width * 4 - 1));
  assert(converted == last_good);
  assert(!ConvertARGB32ToRGBAVector(nullptr, source.size(), converted,
                                    width, height, stride));
  assert(converted == last_good);

  // Reuse the vector for differently sized frames, including a shrink followed
  // by growth, and compare every result against the same converter.
  for (const size_t size : {size_t{3}, size_t{1}, size_t{7}}) {
    const size_t row_stride = size * 4;
    std::vector<uint8_t> frame(row_stride * 2);
    for (size_t i = 0; i < frame.size(); ++i) {
      frame[i] = static_cast<uint8_t>(i * 13 + size);
    }
    std::vector<uint8_t> reference(size * 2 * 4);
    ConvertARGB32ToRGBA(frame.data(), reference.data(), size, 2, row_stride);
    assert(ConvertARGB32ToRGBAVector(frame.data(), frame.size(), converted,
                                     size, 2, row_stride));
    assert(converted == reference);
  }

  assert(!ConvertARGB32ToRGBAVector(
      source.data(), source.size(), converted,
      std::numeric_limits<size_t>::max(), height, stride));
  return 0;
}
