#pragma once

#include <cstddef>

namespace flutter_inappwebview_plugin {
  // The published slot remains available to the raster thread until the next
  // publish, even after its previous lease has been released.
  template <typename Surfaces>
  size_t FindWritableSurface(const Surfaces& surfaces,
    bool has_published_surface, size_t published_surface)
  {
    for (size_t i = 0; i < surfaces.size(); ++i) {
      if (!surfaces[i].is_leased &&
        (!has_published_surface || i != published_surface)) {
        return i;
      }
    }
    return surfaces.size();
  }
}
