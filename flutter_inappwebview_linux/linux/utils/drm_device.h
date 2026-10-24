// Utility to pin WPE WebKit to the same GPU Flutter renders with.
//
// WPE exports its frames as DMA-BUFs that are imported into Flutter's GL
// context. That import only works when both sides live on the same DRM device,
// but WPE picks its device on its own (the first one libdrm reports), which on
// hybrid setups is rarely the one Flutter uses - the webview then renders black.

#ifndef FLUTTER_INAPPWEBVIEW_LINUX_UTILS_DRM_DEVICE_H_
#define FLUTTER_INAPPWEBVIEW_LINUX_UTILS_DRM_DEVICE_H_

namespace flutter_inappwebview_plugin {

// Resolves the DRM device backing the EGL display Flutter renders with and
// exports it as WPE_DRM_DEVICE.
// Call this ONCE at plugin registration, BEFORE any WPEDisplay is created.
// An already set WPE_DRM_DEVICE is never overridden.
// Returns true if the variable was set.
bool ApplyWpeDrmDeviceIfNeeded();

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_LINUX_UTILS_DRM_DEVICE_H_
