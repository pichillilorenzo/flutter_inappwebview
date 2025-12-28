/*
 * Adopted from the Weston project <https://cgit.freedesktop.org/wayland/weston>
 * along with its license.
 */

#include "../ws-egl.h"
#include "linux-dmabuf.h"
#include "linux-dmabuf-unstable-v1-server-protocol.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static void
params_destroy(struct wl_client *client, struct wl_resource *resource)
{
    wl_resource_destroy(resource);
}

static void
params_add(struct wl_client *client,
	   struct wl_resource *params_resource,
	   int name_fd,
	   uint32_t plane_idx,
	   uint32_t offset,
	   uint32_t stride,
	   uint32_t modifier_hi,
	   uint32_t modifier_lo)
{
    auto *buffer = static_cast<struct linux_dmabuf_buffer *>(wl_resource_get_user_data(params_resource));
    if (!buffer) {
        wl_resource_post_error(params_resource,
                               ZWP_LINUX_BUFFER_PARAMS_V1_ERROR_ALREADY_USED,
                               "params was already used to create a wl_buffer");
        close(name_fd);
        return;
    }

    assert(buffer->params_resource == params_resource);
    assert(!buffer->buffer_resource);

    if (plane_idx >= MAX_DMABUF_PLANES) {
        wl_resource_post_error(params_resource,
                               ZWP_LINUX_BUFFER_PARAMS_V1_ERROR_PLANE_IDX,
                               "plane index %u is too high", plane_idx);
        close(name_fd);
        return;
    }

    if (buffer->attributes.fd[plane_idx] != -1) {
        wl_resource_post_error(params_resource,
                               ZWP_LINUX_BUFFER_PARAMS_V1_ERROR_PLANE_SET,
                               "a dmabuf has already been added for plane %u",
                               plane_idx);
        close(name_fd);
        return;
    }

    buffer->attributes.fd[plane_idx] = name_fd;
    buffer->attributes.offset[plane_idx] = offset;
    buffer->attributes.stride[plane_idx] = stride;

    if (wl_resource_get_version(params_resource) < ZWP_LINUX_DMABUF_V1_MODIFIER_SINCE_VERSION)
        buffer->attributes.modifier[plane_idx] = DRM_FORMAT_MOD_INVALID;
    else
        buffer->attributes.modifier[plane_idx] = ((uint64_t)modifier_hi << 32) |
                                                            modifier_lo;

    buffer->attributes.n_planes++;
}

static void
destroy_wl_buffer_resource(struct wl_resource *resource)
{
    auto *buffer = static_cast<struct linux_dmabuf_buffer *>(wl_resource_get_user_data(resource));
    assert(buffer && buffer->buffer_resource == resource);
    assert(!buffer->params_resource);

    if (buffer->user_data_destroy_func)
        buffer->user_data_destroy_func(buffer);

    linux_dmabuf_buffer_destroy(buffer);
}

static void
linux_dmabuf_wl_buffer_destroy(struct wl_client *client,
			       struct wl_resource *resource)
{
    wl_resource_destroy(resource);
}

static const struct wl_buffer_interface linux_dmabuf_buffer_implementation = {
    .destroy = linux_dmabuf_wl_buffer_destroy
};

static bool
import_dmabuf(struct linux_dmabuf_buffer *dmabuf)
{
    for (int i = 1; i < dmabuf->attributes.n_planes; i++) {
        /* Return if modifiers passed are unequal. */
        if (dmabuf->attributes.modifier[i] != dmabuf->attributes.modifier[0])
            return false;
    }

    /* Accept the buffer. */
    WS::instanceImpl<WS::ImplEGL>().importDmaBufBuffer(dmabuf);

    return true;
}

