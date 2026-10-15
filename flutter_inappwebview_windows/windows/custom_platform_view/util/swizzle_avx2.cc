/*
 * Copyright 2016 Google Inc.
 *
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 *
 * see skia/src/opts/SkSwizzler_opts.h
 */

// This translation unit is compiled with /arch:AVX2 (see CMakeLists.txt). It
// MUST NOT include swizzle.h: the inline RGBA_to_BGRA / RGBA_to_BGRA_portable
// there would then be emitted with AVX2 codegen and could be COMDAT-folded over
// the baseline copies at link time, reintroducing the pre-Haswell crash. Keep
// it standalone so only RGBA_to_BGRA_AVX2 carries AVX2 opcodes; it is only ever
// called after the runtime info.has_avx2() check in RGBA_to_BGRA.

#include <immintrin.h>

#include <algorithm>
#include <cstdint>

void RGBA_to_BGRA_AVX2(uint32_t* dst, const uint32_t* src, int height,
                       int src_stride, int dst_stride) {
  const __m256i swapRB =
      _mm256_setr_epi8(2, 1, 0, 3, 6, 5, 4, 7, 10, 9, 8, 11, 14, 13, 12, 15, 2,
                       1, 0, 3, 6, 5, 4, 7, 10, 9, 8, 11, 14, 13, 12, 15);

  auto width = std::min<int>(src_stride, dst_stride);

  for (int y = 0; y < height; y++) {
    auto cw = width;
    auto rptr = src;
    auto dptr = dst;
    while (cw >= 8) {
      __m256i rgba = _mm256_loadu_si256((const __m256i*)rptr);
      __m256i bgra = _mm256_shuffle_epi8(rgba, swapRB);
      _mm256_storeu_si256((__m256i*)dptr, bgra);

      rptr += 8;
      dptr += 8;
      cw -= 8;
    }

    for (auto x = 0; x < cw; x++) {
      uint8_t a = (rptr[x] >> 24) & 0xFF, b = (rptr[x] >> 16) & 0xFF,
              g = (rptr[x] >> 8) & 0xFF, r = (rptr[x] >> 0) & 0xFF;
      dptr[x] = (uint32_t)a << 24 | (uint32_t)r << 16 | (uint32_t)g << 8 |
                (uint32_t)b << 0;
    }

    src += src_stride;
    dst += dst_stride;
  }
}
