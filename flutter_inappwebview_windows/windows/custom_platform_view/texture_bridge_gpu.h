#pragma once

#include <d3d11.h>
#include <flutter/texture_registrar.h>

#include "texture_bridge.h"

namespace flutter_inappwebview_plugin
{
  // Feeds captured WebView frames to Flutter as a DXGI shared texture.
  //
  // Windows.Graphics.Capture produces a frame on every compositor tick for a
  // captured visual, whether or not its content changed. Forwarding each one
  // made Flutter re-rasterize at the display refresh rate for as long as a
  // WebView was on screen. This bridge therefore compares every incoming frame
  // with the frame Flutter already has (a small compute shader, no CPU
  // readback of pixels) and only copies + notifies when at least one pixel
  // differs. Flutter then renders only when the page actually repainted.
  class TextureBridgeGpu : public TextureBridge {
  public:
    TextureBridgeGpu(GraphicsContext* graphics_context,
      ABI::Windows::UI::Composition::IVisual* visual);

    // Called by Flutter on its raster thread. |surface_| already holds the
    // latest accepted frame, so no copy happens here.
    const FlutterDesktopGpuSurfaceDescriptor* GetSurfaceDescriptor(size_t width,
      size_t height);

  protected:
    void StopInternal() override;
    bool AcceptFrame(const winrt::com_ptr<ID3D11Texture2D>& frame) override;

  private:
    FlutterDesktopGpuSurfaceDescriptor surface_descriptor_ = {};
    Size surface_size_ = { 0, 0 };
    // The texture Flutter samples (shared handle). Only written for frames
    // that differ from its current content.
    winrt::com_ptr<ID3D11Texture2D> surface_{ nullptr };
    winrt::com_ptr<IDXGIResource> dxgi_surface_;
    // Our own copy of the incoming frame: the capture pool's textures may not
    // be bindable as shader resources, and copying releases the pool buffer
    // early.
    winrt::com_ptr<ID3D11Texture2D> incoming_{ nullptr };
    Size incoming_size_ = { 0, 0 };
    // Compare pass. Null when the compute shader could not be built; every
    // frame is then treated as changed (the previous behaviour).
    winrt::com_ptr<ID3D11ComputeShader> compare_shader_;
    winrt::com_ptr<ID3D11Buffer> compare_result_;
    winrt::com_ptr<ID3D11UnorderedAccessView> compare_result_uav_;
    winrt::com_ptr<ID3D11Buffer> compare_staging_;

    // Returns true when |surface_| was (re)created for this size.
    bool EnsureSurface(uint32_t width, uint32_t height);
    bool EnsureIncoming(uint32_t width, uint32_t height);
    bool InitComparer();
    // GPU compare of two same-sized B8G8R8A8 textures. Returns true when any
    // pixel differs, and also when the compare itself could not run.
    bool FramesDiffer(ID3D11Texture2D* a, ID3D11Texture2D* b, uint32_t width,
      uint32_t height);
  };
}
