#include <d3d11.h>
#include <gtest/gtest.h>

#include <memory>
#include <chrono>
#include <iostream>
#include <thread>
#include <vector>

#include "custom_platform_view/shared_texture_surface_pool.h"
#include "custom_platform_view/surface_pool_slot.h"

namespace flutter_inappwebview_plugin::test {
namespace {

class SharedTextureSurfacePoolTest : public testing::Test {
 protected:
  void SetUp() override {
    const D3D_FEATURE_LEVEL levels[] = {D3D_FEATURE_LEVEL_11_0};
    // Exercise production D3D allocation and real shared handles on software
    // Direct3D. This is a correctness test, not a device GPU-memory benchmark.
    ASSERT_EQ(S_OK, D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr,
      D3D11_CREATE_DEVICE_BGRA_SUPPORT, levels, 1, D3D11_SDK_VERSION,
      device_.put(), nullptr, context_.put()));
    ASSERT_EQ(S_OK, D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr,
      D3D11_CREATE_DEVICE_BGRA_SUPPORT, levels, 1, D3D11_SDK_VERSION,
      consumer_device_.put(), nullptr, consumer_context_.put()));
  }

  static size_t RetainedTextureCount(const SharedTextureSurfacePool& pool) {
    size_t count = 0;
    for (const auto& surface : pool.surfaces) {
      if (surface.texture) ++count;
    }
    return count;
  }

  void WriteFrame(ID3D11Texture2D* texture, uint32_t pixel) {
    D3D11_TEXTURE2D_DESC desc;
    texture->GetDesc(&desc);
    const std::vector<uint32_t> pixels(
      static_cast<size_t>(desc.Width) * desc.Height, pixel);
    context_->UpdateSubresource(texture, 0, nullptr, pixels.data(),
      desc.Width * static_cast<UINT>(sizeof(uint32_t)), 0);
    D3D11_QUERY_DESC query_desc = {};
    query_desc.Query = D3D11_QUERY_EVENT;
    winrt::com_ptr<ID3D11Query> finished;
    ASSERT_EQ(S_OK, device_->CreateQuery(&query_desc, finished.put()));
    context_->End(finished.get());
    context_->Flush();
    const auto deadline = std::chrono::steady_clock::now() +
      std::chrono::seconds(5);
    HRESULT ready;
    while ((ready = context_->GetData(finished.get(), nullptr, 0, 0)) == S_FALSE
      && std::chrono::steady_clock::now() < deadline) {
      std::this_thread::yield();
    }
    ASSERT_EQ(S_OK, ready);
  }

  void ExpectConsumerFrame(ID3D11Texture2D* texture, uint32_t pixel) {
    D3D11_TEXTURE2D_DESC desc;
    texture->GetDesc(&desc);
    desc.Usage = D3D11_USAGE_STAGING;
    desc.BindFlags = 0;
    desc.MiscFlags = 0;
    desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    winrt::com_ptr<ID3D11Texture2D> staging;
    ASSERT_EQ(S_OK, consumer_device_->CreateTexture2D(&desc, nullptr,
      staging.put()));
    consumer_context_->CopyResource(staging.get(), texture);
    D3D11_MAPPED_SUBRESOURCE mapped = {};
    ASSERT_EQ(S_OK, consumer_context_->Map(staging.get(), 0, D3D11_MAP_READ,
      0, &mapped));
    EXPECT_EQ(pixel, *static_cast<const uint32_t*>(mapped.pData));
    consumer_context_->Unmap(staging.get(), 0);
  }

  winrt::com_ptr<ID3D11Device> device_;
  winrt::com_ptr<ID3D11DeviceContext> context_;
  winrt::com_ptr<ID3D11Device> consumer_device_;
  winrt::com_ptr<ID3D11DeviceContext> consumer_context_;
};

TEST_F(SharedTextureSurfacePoolTest, DetachesOnlyTheUnpublishedSpare) {
  SharedTextureSurfacePool pool(4096, 2048);
  ASSERT_TRUE(pool.EnsureTextures(device_.get()));
  ASSERT_EQ(2u, RetainedTextureCount(pool));
  for (const auto& surface : pool.surfaces) {
    D3D11_TEXTURE2D_DESC desc;
    surface.texture->GetDesc(&desc);
    EXPECT_EQ(4096u, desc.Width);
    EXPECT_EQ(2048u, desc.Height);
    EXPECT_EQ(DXGI_FORMAT_B8G8R8A8_UNORM, desc.Format);
    EXPECT_NE(nullptr, surface.shared_handle);
  }
  pool.published_surface = 0;
  pool.has_published_surface = true;
  const auto published_handle = pool.surfaces[0].shared_handle;
  std::vector<winrt::com_ptr<ID3D11Texture2D>> retired;
  EXPECT_FALSE(pool.DetachUnusedTextures(retired));
  ASSERT_EQ(1u, retired.size());
  EXPECT_EQ(1u, RetainedTextureCount(pool));
  EXPECT_EQ(published_handle, pool.surfaces[0].shared_handle);
  EXPECT_EQ(nullptr, pool.surfaces[1].shared_handle);
  EXPECT_TRUE(pool.has_published_surface);
  EXPECT_EQ(0u, pool.published_surface);
  // The caller can release resources without holding the raster ownership lock.
  ASSERT_TRUE(pool.mutex.try_lock());
  pool.mutex.unlock();
  retired.clear();
  EXPECT_FALSE(pool.DetachUnusedTextures(retired));
  EXPECT_TRUE(retired.empty());
  // Logical bytes retained by the bridge: 2 * 4096 * 2048 * 4 -> 1 * same.
  // This does not estimate driver allocations or resources retained by Flutter.
  EXPECT_EQ(32u * 1024u * 1024u,
    RetainedTextureCount(pool) * pool.size.width * pool.size.height * 4u);
  std::cout << "{\"backend\":\"d3d11-warp-pool-test\",\"width\":4096,"
    "\"height\":2048,\"retainedSurfacesBefore\":2,\"retainedSurfacesAfter\":"
    << RetainedTextureCount(pool)
    << ",\"logicalBytesBefore\":67108864,\"logicalBytesAfter\":33554432,"
    "\"physicalGpuMemoryMeasured\":false}\n";
}

