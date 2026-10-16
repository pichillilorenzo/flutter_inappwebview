package com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview;

import android.graphics.Bitmap;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.MethodChannel;

/**
 * One accepted {@code takeScreenshot()} call, tracked from admission until its reply is settled.
 *
 * <p>Cancellation is cooperative. {@link #cancel} only raises a flag; whichever thread currently owns
 * the request (the WebView looper while capturing, the encode worker afterwards) polls the flag
 * between stages and discards its output. None of {@code draw}, {@code createScaledBitmap} or
 * {@code compress} is preemptible; {@code compress} is cut short by
 * {@link ScreenshotEncoder.CancellableByteArrayOutputStream} refusing further writes.
 *
 * <p>Three one-shot latches keep the lifecycle race-free no matter which thread gets there first:
 * <ul>
 *   <li>{@link #tryMarkStarted()} decides who owns the capture stage: the posted runnable, or a
 *       cancel that arrived while it was still queued.</li>
 *   <li>{@link #settle(byte[])} delivers the {@link MethodChannel.Result} exactly once.</li>
 *   <li>{@link #finish()} runs the owner's bookkeeping (registry removal, admission permit) exactly
 *       once.</li>
 * </ul>
 */
final class ScreenshotRequest {
  interface Listener {
    void onFinished(@NonNull ScreenshotRequest request);
  }

  final long id;
  @Nullable
  final Map<String, Object> configuration;
  private final MethodChannel.Result result;
  private final Listener listener;
  private final AtomicBoolean started = new AtomicBoolean(false);
  private final AtomicBoolean cancelled = new AtomicBoolean(false);
  private final AtomicBoolean settled = new AtomicBoolean(false);
  private final AtomicBoolean finished = new AtomicBoolean(false);

  /** The capture runnable posted to the WebView looper, so a queued request can be removed. */
  @Nullable
  volatile Runnable captureTask;

  // Capture geometry and encode parameters. Written by the capture thread before the bitmap is
  // handed to the encoder; the handler hand-off is the happens-before edge that makes them visible
  // to the worker. captureX/Y are content coordinates (the scroll offset, or rect.x/y).
  Bitmap.CompressFormat compressFormat = Bitmap.CompressFormat.PNG;
  int quality = 100;
  @Nullable
  Double snapshotWidth;
  float pixelDensity = 1f;
  int captureX, captureY, captureWidth, captureHeight;
  /** Target size when snapshotWidth is set (same rounding as the scale stage), else 0. */
  int dstWidth, dstHeight;
  /** Android-only option from ScreenshotConfiguration. */
  boolean drawScaled;
  /** True when the capture stage already produced the bitmap at dstWidth x dstHeight. */
  boolean alreadyScaled;

  ScreenshotRequest(long id,
                    @Nullable Map<String, Object> configuration,
                    @NonNull MethodChannel.Result result,
                    @NonNull Listener listener) {
    this.id = id;
    this.configuration = configuration;
    this.result = result;
    this.listener = listener;
  }

  /** Claims the capture stage. Exactly one caller ever gets {@code true}. */
  boolean tryMarkStarted() {
    return started.compareAndSet(false, true);
  }

  /**
   * Raises the cancellation flag. Returns {@code false} if it was already raised. Does not settle
   * the reply; see {@link InAppWebView#cancelScreenshot(long)} for the completion rule.
   */
  boolean cancel() {
    return cancelled.compareAndSet(false, true);
  }

  boolean isCancelled() {
    return cancelled.get();
  }

  /**
   * Delivers the reply at most once. Safe from any thread: the Flutter Android embedding accepts
   * platform-message replies off the main thread and itself guards against a second reply.
   */
  boolean settle(@Nullable byte[] bytes) {
    if (!settled.compareAndSet(false, true)) {
      return false;
    }
    result.success(bytes);
    return true;
  }

  /** Runs owner bookkeeping once. */
  boolean finish() {
    if (!finished.compareAndSet(false, true)) {
      return false;
    }
    listener.onFinished(this);
    return true;
  }
}
