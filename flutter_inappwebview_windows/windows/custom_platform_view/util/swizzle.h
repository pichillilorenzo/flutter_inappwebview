/*
 * Copyright 2016 Google Inc.
 *
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

/*
 * see skia/src/opts/SkSwizzler_opts.h
 */

#pragma once

#include <algorithm>
#include <cstdint>

#include "cpuid/cpuinfo.h"

inline void RGBA_to_BGRA_portable(uint32_t* dst, const uint32_t* src,
                                  int height, int src_stride, int dst_stride) {
  auto width = std::min<int>(src_stride, dst_stride);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      uint8_t a = (src[x] >> 24) & 0xFF, b = (src[x] >> 16) & 0xFF,
              g = (src[x] >> 8) & 0xFF, r = (src[x] >> 0) & 0xFF;
      dst[x] = (uint32_t)a << 24 | (uint32_t)r << 16 | (uint32_t)g << 8 |
               (uint32_t)b << 0;
    }

    src += src_stride;
    dst += dst_stride;
  }
}

// AVX2 variant lives in its own translation unit (swizzle_avx2.cc) compiled
// with /arch:AVX2. MSVC has no per-function target attribute, so the only way
// to confine AVX2 opcodes to code reached AFTER the runtime CPUID check below
// is to isolate them in a separate TU. Applying /arch:AVX2 to the whole plugin
// let MSVC emit AVX2 anywhere in the DLL, crashing pre-Haswell CPUs (e.g.
// Sandy Bridge) with STATUS_ILLEGAL_INSTRUCTION 0xc000001d.
void RGBA_to_BGRA_AVX2(uint32_t* dst, const uint32_t* src, int height,
                       int src_stride, int dst_stride);

inline void RGBA_to_BGRA(uint32_t* dst, const uint32_t* src, int height,
                         int src_stride, int dst_stride) {
  static cpuid::cpuinfo info;

  if (info.has_avx2()) {
    return RGBA_to_BGRA_AVX2(dst, src, height, src_stride, dst_stride);
  }

  RGBA_to_BGRA_portable(dst, src, height, src_stride, dst_stride);
}
