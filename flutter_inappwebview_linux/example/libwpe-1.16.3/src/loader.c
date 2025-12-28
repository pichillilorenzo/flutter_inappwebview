/*
 * Copyright (C) 2015, 2016, 2022 Igalia S.L.
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

#include "loader-private.h"

#include <dlfcn.h>
#include <stdio.h>
#include <string.h>

#include "alloc-private.h"
#include "logging-private.h"

static void* s_impl_library = 0;
static struct wpe_loader_interface* s_impl_loader = 0;

#ifndef WPE_BACKEND
#define IMPL_LIBRARY_NAME_BUFFER_SIZE 512
static char* s_impl_library_name;
static char s_impl_library_name_buffer[IMPL_LIBRARY_NAME_BUFFER_SIZE];
#endif

#ifndef WPE_BACKEND
static void
wpe_loader_set_impl_library_name(const char* impl_library_name)
{
    size_t len;

    if (!impl_library_name)
        return;

    len = strlen(impl_library_name) + 1;
    if (len == 1)
        return;

    if (len > IMPL_LIBRARY_NAME_BUFFER_SIZE)
        s_impl_library_name = wpe_malloc(len);
    else
        s_impl_library_name = s_impl_library_name_buffer;
    memcpy(s_impl_library_name, impl_library_name, len);
}
#endif

void
load_impl_library()
{
#ifdef WPE_BACKEND
    s_impl_library = dlopen(WPE_BACKEND, RTLD_NOW);
    if (!s_impl_library) {
        wpe_log_fatal("could not load compile-time defined WPE_BACKEND: %s", dlerror());
        abort();
    }
#else
#ifndef NDEBUG
    // Get the impl library from an environment variable, if available.
    char* env_library_name = getenv("WPE_BACKEND_LIBRARY");
    if (env_library_name) {
        s_impl_library = dlopen(env_library_name, RTLD_NOW);
        if (!s_impl_library) {
            wpe_log_fatal("could not load specified WPE_BACKEND_LIBRARY: %s", dlerror());
            abort();
        }
        wpe_loader_set_impl_library_name(env_library_name);
    }
#endif
    if (!s_impl_library) {
        // Load libWPEBackend-default.so by ... default.
        s_impl_library = dlopen("libWPEBackend-default.so", RTLD_NOW);
        if (!s_impl_library) {
            wpe_log_fatal("could not load the impl library. Is there any backend installed?: %s", dlerror());
            abort();
        }
        wpe_loader_set_impl_library_name("libWPEBackend-default.so");
    }
#endif

    s_impl_loader = dlsym(s_impl_library, "_wpe_loader_interface");
}

bool
wpe_loader_init(const char* impl_library_name)
{
#ifndef WPE_BACKEND
    if (!impl_library_name) {
        wpe_log_fatal("wpe_loader_init: invalid implementation library name");
        abort();
    }

    if (s_impl_library) {
        if (!s_impl_library_name || strcmp(s_impl_library_name, impl_library_name) != 0) {
            wpe_log_fatal("wpe_loader_init: already initialized");
            return false;
        }
        return true;
    }

    s_impl_library = dlopen(impl_library_name, RTLD_NOW);
    if (!s_impl_library) {
        wpe_log_error("wpe_loader_init could not load the library '%s': %s", impl_library_name, dlerror());
        return false;
    }
    wpe_loader_set_impl_library_name(impl_library_name);

    s_impl_loader = dlsym(s_impl_library, "_wpe_loader_interface");
    return true;
#else
    return false;
#endif
}

const char*
wpe_loader_get_loaded_implementation_library_name(void)
{
#ifdef WPE_BACKEND
    return s_impl_library ? WPE_BACKEND : NULL;
#else
    return s_impl_library_name;
#endif
}

void*
wpe_load_object(const char* object_name)
{
    if (!s_impl_library)
        load_impl_library();

    if (s_impl_loader) {
        if (!s_impl_loader->load_object) {
            wpe_log_fatal(
                "wpe_load_object: failed to load object with name '%s': backend doesn't implement load_object vfunc",
                object_name);
            abort();
        }
        return s_impl_loader->load_object(object_name);
    }

    void* object = dlsym(s_impl_library, object_name);
    if (!object)
        wpe_log_error("wpe_load_object: failed to load object with name '%s'", object_name);

    return object;
}
