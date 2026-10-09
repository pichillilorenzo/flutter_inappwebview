// Utility to detect if software rendering should be used
// This checks for VM environments where DMA-BUF/GPU acceleration may not work properly

#ifndef DRAGO_INAPPWEBVIEW_LINUX_UTILS_SOFTWARE_RENDERING_H_
#define DRAGO_INAPPWEBVIEW_LINUX_UTILS_SOFTWARE_RENDERING_H_

namespace drago_inappwebview_plugin {

// Check if software rendering should be automatically enabled.
// This detects VM environments (UTM, QEMU, VMware, VirtualBox, etc.) where
// GPU acceleration via DMA-BUF may not work correctly.
//
// Environment variables:
// - LIBGL_ALWAYS_SOFTWARE=1 : Force software rendering (standard WebKit flag)
// - DRAGO_INAPPWEBVIEW_SKIP_DMABUF_CHECK=1 : Skip detection, use hardware
//
// If this returns true, LIBGL_ALWAYS_SOFTWARE=1 should be set BEFORE any
// EGL/GL/WPE initialization to ensure WebKit uses SHM buffers.
bool ShouldUseSoftwareRendering();

// Apply software rendering environment if needed.
// Call this ONCE at plugin initialization, BEFORE any WebView is created.
// Returns true if software rendering was enabled.
bool ApplySoftwareRenderingIfNeeded();

}  // namespace drago_inappwebview_plugin

#endif  // DRAGO_INAPPWEBVIEW_LINUX_UTILS_SOFTWARE_RENDERING_H_
