/*
 * Adopted from the Weston project <https://cgit.freedesktop.org/wayland/weston>
 * along with its license.
 */

#pragma once

#include <wayland-server.h>
#include "drm_fourcc.h"

#define MAX_DMABUF_PLANES 4

struct linux_dmabuf_attributes {
    uint32_t width;
    uint32_t height;
    uint32_t format;
    uint32_t flags; /* enum zlinux_buffer_params_flags */
    int8_t n_planes;
    int fd[MAX_DMABUF_PLANES];
    uint32_t offset[MAX_DMABUF_PLANES];
    uint32_t stride[MAX_DMABUF_PLANES];
    uint64_t modifier[MAX_DMABUF_PLANES];
};

typedef void (*linux_dmabuf_user_data_destroy_func)(struct linux_dmabuf_buffer *buffer);

struct linux_dmabuf_buffer {
    struct wl_resource *buffer_resource;
    struct wl_resource *params_resource;
    struct linux_dmabuf_attributes attributes;

    void *user_data;
    linux_dmabuf_user_data_destroy_func user_data_destroy_func;

    struct wl_list link;
};

struct wl_global *
linux_dmabuf_setup(struct wl_display *wl_display);

bool
linux_dmabuf_buffer_implements_resource(struct wl_resource*);

void
linux_dmabuf_buffer_destroy(struct linux_dmabuf_buffer *buffer);
