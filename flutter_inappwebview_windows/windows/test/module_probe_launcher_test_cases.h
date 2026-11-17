#pragma once

#include <windows.h>
#include <gtest/gtest.h>
#include <string>

namespace flutter_inappwebview_plugin::test::module_probe_launcher_test {

inline void dllLifetime() {
  wchar_t executable[MAX_PATH] = {};
  ASSERT_NE(GetModuleFileNameW(nullptr, executable, MAX_PATH), 0u);
  const std::wstring path = std::wstring(executable).substr(
    0, std::wstring(executable).find_last_of(L"\\/") + 1) + L"probe_fixture.dll";
  const auto module = LoadLibraryW(path.c_str());
  ASSERT_NE(module, nullptr);
  const auto started = CreateEventW(nullptr, TRUE, FALSE, nullptr);
  const auto release = CreateEventW(nullptr, TRUE, FALSE, nullptr);
  const auto unloaded = CreateEventW(nullptr, TRUE, FALSE, nullptr);
  using Start = BOOL (*)(HANDLE, HANDLE, HANDLE);
  const auto start = reinterpret_cast<Start>(GetProcAddress(module, "StartProbe"));
  EXPECT_NE(start, nullptr);
  const bool launched = start && start(started, release, unloaded);
  EXPECT_TRUE(launched);
  if (launched) {
    EXPECT_EQ(WaitForSingleObject(started, 5000), WAIT_OBJECT_0);
    FreeLibrary(module);
    // The callback is blocked, and must still hold the fixture in memory.
    EXPECT_EQ(WaitForSingleObject(unloaded, 0), WAIT_TIMEOUT);
    SetEvent(release);
    ASSERT_EQ(WaitForSingleObject(unloaded, 5000), WAIT_OBJECT_0);
  }
  else {
    FreeLibrary(module);
  }
  CloseHandle(unloaded);
  CloseHandle(release);
  CloseHandle(started);
}

}  // namespace flutter_inappwebview_plugin::test::module_probe_launcher_test
