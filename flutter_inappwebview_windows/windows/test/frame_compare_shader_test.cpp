#include <d3d11.h>
#include <wrl/client.h>
#include <gtest/gtest.h>

#include <cstdint>
#include <utility>
#include <vector>

#include "custom_platform_view/frame_compare_cs.h"

namespace flutter_inappwebview_plugin::test {
namespace {

using Microsoft::WRL::ComPtr;

class FrameCompareShaderTest
    : public testing::TestWithParam<std::pair<UINT, UINT>> {
 protected:
  void SetUp() override {
    const D3D_FEATURE_LEVEL levels[] = {D3D_FEATURE_LEVEL_11_0};
    // WARP exercises the real bytecode without depending on a CI runner GPU.
    ASSERT_EQ(S_OK, D3D11CreateDevice(nullptr, D3D_DRIVER_TYPE_WARP, nullptr,
        D3D11_CREATE_DEVICE_BGRA_SUPPORT, levels, 1, D3D11_SDK_VERSION,
        device_.GetAddressOf(), nullptr, context_.GetAddressOf()));
    ASSERT_EQ(S_OK, device_->CreateComputeShader(kFrameCompareCs,
        sizeof(kFrameCompareCs), nullptr, shader_.GetAddressOf()));

    D3D11_TEXTURE2D_DESC texture_desc = {};
    texture_desc.Width = GetParam().first;
    texture_desc.Height = GetParam().second;
    texture_desc.MipLevels = 1;
    texture_desc.ArraySize = 1;
    texture_desc.Format = DXGI_FORMAT_B8G8R8A8_UNORM;
    texture_desc.SampleDesc.Count = 1;
    texture_desc.Usage = D3D11_USAGE_DEFAULT;
    texture_desc.BindFlags = D3D11_BIND_SHADER_RESOURCE;
    for (int i = 0; i < 2; ++i) {
      ASSERT_EQ(S_OK, device_->CreateTexture2D(&texture_desc, nullptr,
          textures_[i].GetAddressOf()));
      ASSERT_EQ(S_OK, device_->CreateShaderResourceView(textures_[i].Get(),
          nullptr, views_[i].GetAddressOf()));
    }

    D3D11_BUFFER_DESC buffer_desc = {};
    buffer_desc.ByteWidth = 16;
    buffer_desc.Usage = D3D11_USAGE_DEFAULT;
    buffer_desc.BindFlags = D3D11_BIND_UNORDERED_ACCESS;
    buffer_desc.MiscFlags = D3D11_RESOURCE_MISC_BUFFER_ALLOW_RAW_VIEWS;
    ASSERT_EQ(S_OK, device_->CreateBuffer(&buffer_desc, nullptr,
        result_.GetAddressOf()));
    D3D11_UNORDERED_ACCESS_VIEW_DESC uav_desc = {};
    uav_desc.Format = DXGI_FORMAT_R32_TYPELESS;
    uav_desc.ViewDimension = D3D11_UAV_DIMENSION_BUFFER;
    uav_desc.Buffer.NumElements = 4;
    uav_desc.Buffer.Flags = D3D11_BUFFER_UAV_FLAG_RAW;
    ASSERT_EQ(S_OK, device_->CreateUnorderedAccessView(result_.Get(),
        &uav_desc, result_view_.GetAddressOf()));
    buffer_desc.Usage = D3D11_USAGE_STAGING;
    buffer_desc.BindFlags = 0;
    buffer_desc.MiscFlags = 0;
    buffer_desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    ASSERT_EQ(S_OK, device_->CreateBuffer(&buffer_desc, nullptr,
        staging_.GetAddressOf()));
  }

  void ExpectComparison(const std::vector<uint32_t>& a,
      const std::vector<uint32_t>& b, bool expected_difference) {
    const UINT width = GetParam().first;
    const UINT height = GetParam().second;
    const UINT row_pitch = width * static_cast<UINT>(sizeof(uint32_t));
    ASSERT_EQ(static_cast<size_t>(width) * height, a.size());
    ASSERT_EQ(a.size(), b.size());
    context_->UpdateSubresource(textures_[0].Get(), 0, nullptr, a.data(),
        row_pitch, 0);
    context_->UpdateSubresource(textures_[1].Get(), 0, nullptr, b.data(),
        row_pitch, 0);
    const UINT zeros[4] = {};
    context_->ClearUnorderedAccessViewUint(result_view_.Get(), zeros);
    ID3D11ShaderResourceView* views[] = {views_[0].Get(), views_[1].Get()};
    ID3D11UnorderedAccessView* uavs[] = {result_view_.Get()};
    context_->CSSetShader(shader_.Get(), nullptr, 0);
    context_->CSSetShaderResources(0, 2, views);
    context_->CSSetUnorderedAccessViews(0, 1, uavs, nullptr);
    context_->Dispatch((width + 15) / 16, (height + 15) / 16, 1);
    ID3D11ShaderResourceView* no_views[2] = {};
    ID3D11UnorderedAccessView* no_uavs[1] = {};
    context_->CSSetShaderResources(0, 2, no_views);
    context_->CSSetUnorderedAccessViews(0, 1, no_uavs, nullptr);
    context_->CSSetShader(nullptr, nullptr, 0);
    context_->CopyResource(staging_.Get(), result_.Get());
    // Blocking readback is deliberate in this correctness test.
    D3D11_MAPPED_SUBRESOURCE mapped = {};
    ASSERT_EQ(S_OK, context_->Map(staging_.Get(), 0, D3D11_MAP_READ, 0, &mapped));
    const uint32_t actual = *static_cast<const uint32_t*>(mapped.pData);
    context_->Unmap(staging_.Get(), 0);
    EXPECT_EQ(expected_difference ? 1u : 0u, actual);
  }

  ComPtr<ID3D11Device> device_;
  ComPtr<ID3D11DeviceContext> context_;
  ComPtr<ID3D11ComputeShader> shader_;
  ComPtr<ID3D11Texture2D> textures_[2];
  ComPtr<ID3D11ShaderResourceView> views_[2];
  ComPtr<ID3D11Buffer> result_;
  ComPtr<ID3D11UnorderedAccessView> result_view_;
  ComPtr<ID3D11Buffer> staging_;
};

TEST_P(FrameCompareShaderTest, DetectsExactChangesAndClearsPreviousResults) {
  const size_t count = static_cast<size_t>(GetParam().first) * GetParam().second;
  std::vector<uint32_t> reference(count);
  for (size_t i = 0; i < count; ++i) {
    reference[i] = static_cast<uint32_t>(i * 2654435761u);
  }
  ExpectComparison(reference, reference, false);
  auto changed = reference;
  changed.front() ^= 1u;
  ExpectComparison(reference, changed, true);
  for (UINT channel = 0; channel < 4; ++channel) {
    SCOPED_TRACE(channel);
    // An equal comparison after a changed one must clear the previous result.
    ExpectComparison(reference, reference, false);
    changed = reference;
    changed.back() ^= 1u << (channel * 8);
    ExpectComparison(reference, changed, true);
  }
  ExpectComparison(reference, reference, false);
  // Many shader invocations writing the difference flag must still yield 1.
  changed = reference;
  for (auto& pixel : changed) {
    pixel ^= 0xffffffffu;
  }
  ExpectComparison(reference, changed, true);
}

INSTANTIATE_TEST_SUITE_P(TextureSizes, FrameCompareShaderTest,
    testing::Values(std::make_pair(1u, 1u), std::make_pair(16u, 16u),
        std::make_pair(17u, 19u), std::make_pair(31u, 33u)));

}  // namespace
}  // namespace flutter_inappwebview_plugin::test
