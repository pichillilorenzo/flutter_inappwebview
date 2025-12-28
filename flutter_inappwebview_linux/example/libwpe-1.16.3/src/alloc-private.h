/*
 * Copyright (C) 2022 Igalia S.L.
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

#ifndef wpe_alloc_private_h
#define wpe_alloc_private_h

#include <stdlib.h>
#include <string.h>

#if defined(__has_attribute) && __has_attribute(noreturn)
#define WPE_NORETURN __attribute__((noreturn))
#else
#define WPE_NORETURN
#endif /* __has_attribute(noreturn) */

#if defined(__has_attribute) && __has_attribute(alloc_size)
#define WPE_ALLOCSIZE(...) __attribute__((alloc_size(__VA_ARGS__)))
#else
#define WPE_ALLOCSIZE(...)
#endif /* __has_attribute(alloc_size) */

#if defined(__has_attribute) && __has_attribute(malloc)
#define WPE_MALLOC __attribute__((malloc))
#else
#define WPE_MALLOC
#endif /* __has_attribute(malloc) */

#if defined(__has_attribute) && __has_attribute(warn_unused_result)
#define WPE_USERESULT __attribute__((warn_unused_result))
#else
#define WPE_USERESULT
#endif /* __has_attribute(warn_unused_result) */

#ifdef __cplusplus
extern "C"
#endif /* __cplusplus */
    WPE_NORETURN void
    wpe_alloc_fail(const char* file, unsigned line, size_t amount);

WPE_ALLOCSIZE(1, 2)
WPE_MALLOC WPE_USERESULT static inline void*
wpe_calloc_impl(size_t nmemb, size_t size, const char* file, unsigned line)
{
    void* p = calloc(nmemb, size);
    if (p)
        return p;

    wpe_alloc_fail(file, line, nmemb * size);
}

WPE_ALLOCSIZE(2)
WPE_USERESULT static inline void*
wpe_realloc_impl(void* p, size_t size, const char* file, unsigned line)
{
    if ((p = realloc(p, size)))
        return p;

    wpe_alloc_fail(file, line, size);
}

WPE_ALLOCSIZE(1)
WPE_MALLOC WPE_USERESULT static inline void*
wpe_malloc_impl(size_t size, const char* file, unsigned line)
{
    void* p = malloc(size);
    if (p)
        return p;

    wpe_alloc_fail(file, line, size);
}

#define wpe_calloc(nmemb, size) wpe_calloc_impl((nmemb), (size), __FILE__, __LINE__)
#define wpe_realloc(p, size)    wpe_realloc_impl((p), (size), __FILE__, __LINE__)
#define wpe_malloc(size)        wpe_malloc_impl((size), __FILE__, __LINE__)
#define wpe_free                free

/* Prevent usage of unwrapped functions from this point onwards. */
#pragma GCC poison malloc
#pragma GCC poison realloc
#pragma GCC poison calloc
#pragma GCC poison free

#undef WPE_ALLOCSIZE
#undef WPE_MALLOC
#undef WPE_NORETURN
#undef WPE_USERESULT

#endif /* wpe_alloc_private_h */
