/*
 * Copyright (C) 2019 Igalia S.L.
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

#if !defined(__WPE_FDO_EGL_H_INSIDE__) && !defined(WPE_FDO_COMPILATION)
#error "Only <wpe/fdo-egl.h> can be included directly."
#endif

#ifndef __exported_image_egl_h__
#define __exported_image_egl_h__

/**
 * SECTION:egl_exported_image
 * @short_description: EGL exported images.
 * @include wpe/fdo-egl.h
 *
 * Represents an EGL exported image with some associated attributes.
 *
 * An `wpe_fdo_egl_exported_image` represents an `EGLImageKHR` object,
 * which may be retrieved using wpe_fdo_egl_exported_image_get_egl_image(),
 * and provides additional information about it.
 */

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void* EGLImageKHR;

struct wpe_fdo_egl_exported_image;

/**
 * wpe_fdo_egl_exported_image_get_width:
 * @image: (transfer none): An exported EGL image.
 *
 * Gets the width of an exported @image.
 *
 * Returns: Image width.
 */
uint32_t
wpe_fdo_egl_exported_image_get_width(struct wpe_fdo_egl_exported_image *image);

/**
 * wpe_fdo_egl_exported_image_get_height:
 * @image: (transfer none): An exported EGL image.
 *
 * Gets the height of an exported @image.
 *
 * Returns: Image height.
 */
uint32_t
wpe_fdo_egl_exported_image_get_height(struct wpe_fdo_egl_exported_image *image);

/**
 * wpe_fdo_egl_exported_image_get_egl_image:
 * @image: (transfer none): An exported EGL image.
 *
 * Gets the `EGLImage` for en exported @image.
 *
 * Returns: (transfer none): An `EGLImage` handle.
 */
EGLImageKHR
wpe_fdo_egl_exported_image_get_egl_image(struct wpe_fdo_egl_exported_image *image);

#ifdef __cplusplus
}
#endif

#endif /* __exported_image_egl_h___ */
