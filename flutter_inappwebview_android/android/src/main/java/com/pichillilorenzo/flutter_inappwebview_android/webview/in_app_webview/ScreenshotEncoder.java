package com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview;

import android.graphics.Bitmap;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Process;
import android.util.Log;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Off-looper half of the screenshot pipeline: scale, compress and reply.
 *
 * <p>A single process-wide worker thread serialises encodes so the number of large bitmaps alive at
 * once stays bounded and no thread is created per screenshot or per WebView. It is a HandlerThread
 * rather than an executor so the worker stays addressable as a Handler. Admission is
 * a counting permit taken by {@link InAppWebView#takeScreenshot} before anything is allocated and
 * released by {@link ScreenshotRequest#finish()}, so a rejected request costs no bitmap.
 */
final class ScreenshotEncoder {
  private static final String LOG_TAG = "ScreenshotEncoder";

  /**
   * Upper bound on screenshot requests alive in the process (queued, drawing or encoding). Each one
   * may own a viewport-sized ARGB bitmap (~10 MB at 1080x2400), so keep this small.
   */
  static final int MAX_IN_FLIGHT = 4;

  /**
   * One notch above {@link Process#THREAD_PRIORITY_BACKGROUND}: lower than the UI thread (0) and the
   * render thread, but still outside the background cgroup, which can throttle a thread to a few
   * percent of a core while the foreground is busy and would make previews arbitrarily stale.
   */
  private static final int ENCODE_THREAD_PRIORITY =
          Process.THREAD_PRIORITY_BACKGROUND + Process.THREAD_PRIORITY_MORE_FAVORABLE;

  private static final AtomicInteger IN_FLIGHT = new AtomicInteger();

  private static final HandlerThread THREAD = new HandlerThread("fiwv-screenshot-encode", ENCODE_THREAD_PRIORITY);

  static {
    THREAD.setDaemon(true);
    THREAD.start();
  }

  /** The worker's handler. */
  static final Handler HANDLER = new Handler(THREAD.getLooper());

  private ScreenshotEncoder() {
  }

  /** Takes an admission permit; {@code false} means the process-wide limit is reached. */
  static boolean tryAcquire() {
    while (true) {
      int current = IN_FLIGHT.get();
      if (current >= MAX_IN_FLIGHT) {
        return false;
      }
      if (IN_FLIGHT.compareAndSet(current, current + 1)) {
        return true;
      }
    }
  }

  static void release() {
    IN_FLIGHT.decrementAndGet();
  }

  /**
   * Takes ownership of {@code captured} and finishes the request on the worker. If the worker
   * cannot accept the task the bitmap is recycled and the request is settled with {@code null} here.
   */
  static void submit(@NonNull final ScreenshotRequest request, @NonNull final Bitmap captured) {
    final boolean posted = HANDLER.post(new Runnable() {
      @Override
      public void run() {
        encode(request, captured);
      }
    });
    if (!posted) {
      captured.recycle();
      request.settle(null);
      request.finish();
    }
  }

  /**
   * Scale (unless the capture stage already produced the target size), compress and reply. Owns
   * {@code captured}; always finishes the request. Must run on the worker thread.
   */
  static void encode(@NonNull ScreenshotRequest request, @NonNull Bitmap captured) {
    Bitmap bitmap = captured;
    try {
      if (request.snapshotWidth != null && !request.alreadyScaled) {
        int dstWidth = (int) Math.floor(request.snapshotWidth * request.pixelDensity + 0.5);
        float ratioBitmap = (float) bitmap.getWidth() / (float) bitmap.getHeight();
        int dstHeight = (int) ((float) dstWidth / ratioBitmap);
        Bitmap scaled = Bitmap.createScaledBitmap(bitmap, dstWidth, dstHeight, true);
        // createScaledBitmap returns the source itself when no scaling is needed; never recycle
        // the bitmap that is about to be compressed.
        if (scaled != bitmap) {
          bitmap.recycle();
          bitmap = scaled;
        }
      }

      ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
      final boolean compressed =
              bitmap.compress(request.compressFormat, request.quality, byteArrayOutputStream);
      if (!compressed) {
        Log.e(LOG_TAG, "Screenshot cannot be compressed using compressFormat " +
                request.compressFormat.name() + " with quality " + request.quality, null);
        return; // the finally block replies with null
      }

      try {
        byteArrayOutputStream.close();
      } catch (IOException e) {
        Log.e(LOG_TAG, "", e);
      }
      bitmap.recycle();
      bitmap = null;
      request.settle(byteArrayOutputStream.toByteArray());
    } catch (IllegalArgumentException | OutOfMemoryError e) {
      Log.e(LOG_TAG, "", e);
    } finally {
      if (bitmap != null) {
        bitmap.recycle();
      }
      // Any path that returned without a reply (a failed compress, an error) answers null here.
      request.settle(null);
      request.finish();
    }
  }
}
