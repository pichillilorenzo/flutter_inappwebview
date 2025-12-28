/*
 * Copyright (C) 2020 Igalia S.L.
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

#if !defined(__WPE_FDO_EGL_H_INSIDE__) && !defined(__WPE_FDO_SHM_H_INSIDE__) && !defined(__WPE_FDO_H_INSIDE__) && !defined(WPE_FDO_COMPILATION)
#error "Only <wpe/fdo-egl.h>, <wpe/unstable/fdo-shm.h> or <wpe/fdo.h> can be included directly."
#endif

#ifndef __exported_buffer_shm_h__
#define __exported_buffer_shm_h__

#ifdef __cplusplus
extern "C" {
#endif

struct wpe_fdo_shm_exported_buffer;
struct wl_resource;
struct wl_shm_buffer;

struct wl_resource*
wpe_fdo_shm_exported_buffer_get_resource(struct wpe_fdo_shm_exported_buffer*);

struct wl_shm_buffer*
wpe_fdo_shm_exported_buffer_get_shm_buffer(struct wpe_fdo_shm_exported_buffer*);

#ifdef __cplusplus
}
#endif

#endif /* __exported_buffer_shm_h__ */
