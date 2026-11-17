#include "../in_app_webview/dma_buf_import_policy.h"

#include <cassert>

using flutter_inappwebview_plugin::DecideDmaBufImportAction;
using flutter_inappwebview_plugin::DmaBufImportAction;
using flutter_inappwebview_plugin::InlineDmaBufImportState;

int main() {
  // Inline zero-copy holds the DMA-BUF for Flutter without making an unused
  // WPE-display EGL image, while pixel readback remains disabled.
  assert(DecideDmaBufImportAction(true, true, false) ==
         DmaBufImportAction::kDeferToFlutter);
  assert(DecideDmaBufImportAction(true, true, true) ==
         DmaBufImportAction::kDeferToFlutter);

  // A failed Flutter import switches subsequent frames to the existing pixel
  // fallback. Explicitly disabled zero-copy does the same from frame one.
  assert(DecideDmaBufImportAction(true, false, false) ==
         DmaBufImportAction::kImportPixels);
  assert(DecideDmaBufImportAction(true, false, true) ==
         DmaBufImportAction::kImportPixels);

  // Non-inline consumers retain the WPE EGL image path used by InAppBrowser.
  assert(DecideDmaBufImportAction(false, true, false) ==
         DmaBufImportAction::kImportInWpe);
  assert(DecideDmaBufImportAction(false, true, true) ==
         DmaBufImportAction::kImportPixels);
  assert(DecideDmaBufImportAction(false, false, false) ==
         DmaBufImportAction::kImportPixels);

  // Absence of a frame and SHM frames do not poison zero-copy eligibility.
  InlineDmaBufImportState state;
  state.SetEnabled(true);
  assert(state.ShouldAttemptImport());
  assert(!state.ReportFailedImport(false));  // no frame
  assert(state.ShouldAttemptImport());
  assert(!state.ReportFailedImport(false));  // SHM frame
  assert(state.ShouldAttemptImport());

  // A failed DMA-BUF import switches the coordinated consumer to pixels once.
  assert(state.ReportFailedImport(true));
  assert(state.IsFallbackActive());
  assert(!state.ShouldAttemptImport());
  assert(!state.ReportFailedImport(true));

  // Explicit disable starts directly in pixel mode without attempting EGL.
  InlineDmaBufImportState disabled_state;
  disabled_state.SetEnabled(false);
  assert(!disabled_state.ShouldAttemptImport());
  assert(!disabled_state.ReportFailedImport(true));
  assert(!disabled_state.IsFallbackActive());
}