static void
params_create_common(struct wl_client *client, struct wl_resource *params_resource,
                     uint32_t buffer_id, int32_t width, int32_t height,
                     uint32_t format, uint32_t flags)
{
    auto *buffer = static_cast<struct linux_dmabuf_buffer *>(wl_resource_get_user_data(params_resource));
    if (!buffer) {
        wl_resource_post_error(params_resource,
                               ZWP_LINUX_BUFFER_PARAMS_V1_ERROR_ALREADY_USED,
                               "params was already used to create a wl_buffer");
        return;
    }

    assert(buffer->params_resource == params_resource);
    assert(!buffer->buffer_resource);

    /* Switch the linux_dmabuf_buffer object from params resource to
     * eventually wl_buffer resource.
     */
    wl_resource_set_user_data(buffer->params_resource, NULL);
    buffer->params_resource = NULL;

    if (!buffer->attributes.n_planes) {
        wl_resource_post_error(params_resource,
                               ZWP_LINUX_BUFFER_PARAMS_V1_ERROR_INCOMPLETE,
                               "no dmabuf has been added to the params");
        goto err_out;
    }

    /* Check for holes in the dmabufs set (e.g. [0, 1, 3]). */
    for (int i = 0; i < buffer->attributes.n_planes; i++) {
        if (buffer->attributes.fd[i] == -1) {
            wl_resource_post_error(params_resource,
                                   ZWP_LINUX_BUFFER_PARAMS_V1_ERROR_INCOMPLETE,
                                   "no dmabuf has been added for plane %i", i);
            goto err_out;
        }
    }

    buffer->attributes.width = width;
    buffer->attributes.height = height;
    buffer->attributes.format = format;
    buffer->attributes.flags = flags;

    if (width < 1 || height < 1) {
        wl_resource_post_error(params_resource,
                               ZWP_LINUX_BUFFER_PARAMS_V1_ERROR_INVALID_DIMENSIONS,
                               "invalid width %d or height %d", width, height);
        goto err_out;
    }

    for (int i = 0; i < buffer->attributes.n_planes; i++) {
        off_t size;

        if ((uint64_t) buffer->attributes.offset[i] + buffer->attributes.stride[i] > UINT32_MAX) {
            wl_resource_post_error(params_resource,
                                   ZWP_LINUX_BUFFER_PARAMS_V1_ERROR_OUT_OF_BOUNDS,
                                   "size overflow for plane %i", i);
            goto err_out;
        }

        if (i == 0 &&
            (uint64_t) buffer->attributes.offset[i] +
            (uint64_t) buffer->attributes.stride[i] * height > UINT32_MAX) {
            wl_resource_post_error(params_resource,
                                   ZWP_LINUX_BUFFER_PARAMS_V1_ERROR_OUT_OF_BOUNDS,
                                   "size overflow for plane %i", i);
            goto err_out;
        }

        /* Don't report an error as it might be caused
         * by the kernel not supporting seeking on dmabuf.
         */
        size = lseek(buffer->attributes.fd[i], 0, SEEK_END);
        if (size == -1)
            continue;

        if (buffer->attributes.offset[i] >= size) {
            wl_resource_post_error(params_resource,
                                   ZWP_LINUX_BUFFER_PARAMS_V1_ERROR_OUT_OF_BOUNDS,
                                   "invalid offset %i for plane %i",
                                   buffer->attributes.offset[i], i);
            goto err_out;
        }

        if (buffer->attributes.offset[i] + buffer->attributes.stride[i] > size) {
            wl_resource_post_error(params_resource,
                                   ZWP_LINUX_BUFFER_PARAMS_V1_ERROR_OUT_OF_BOUNDS,
                                   "invalid stride %i for plane %i",
                                   buffer->attributes.stride[i], i);
            goto err_out;
        }

        /* Only valid for first plane as other planes might be
         * sub-sampled according to fourcc format.
         */
        if (i == 0 &&
            buffer->attributes.offset[i] + buffer->attributes.stride[i] * height > size) {
            wl_resource_post_error(params_resource,
                                   ZWP_LINUX_BUFFER_PARAMS_V1_ERROR_OUT_OF_BOUNDS,
                                   "invalid buffer stride or height for plane %i", i);
            goto err_out;
        }
    }

    /* XXX: Some additional sanity checks could be done with respect
     * to the fourcc format. A centralized collection (kernel or
     * libdrm) would be useful to avoid code duplication for these
     * checks (e.g. drm_format_num_planes).
     */

    if (!import_dmabuf(buffer))
        goto err_failed;

    buffer->buffer_resource = wl_resource_create(client,
                                                 &wl_buffer_interface,
                                                 1, buffer_id);
    if (!buffer->buffer_resource) {
        wl_resource_post_no_memory(params_resource);
        goto err_buffer;
    }

    wl_resource_set_implementation(buffer->buffer_resource,
                                   &linux_dmabuf_buffer_implementation,
                                   buffer, destroy_wl_buffer_resource);

    /* Send 'created' event when the request is not for an immediate
     * import, ie buffer_id is zero.
     */
    if (buffer_id == 0)
        zwp_linux_buffer_params_v1_send_created(params_resource,
						buffer->buffer_resource);

    return;

 err_buffer:
    if (buffer->user_data_destroy_func)
        buffer->user_data_destroy_func(buffer);

 err_failed:
    if (buffer_id == 0) {
        zwp_linux_buffer_params_v1_send_failed(params_resource);
    } else {
      /* Since the behavior is left implementation defined by the
       * protocol in case of create_immed failure due to an unknown cause,
       * we choose to treat it as a fatal error and immediately kill the
       * client instead of creating an invalid handle and waiting for it
       * to be used.
       */
      wl_resource_post_error(params_resource,
                             ZWP_LINUX_BUFFER_PARAMS_V1_ERROR_INVALID_WL_BUFFER,
                             "importing the supplied dmabufs failed");
    }

 err_out:
    linux_dmabuf_buffer_destroy(buffer);
}

