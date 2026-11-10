// Writes 1 into a raw buffer if any pixel of |a| differs from |b|. Both
// textures are B8G8R8A8_UNORM of the same size; unorm loads of equal bytes
// yield equal floats, so the comparison is exact.
//
// Regenerate from the package directory with Windows SDK 10.0.26100.0:
//   ./tool/update_frame_compare_shader.ps1
// Verify the checked-in bytecode without changing it:
//   ./tool/update_frame_compare_shader.ps1 -Check
Texture2D<float4> a : register(t0);
Texture2D<float4> b : register(t1);
RWByteAddressBuffer result : register(u0);

[numthreads(16, 16, 1)]
void main(uint3 id : SV_DispatchThreadID) {
  uint width, height;
  a.GetDimensions(width, height);
  if (id.x >= width || id.y >= height) {
    return;
  }
  if (any(a.Load(int3(id.xy, 0)) != b.Load(int3(id.xy, 0)))) {
    result.Store(0, 1u);
  }
}
