#include <windows.h>
#include "../custom_platform_view/module_probe_launcher.h"

namespace {
HANDLE unloadedEvent = nullptr;
}

// This DLL is deliberately independent of the plugin and Flutter: dropping the
// host's last LoadLibrary reference must not unload a queued/running callback.
extern "C" __declspec(dllexport) BOOL StartProbe(
  HANDLE started, HANDLE release, HANDLE unloaded) {
  unloadedEvent = unloaded;
  return flutter_inappwebview_plugin::ModuleProbeLauncher{}([=]() {
    SetEvent(started);
    WaitForSingleObject(release, 10000);
  });
}

BOOL WINAPI DllMain(HINSTANCE, DWORD reason, LPVOID) {
  if (reason == DLL_PROCESS_DETACH && unloadedEvent) {
    SetEvent(unloadedEvent);
  }
  return TRUE;
}
