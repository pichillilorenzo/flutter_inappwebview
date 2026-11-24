#include "../utils/frame_pixels.h"

#include <cstdlib>
#include <iostream>

using flutter_inappwebview_plugin::PackFramePixels;

static void Check(bool passed, const char* message) {
  if (!passed) {
    std::cerr << message << '\n';
    std::exit(EXIT_FAILURE);
  }
}

int main() {
  const uint8_t padded[] = {1, 2,  3,  4,  5,  6,  7,  8,  99, 99, 99, 99,
                            9, 10, 11, 12, 13, 14, 15, 16, 99, 99, 99, 99};
  std::vector<uint8_t> result;
  Check(PackFramePixels(padded, sizeof(padded), 12, 2, 2, false, result),
        "Padded ARGB frame rejected");
  Check(result == std::vector<uint8_t>({3, 2, 1, 4, 7, 6, 5, 8, 11, 10, 9, 12, 15, 14, 13, 16}),
        "Row padding or BGRA conversion is incorrect");
  Check(PackFramePixels(padded, sizeof(padded), 12, 2, 2, true, result),
        "Padded XRGB frame rejected");
  Check(
      result == std::vector<uint8_t>({3, 2, 1, 255, 7, 6, 5, 255, 11, 10, 9, 255, 15, 14, 13, 255}),
      "XRGB alpha must be opaque");
  const auto previous = result;
  Check(!PackFramePixels(nullptr, sizeof(padded), 12, 2, 2, false, result), "Null data accepted");
  Check(!PackFramePixels(padded, sizeof(padded), 0, 2, 2, false, result), "Zero stride accepted");
  Check(!PackFramePixels(padded, sizeof(padded), 4, 2, 2, false, result), "Short row accepted");
  Check(!PackFramePixels(padded, sizeof(padded) - 1, 12, 2, 2, false, result),
        "Short buffer accepted");
  Check(!PackFramePixels(padded, sizeof(padded), 12, 0, 2, false, result), "Zero width accepted");
  Check(!PackFramePixels(padded, sizeof(padded), 12, 2, 0, false, result), "Zero height accepted");
  Check(!PackFramePixels(padded, sizeof(padded), 12, UINT32_MAX, UINT32_MAX, false, result),
        "Oversized frame accepted");
  Check(result == previous, "Rejected input changed the previous frame");
  Check(PackFramePixels(padded, 4, 4, 1, 1, false, result), "Single pixel rejected");
  Check(result == std::vector<uint8_t>({3, 2, 1, 4}), "Resizing left stale pixels");
  std::cout << "Frame pixel tests passed\n";
}
