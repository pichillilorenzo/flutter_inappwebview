/*
 * Copyright (C) 2025 Igalia S.L.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#pragma once

#if defined(WPE_ENABLE_ANDROID) && WPE_ENABLE_ANDROID
#include <android/log.h>

#define wpe_log(level, fmt, ...) __android_log_print(ANDROID_LOG_##level, "libwpe", (fmt), ##__VA_ARGS__)

#else
#include <stdio.h>

#define wpe_log(level, fmt, ...)                                          \
    do {                                                                  \
        fprintf(stderr, "libwpe [" #level "]: " fmt "\n", ##__VA_ARGS__); \
        fflush(stderr);                                                   \
    } while (0)

#endif

#define wpe_log_debug(fmt, ...)   wpe_log(DEBUG, fmt, ##__VA_ARGS__)
#define wpe_log_warning(fmt, ...) wpe_log(WARN, fmt, ##__VA_ARGS__)
#define wpe_log_error(fmt, ...)   wpe_log(ERROR, fmt, ##__VA_ARGS__)
#define wpe_log_fatal(fmt, ...)   wpe_log(FATAL, fmt, ##__VA_ARGS__)
