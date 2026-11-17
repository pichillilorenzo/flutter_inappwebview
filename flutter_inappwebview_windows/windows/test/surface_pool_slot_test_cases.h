#pragma once

#include "../custom_platform_view/surface_pool_slot.h"

#include <array>
#include <condition_variable>
#include <memory>
#include <mutex>
#include <stdexcept>
#include <thread>

namespace flutter_inappwebview_plugin::test {
inline void RequireSurfaceSlot(bool condition) {
  if (!condition) throw std::runtime_error("Surface slot ownership violated");
}

inline void RunSurfacePoolSlotTests() {
  struct Surface { bool is_leased = false; int value = 0; };
  std::array<Surface, 2> surfaces;
  RequireSurfaceSlot(FindWritableSurface(surfaces, false, 0) == 0);
  surfaces[0].is_leased = true;
  RequireSurfaceSlot(FindWritableSurface(surfaces, false, 0) == 1);
  surfaces[1].is_leased = true;
  RequireSurfaceSlot(FindWritableSurface(surfaces, false, 0) == surfaces.size());
  surfaces[0].is_leased = surfaces[1].is_leased = false;

  std::mutex mutex;
  std::condition_variable ready;
  bool selected = false;
  bool leased = false;
  bool wrote_leased_surface = false;
  size_t published = 0;
  surfaces[0].value = 10;
  std::thread capture([&] {
    std::unique_lock<std::mutex> lock(mutex);
    const auto writable = FindWritableSurface(surfaces, true, published);
    selected = true;
    ready.notify_one();
    ready.wait(lock, [&] { return leased; });
    // Raster leased the published frame after capture selected its target.
    wrote_leased_surface = surfaces[writable].is_leased;
    surfaces[writable].value = 20;
    published = writable;
  });
  {
    std::unique_lock<std::mutex> lock(mutex);
    ready.wait(lock, [&] { return selected; });
    surfaces[published].is_leased = true;
    leased = true;
    ready.notify_one();
  }
  capture.join();
  RequireSurfaceSlot(!wrote_leased_surface);
  RequireSurfaceSlot(surfaces[0].value == 10);
  RequireSurfaceSlot(published == 1);
  // Keep the last frame published when the other slot is still leased.
  RequireSurfaceSlot(FindWritableSurface(surfaces, true, published) == surfaces.size());
  surfaces[0].is_leased = false;
  RequireSurfaceSlot(FindWritableSurface(surfaces, true, published) == 0);
  // An unchanged frame keeps its published slot and remains leaseable while
  // capture prepares the other slot. Resize starts a separate pool.
  RequireSurfaceSlot(FindWritableSurface(surfaces, true, published) == 0);
  surfaces[published].is_leased = true;
  RequireSurfaceSlot(FindWritableSurface(surfaces, true, published) == 0);
  auto old_pool = std::make_shared<std::array<Surface, 2>>(surfaces);
  auto retained_lease = old_pool;
  auto resized_pool = std::make_shared<std::array<Surface, 2>>();
  old_pool.reset();
  RequireSurfaceSlot((*retained_lease)[published].is_leased);
  RequireSurfaceSlot(FindWritableSurface(*resized_pool, false, 0) == 0);
  (*retained_lease)[published].is_leased = false;
  RequireSurfaceSlot(!(*resized_pool)[published].is_leased);
}
}
