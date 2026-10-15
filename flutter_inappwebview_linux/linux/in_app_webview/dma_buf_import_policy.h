#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_DMA_BUF_IMPORT_POLICY_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_DMA_BUF_IMPORT_POLICY_H_

#include <atomic>

namespace flutter_inappwebview_plugin {

enum class DmaBufImportAction {
  // Create the EGL image in WPE's display for consumers such as InAppBrowser.
  kImportInWpe,
  // Keep the buffer alive and let Flutter import it in its current display.
  kDeferToFlutter,
  // Use the existing CPU pixel conversion path.
  kImportPixels,
};

constexpr bool IsEligibleDmaBufFrame(bool has_current_buffer,
                                     bool current_buffer_is_dma_buf,
                                     bool* out_is_dma_buf_frame) {
  if (!has_current_buffer || !current_buffer_is_dma_buf) {
    return false;
  }
  if (out_is_dma_buf_frame) {
    *out_is_dma_buf_frame = true;
  }
  return true;
}

constexpr DmaBufImportAction DecideDmaBufImportAction(
    bool inline_flutter_consumer, bool skip_pixel_readback,
    bool wpe_import_failed) {
  if (inline_flutter_consumer && skip_pixel_readback) {
    return DmaBufImportAction::kDeferToFlutter;
  }
  if (!inline_flutter_consumer && skip_pixel_readback && !wpe_import_failed) {
    return DmaBufImportAction::kImportInWpe;
  }
  return DmaBufImportAction::kImportPixels;
}

// Shared decision state for the inline Flutter consumer. Only an actual failed
// import of a DMA-BUF frame moves the consumer into pixel fallback mode.
class InlineDmaBufImportState {
 public:
  void SetEnabled(bool enabled) {
    enabled_.store(enabled, std::memory_order_release);
    fallback_.store(false, std::memory_order_release);
  }

  bool ShouldAttemptImport() const {
    return enabled_.load(std::memory_order_acquire) &&
           !fallback_.load(std::memory_order_acquire);
  }

  bool ReportFailedImport(bool current_frame_is_dma_buf) {
    if (!current_frame_is_dma_buf ||
        !enabled_.load(std::memory_order_acquire)) {
      return false;
    }
    bool expected = false;
    return fallback_.compare_exchange_strong(expected, true,
                                             std::memory_order_acq_rel);
  }

  bool IsFallbackActive() const {
    return fallback_.load(std::memory_order_acquire);
  }

 private:
  std::atomic<bool> enabled_{false};
  std::atomic<bool> fallback_{false};
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_DMA_BUF_IMPORT_POLICY_H_
