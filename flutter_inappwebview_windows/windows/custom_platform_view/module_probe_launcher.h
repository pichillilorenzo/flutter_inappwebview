#pragma once

#include <windows.h>
#include <functional>
#include <memory>
#include <utility>

namespace flutter_inappwebview_plugin {

// Retain the callback's DLL while queued and running, even if the engine goes
// away. The pool releases the reference only AFTER our callback and all its C++
// destructors return; releasing it inside a std::thread would race DLL unload.
struct ModuleProbeLauncher {
  bool operator()(std::function<void()> work) const {
    auto pending = std::make_unique<Pending>();
    pending->work = std::move(work);
    if (!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS,
      reinterpret_cast<LPCWSTR>(&Run), &pending->module)) {
      return false;
    }
    // Transfer ownership before submission: the callback may run immediately.
    auto* context = pending.release();
    if (!TrySubmitThreadpoolCallback(&Run, context, nullptr)) {
      FreeLibrary(context->module);
      delete context;
      return false;
    }
    return true;
  }

 private:
  struct Pending {
    HMODULE module = nullptr;
    std::function<void()> work;
  };

  static void CALLBACK Run(PTP_CALLBACK_INSTANCE instance, void* context) {
    std::unique_ptr<Pending> pending(static_cast<Pending*>(context));
    FreeLibraryWhenCallbackReturns(instance, pending->module);
    CallbackMayRunLong(instance);
    pending->work();
  }
};

}  // namespace flutter_inappwebview_plugin