TEST_F(SharedTextureSurfacePoolTest, LeasedSpareSurvivesUntilConsumerOpensIt) {
  auto pool = std::make_shared<SharedTextureSurfacePool>(4, 3);
  ASSERT_TRUE(pool->EnsureTextures(device_.get()));
  WriteFrame(pool->surfaces[0].texture.get(), 0xff13579bu);
  const auto leased_handle = pool->surfaces[0].shared_handle;
  pool->surfaces[0].is_leased = true;
  pool->has_published_surface = true;
  pool->published_surface = 1;
  std::vector<winrt::com_ptr<ID3D11Texture2D>> retired;
  EXPECT_TRUE(pool->DetachUnusedTextures(retired));
  EXPECT_TRUE(retired.empty());
  EXPECT_EQ(2u, RetainedTextureCount(*pool));
  // The consumer has not opened the raw handle at the time of the trim.
  winrt::com_ptr<ID3D11Texture2D> consumer_texture;
  ASSERT_EQ(S_OK, consumer_device_->OpenSharedResource(leased_handle,
    __uuidof(ID3D11Texture2D), consumer_texture.put_void()));
  pool->surfaces[0].is_leased = false; // Flutter's release callback.
  EXPECT_FALSE(pool->DetachUnusedTextures(retired));
  ASSERT_EQ(1u, retired.size());
  retired.clear();
  EXPECT_EQ(1u, RetainedTextureCount(*pool));
  ExpectConsumerFrame(consumer_texture.get(), 0xff13579bu);
  pool.reset(); // A consumer that opened its resource owns it independently.
  ExpectConsumerFrame(consumer_texture.get(), 0xff13579bu);
}

TEST_F(SharedTextureSurfacePoolTest, RefillPreservesThePublishedFrameAndHandle) {
  SharedTextureSurfacePool pool(4, 3);
  ASSERT_TRUE(pool.EnsureTextures(device_.get()));
  pool.has_published_surface = true;
  pool.published_surface = 0;
  WriteFrame(pool.surfaces[0].texture.get(), 0xffabcdefu);
  const auto last_handle = pool.surfaces[0].shared_handle;
  std::vector<winrt::com_ptr<ID3D11Texture2D>> retired;
  EXPECT_FALSE(pool.DetachUnusedTextures(retired));
  retired.clear();
  ASSERT_TRUE(pool.EnsureTextures(device_.get()));
  EXPECT_EQ(2u, RetainedTextureCount(pool));
  EXPECT_EQ(last_handle, pool.surfaces[0].shared_handle);
  EXPECT_EQ(1u, FindWritableSurface(pool.surfaces,
    pool.has_published_surface, pool.published_surface));
  winrt::com_ptr<ID3D11Texture2D> old_frame;
  ASSERT_EQ(S_OK, consumer_device_->OpenSharedResource(last_handle,
    __uuidof(ID3D11Texture2D), old_frame.put_void()));
  ExpectConsumerFrame(old_frame.get(), 0xffabcdefu);
  const auto spare_handle = pool.surfaces[1].shared_handle;
  ASSERT_TRUE(pool.EnsureTextures(device_.get()));
  EXPECT_EQ(spare_handle, pool.surfaces[1].shared_handle);
}

TEST_F(SharedTextureSurfacePoolTest, ResizeAndDisposePreserveOutstandingLease) {
  auto pool = std::make_shared<SharedTextureSurfacePool>(4, 3);
  ASSERT_TRUE(pool->EnsureTextures(device_.get()));
  pool->has_published_surface = true;
  pool->surfaces[0].is_leased = true;
  WriteFrame(pool->surfaces[0].texture.get(), 0xff765432u);
  const auto old_handle = pool->surfaces[0].shared_handle;
  auto outstanding_lease = pool; // The production FrameLease retains this pool.
  std::weak_ptr<SharedTextureSurfacePool> old_pool = pool;
  auto resized_pool = std::make_shared<SharedTextureSurfacePool>(19, 17);
  ASSERT_TRUE(resized_pool->EnsureTextures(device_.get()));
  pool = resized_pool;
  EXPECT_EQ(19u, pool->size.width);
  EXPECT_EQ(17u, pool->size.height);
  EXPECT_FALSE(old_pool.expired());
  pool.reset();
  resized_pool.reset();
  winrt::com_ptr<ID3D11Texture2D> consumer_texture;
  ASSERT_EQ(S_OK, consumer_device_->OpenSharedResource(old_handle,
    __uuidof(ID3D11Texture2D), consumer_texture.put_void()));
  outstanding_lease->surfaces[0].is_leased = false;
  outstanding_lease.reset();
  EXPECT_TRUE(old_pool.expired());
  ExpectConsumerFrame(consumer_texture.get(), 0xff765432u);
}

} // namespace
} // namespace flutter_inappwebview_plugin::test