static void
params_create(struct wl_client *client,
	      struct wl_resource *params_resource,
	      int32_t width,
	      int32_t height,
	      uint32_t format,
	      uint32_t flags)
{
    params_create_common(client, params_resource, 0, width, height, format,
                         flags);
}

static void
params_create_immed(struct wl_client *client,
		    struct wl_resource *params_resource,
		    uint32_t buffer_id,
		    int32_t width,
		    int32_t height,
		    uint32_t format,
		    uint32_t flags)
{
    params_create_common(client, params_resource, buffer_id, width, height,
                         format, flags);
}

static const struct zwp_linux_buffer_params_v1_interface
zwp_linux_buffer_params_implementation = {
    .destroy = params_destroy,
    .add = params_add,
    .create = params_create,
    .create_immed = params_create_immed
};

static void
destroy_params(struct wl_resource *params_resource)
{
    auto *buffer = static_cast<struct linux_dmabuf_buffer *>(wl_resource_get_user_data(params_resource));
    if (!buffer)
        return;

    linux_dmabuf_buffer_destroy(buffer);
}

static void
linux_dmabuf_destroy(struct wl_client *client, struct wl_resource *resource)
{
    wl_resource_destroy(resource);
}

static void
linux_dmabuf_create_params(struct wl_client *client,
			   struct wl_resource *linux_dmabuf_resource,
			   uint32_t params_id)
{
    uint32_t version = wl_resource_get_version(linux_dmabuf_resource);

    auto *buffer = static_cast<struct linux_dmabuf_buffer *>(calloc(1, sizeof(struct linux_dmabuf_buffer)));
    if (!buffer)
        goto err_out;

    for (int i = 0; i < MAX_DMABUF_PLANES; i++)
        buffer->attributes.fd[i] = -1;

    buffer->buffer_resource = NULL;
    buffer->params_resource =
        wl_resource_create(client,
                           &zwp_linux_buffer_params_v1_interface,
                           version, params_id);
    if (!buffer->params_resource)
        goto err_dealloc;

    wl_resource_set_implementation(buffer->params_resource,
                                   &zwp_linux_buffer_params_implementation,
                                   buffer, destroy_params);

    return;

err_dealloc:
    free(buffer);

err_out:
    wl_resource_post_no_memory(linux_dmabuf_resource);
}

static void
dmabuf_feedback_resource_destroy(struct wl_resource *resource)
{
    wl_list_remove(wl_resource_get_link(resource));
}

static void
dmabuf_feedback_destroy(struct wl_client *client, struct wl_resource *resource)
{
    wl_resource_destroy(resource);
}

static const struct zwp_linux_dmabuf_feedback_v1_interface
zwp_linux_dmabuf_feedback_implementation = {
    dmabuf_feedback_destroy
};

