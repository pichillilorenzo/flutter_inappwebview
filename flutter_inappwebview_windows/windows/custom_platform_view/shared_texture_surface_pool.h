#pragma once

#include <d3d11.h>
#include <winrt/base.h>

#include <array>
#include <cstdint>
#include <mutex>
#include <utility>
#include <vector>

namespace flutter_inappwebview_plugin
{
  // The capture producer serializes EnsureTextures/DetachUnusedTextures. The
  // raster thread only leases the published slot under |mutex|. Driver calls
  // (allocation and final Release) must never run while holding this mutex.
  struct SharedTextureSurfacePool {
    struct Surface {
      winrt::com_ptr<ID3D11Texture2D> texture;
      HANDLE shared_handle = nullptr;
      bool is_leased = false;
    };
    struct Dimensions {
      uint32_t width;
      uint32_t height;
    };

    explicit SharedTextureSurfacePool(uint32_t width, uint32_t height)
      : size{ width, height } {}

    std::mutex mutex;
    const Dimensions size;
    std::array<Surface, 2> surfaces;
    size_t published_surface = 0;
    bool has_published_surface = false;

    // Refill empty slots in place: the published frame and outstanding leases
    // remain valid until a new frame is ready, even if allocation fails.
    bool EnsureTextures(ID3D11Device* device)
    {
      D3D11_TEXTURE2D_DESC desc = {};
      desc.ArraySize = 1;
      desc.MipLevels = 1;
      desc.BindFlags = D3D11_BIND_RENDER_TARGET | D3D11_BIND_SHADER_RESOURCE;
      desc.Format = DXGI_FORMAT_B8G8R8A8_UNORM;
      desc.Width = size.width;
      desc.Height = size.height;
      desc.MiscFlags = D3D11_RESOURCE_MISC_SHARED;
      desc.SampleDesc.Count = 1;
      desc.Usage = D3D11_USAGE_DEFAULT;

      for (auto& destination : surfaces) {
        {
          const std::lock_guard<std::mutex> lock(mutex);
          if (destination.texture) {
            continue;
          }
        }
        Surface surface;
        if (FAILED(device->CreateTexture2D(&desc, nullptr,
          surface.texture.put()))) {
          return false;
        }
        auto resource = surface.texture.try_as<IDXGIResource>();
        if (!resource || FAILED(resource->GetSharedHandle(
          &surface.shared_handle)) || !surface.shared_handle) {
          return false;
        }
        const std::lock_guard<std::mutex> lock(mutex);
        destination = std::move(surface);
      }
      return true;
    }

    // Move resources out under the short ownership lock; the caller destroys
    // |retired| after releasing its capture lock as well. Legacy DXGI shared
    // handles are tied to the texture lifetime and must not use CloseHandle.
    bool DetachUnusedTextures(
      std::vector<winrt::com_ptr<ID3D11Texture2D>>& retired)
    {
      retired.reserve(retired.size() + surfaces.size());
      const std::lock_guard<std::mutex> lock(mutex);
      bool retry = false;
      for (size_t i = 0; i < surfaces.size(); ++i) {
        auto& surface = surfaces[i];
        if (has_published_surface && i == published_surface) {
          continue;
        }
        if (surface.is_leased) {
          retry = true;
          continue;
        }
        if (surface.texture) {
          retired.push_back(std::move(surface.texture));
          surface.shared_handle = nullptr;
        }
      }
      return retry;
    }
  };
}
