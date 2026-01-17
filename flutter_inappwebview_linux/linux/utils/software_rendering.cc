// Utility to detect if software rendering should be used
// This checks for VM environments where DMA-BUF/GPU acceleration may not work properly

#include "software_rendering.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <unistd.h>

#include "log.h"

namespace flutter_inappwebview_plugin {

namespace {

// Check if we're running in a virtual machine by reading system files.
// This is a standard approach used by systemd-detect-virt, virt-what, etc.
// These files are readable by any process and contain only hardware ID info.
bool IsRunningInVirtualMachine() {
  // Known VM product name indicators
  const char* vm_indicators[] = {
    "QEMU", "KVM", "VMware", "VirtualBox", "Parallels", "Xen",
    "Microsoft Virtual", "Hyper-V", "UTM", "Virtual Machine",
    "Bochs", "innotek", "Oracle", nullptr
  };
  
  // Check /sys/class/dmi/id/product_name
  FILE* f = fopen("/sys/class/dmi/id/product_name", "r");
  if (f) {
    char buf[256] = {0};
    if (fgets(buf, sizeof(buf), f)) {
      fclose(f);
      for (const char** indicator = vm_indicators; *indicator; indicator++) {
        if (strcasestr(buf, *indicator)) {
          debugLog("VM detected via product_name: " + std::string(buf));
          return true;
        }
      }
    } else {
      fclose(f);
    }
  }
  
  // Check /sys/class/dmi/id/sys_vendor
  f = fopen("/sys/class/dmi/id/sys_vendor", "r");
  if (f) {
    char buf[256] = {0};
    if (fgets(buf, sizeof(buf), f)) {
      fclose(f);
      for (const char** indicator = vm_indicators; *indicator; indicator++) {
        if (strcasestr(buf, *indicator)) {
          debugLog("VM detected via sys_vendor: " + std::string(buf));
          return true;
        }
      }
    } else {
      fclose(f);
    }
  }
  
  // Check /proc/cpuinfo for hypervisor flag (x86/x64)
  f = fopen("/proc/cpuinfo", "r");
  if (f) {
    char line[512];
    while (fgets(line, sizeof(line), f)) {
      if (strstr(line, "flags") && strstr(line, "hypervisor")) {
        fclose(f);
        debugLog("VM detected via hypervisor CPU flag");
        return true;
      }
    }
    fclose(f);
  }
  
  return false;
}

// Check if we have a known good GPU driver that works well with DMA-BUF
bool HasKnownGoodGpuDriver() {
  const char* dri_paths[] = {
    "/sys/class/drm/card0/device/driver",
    "/sys/class/drm/renderD128/device/driver",
    nullptr
  };
  
  // Known good drivers that work well with DMA-BUF
  const char* good_drivers[] = {
    "nvidia",   // Nvidia proprietary driver
    "nouveau",  // Nvidia open-source driver
    "amdgpu",   // AMD GPU driver
    "radeon",   // Older AMD driver
    "i915",     // Intel integrated graphics
    "xe",       // Intel Xe graphics (newer)
    nullptr
  };
  
  for (const char** path = dri_paths; *path; path++) {
    char link_target[256] = {0};
    ssize_t len = readlink(*path, link_target, sizeof(link_target) - 1);
    if (len > 0) {
      link_target[len] = '\0';
      for (const char** driver = good_drivers; *driver; driver++) {
        if (strstr(link_target, *driver)) {
          debugLog("Known good GPU driver detected: " + std::string(link_target));
          return true;
        }
      }
    }
  }
  
  return false;
}

// Check if the GPU driver is known to have DMA-BUF issues
bool HasProblematicGpuDriver() {
  // If we have a known good driver, it's not problematic
  if (HasKnownGoodGpuDriver()) {
    return false;
  }
  
  const char* dri_paths[] = {
    "/sys/class/drm/card0/device/driver",
    "/sys/class/drm/renderD128/device/driver",
    nullptr
  };
  
  for (const char** path = dri_paths; *path; path++) {
    char link_target[256] = {0};
    ssize_t len = readlink(*path, link_target, sizeof(link_target) - 1);
    if (len > 0) {
      link_target[len] = '\0';
      // virtio-gpu and vmwgfx have known issues in VMs
      if (strstr(link_target, "virtio") || strstr(link_target, "vmwgfx")) {
        debugLog("Problematic GPU driver detected: " + std::string(link_target));
        return true;
      }
    }
  }
  
  return false;
}

}  // namespace

bool ShouldUseSoftwareRendering() {
  // Check user override: skip detection
  const char* skip_check = getenv("FLUTTER_INAPPWEBVIEW_SKIP_DMABUF_CHECK");
  if (skip_check && (strcmp(skip_check, "1") == 0 || strcasecmp(skip_check, "true") == 0)) {
    return false;
  }
  
  // Already set by user or another component
  const char* already_sw = getenv("LIBGL_ALWAYS_SOFTWARE");
  if (already_sw && (strcmp(already_sw, "1") == 0 || strcasecmp(already_sw, "true") == 0)) {
    return true;  // Already in software mode
  }
  
  // If we have a known good GPU driver, use hardware rendering
  if (HasKnownGoodGpuDriver()) {
    debugLog("Known good GPU driver found, using hardware rendering");
    return false;
  }

  const bool in_vm = IsRunningInVirtualMachine();
  
  // Detect VM environment
  if (in_vm) {
    return true;
  }
  
  // Detect problematic GPU drivers only inside a VM
  if (in_vm && HasProblematicGpuDriver()) {
    return true;
  }
  
  return false;
}

bool ApplySoftwareRenderingIfNeeded() {
  // Already set - nothing to do
  const char* already_sw = getenv("LIBGL_ALWAYS_SOFTWARE");
  if (already_sw && (strcmp(already_sw, "1") == 0 || strcasecmp(already_sw, "true") == 0)) {
    debugLog("Software rendering already enabled (LIBGL_ALWAYS_SOFTWARE set)");
    return true;
  }
  
  if (ShouldUseSoftwareRendering()) {
    // Set BEFORE any EGL/GL initialization
    setenv("LIBGL_ALWAYS_SOFTWARE", "1", 0);  // Don't override if already set
    debugLog("Auto-enabled software rendering for VM/problematic GPU environment");
    return true;
  }
  
  debugLog("Using hardware GPU rendering");
  return false;
}

}  // namespace flutter_inappwebview_plugin