static void
linux_dmabuf_get_default_feedback(struct wl_client *client,
                                  struct wl_resource *dmabuf_resource,
                                  uint32_t dmabuf_feedback_id)
{
    uint32_t version = wl_resource_get_version(dmabuf_resource);
    struct wl_resource *feedback_resource = wl_resource_create(client, &zwp_linux_dmabuf_feedback_v1_interface, version, dmabuf_feedback_id);
    if (!feedback_resource) {
        wl_resource_post_no_memory(dmabuf_resource);
        return;
    }

    wl_list_init(wl_resource_get_link(feedback_resource));
    wl_resource_set_implementation(feedback_resource, &zwp_linux_dmabuf_feedback_implementation, nullptr, dmabuf_feedback_resource_destroy);

    auto& egl = WS::instanceImpl<WS::ImplEGL>();
    zwp_linux_dmabuf_feedback_v1_send_format_table(feedback_resource, egl.dmabufFormatTableFD(), egl.dmabufFormatTableSize());
    zwp_linux_dmabuf_feedback_v1_send_main_device(feedback_resource, egl.dmabufMainDevice());

    zwp_linux_dmabuf_feedback_v1_send_tranche_target_device(feedback_resource, egl.dmabufMainDevice());
    zwp_linux_dmabuf_feedback_v1_send_tranche_flags(feedback_resource, 0);
    zwp_linux_dmabuf_feedback_v1_send_tranche_formats(feedback_resource, egl.dmabufFormatTableIndices());
    zwp_linux_dmabuf_feedback_v1_send_tranche_done(feedback_resource);

    zwp_linux_dmabuf_feedback_v1_send_done(feedback_resource);
}

static void
linux_dmabuf_get_surface_feedback(struct wl_client*,
                                  struct wl_resource*,
                                  uint32_t /* dmabuf_feedback_id */,
                                  struct wl_resource*)
{
    // We don't support per surface feedback, but since we claim to support version 4 we need to provide an implementation.
}

static const struct zwp_linux_dmabuf_v1_interface linux_dmabuf_implementation = {
    .destroy = linux_dmabuf_destroy,
    .create_params = linux_dmabuf_create_params,
    .get_default_feedback = linux_dmabuf_get_default_feedback,
    .get_surface_feedback = linux_dmabuf_get_surface_feedback
};

static void
bind_linux_dmabuf(struct wl_client *client, void *data, uint32_t version, uint32_t id)
{
    struct wl_resource *resource =
        wl_resource_create(client, &zwp_linux_dmabuf_v1_interface,
                           version, id);
    if (resource == NULL) {
        wl_client_post_no_memory(client);
        return;
    }

    wl_resource_set_implementation(resource, &linux_dmabuf_implementation,
                                   data, NULL);

    WS::instanceImpl<WS::ImplEGL>().foreachDmaBufModifier(
        [version, resource] (int format, uint64_t modifier) {
            if (version >= ZWP_LINUX_DMABUF_V1_MODIFIER_SINCE_VERSION) {
                uint32_t modifier_lo = modifier & 0xFFFFFFFF;
                uint32_t modifier_hi = modifier >> 32;
                zwp_linux_dmabuf_v1_send_modifier(resource, format, modifier_hi, modifier_lo);
            } else if (modifier == DRM_FORMAT_MOD_LINEAR || modifier == DRM_FORMAT_MOD_INVALID) {
                zwp_linux_dmabuf_v1_send_format(resource, format);
            }
        });
}

/** Advertise linux_dmabuf support.
 *
 * Calling this initializes the zwp_linux_dmabuf protocol support, so that
 * the interface will be advertised to clients. Essentially it creates a
 * global.
 */
struct wl_global *
linux_dmabuf_setup(struct wl_display *wl_display)
{
    assert(wl_display);

    return wl_global_create(wl_display,
                            &zwp_linux_dmabuf_v1_interface,
                            ZWP_LINUX_DMABUF_V1_GET_DEFAULT_FEEDBACK_SINCE_VERSION,
                            NULL, bind_linux_dmabuf);
}

bool
linux_dmabuf_buffer_implements_resource(struct wl_resource *resource)
{
    if (resource == NULL)
        return 0;

    if (wl_resource_instance_of(resource, &wl_buffer_interface,
                                &linux_dmabuf_buffer_implementation))
        return 1;
    return 0;
}

void
linux_dmabuf_buffer_destroy(struct linux_dmabuf_buffer *buffer)
{
    for (int i = 0; i < buffer->attributes.n_planes; i++) {
        close(buffer->attributes.fd[i]);
        buffer->attributes.fd[i] = -1;
    }
    buffer->attributes.n_planes = 0;

    wl_list_remove(&buffer->link);

    free(buffer);
}
