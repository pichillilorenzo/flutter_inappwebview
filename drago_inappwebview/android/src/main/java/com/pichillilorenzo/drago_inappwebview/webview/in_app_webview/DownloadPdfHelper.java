package com.pichillilorenzo.drago_inappwebview.webview.in_app_webview;

import android.app.DownloadManager;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.print.DragoPdfPrinter;
import android.print.PrintAttributes;
import android.print.PrintDocumentAdapter;
import android.provider.MediaStore;
import android.util.Base64;
import android.util.Log;
import android.webkit.CookieManager;
import android.webkit.URLUtil;
import android.webkit.ValueCallback;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.drago_inappwebview.print_job.PrintJobSettings;
import com.pichillilorenzo.drago_inappwebview.types.DownloadStartRequest;
import com.pichillilorenzo.drago_inappwebview.types.MarginsExt;

import org.json.JSONObject;

import android.database.Cursor;

import java.io.ByteArrayOutputStream;
import java.lang.ref.WeakReference;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLDecoder;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.MethodChannel;

/** Native SAVE for onDownloadStarting and createPdf on Android. */
public class DownloadPdfHelper {
  static final String LOG_TAG = "DragoDownloadPdf";
  private static final Handler mainHandler = new Handler(Looper.getMainLooper());
  private static final ExecutorService io = Executors.newCachedThreadPool();

  // ---------------------------------------------------------------- progress

  static final int STATE_IN_PROGRESS = 0;
  static final int STATE_COMPLETED = 1;
  static final int STATE_FAILED = 2;
  static final int STATE_CANCELED = 3;
  private static final long THROTTLE_MS = 250;

  /** Sends onDownloadProgress events for one download; IN_PROGRESS throttled to ~4/sec. */
  static class ProgressReporter {
    private final WeakReference<InAppWebView> webViewRef;
    private final String url;
    @Nullable volatile String resultFilePath;
    private long lastSent = 0;
    private boolean finished = false;

    ProgressReporter(InAppWebView webView, String url, @Nullable String resultFilePath) {
      this.webViewRef = new WeakReference<>(webView);
      this.url = url;
      this.resultFilePath = resultFilePath;
    }

    /** False once the webview is gone (disposed). */
    boolean isAlive() {
      InAppWebView webView = webViewRef.get();
      return webView != null && webView.channelDelegate != null;
    }

    synchronized void progress(long received, long total) {
      long now = System.currentTimeMillis();
      if (finished || now - lastSent < THROTTLE_MS) return;
      lastSent = now;
      send(STATE_IN_PROGRESS, received, total, null);
    }

    synchronized void finish(int state, long received, long total, @Nullable String error) {
      if (finished) return;
      finished = true;
      send(state, received, total, error);
    }

    private void send(int state, long received, long total, @Nullable String error) {
      final Map<String, Object> map = new HashMap<>();
      map.put("url", url);
      map.put("resultFilePath", resultFilePath);
      map.put("receivedBytes", Math.max(received, 0));
      map.put("totalBytes", total > 0 ? total : null);
      map.put("state", state);
      map.put("error", error);
      mainHandler.post(new Runnable() {
        @Override
        public void run() {
          InAppWebView webView = webViewRef.get();
          if (webView != null && webView.channelDelegate != null) {
            webView.channelDelegate.onDownloadProgress(map);
          }
        }
      });
    }
  }

  /** Polls DownloadManager every 250ms until the download ends or the webview is disposed. */
  private static void pollDownloadManager(final DownloadManager manager, final long id,
                                          final ProgressReporter reporter) {
    mainHandler.postDelayed(new Runnable() {
      @Override
      public void run() {
        if (!reporter.isAlive()) return;
        Cursor c = null;
        try {
          c = manager.query(new DownloadManager.Query().setFilterById(id));
          if (c == null || !c.moveToFirst()) {
            reporter.finish(STATE_CANCELED, 0, -1, null);
            return;
          }
          int status = c.getInt(c.getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS));
          long received = c.getLong(c.getColumnIndexOrThrow(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR));
          long total = c.getLong(c.getColumnIndexOrThrow(DownloadManager.COLUMN_TOTAL_SIZE_BYTES));
          if (status == DownloadManager.STATUS_SUCCESSFUL) {
            String local = c.getString(c.getColumnIndexOrThrow(DownloadManager.COLUMN_LOCAL_URI));
            if (local != null) {
              Uri u = Uri.parse(local);
              reporter.resultFilePath = "file".equals(u.getScheme()) ? u.getPath() : local;
            }
            reporter.finish(STATE_COMPLETED, received, total, null);
            return;
          }
          if (status == DownloadManager.STATUS_FAILED) {
            int reason = c.getInt(c.getColumnIndexOrThrow(DownloadManager.COLUMN_REASON));
            reporter.finish(STATE_FAILED, received, total, "DownloadManager error " + reason);
            return;
          }
          reporter.progress(received, total);
        } catch (Exception e) {
          reporter.finish(STATE_FAILED, 0, -1, e.toString());
          return;
        } finally {
          if (c != null) c.close();
        }
        mainHandler.postDelayed(this, THROTTLE_MS);
      }
    }, THROTTLE_MS);
  }

  // ---------------------------------------------------------------- downloads

  public static void save(@NonNull final InAppWebView webView, @NonNull DownloadStartRequest request,
                          @Nullable final String resultFilePath) {
    final Context context = webView.getContext().getApplicationContext();
    final String url = request.getUrl();
    final ProgressReporter reporter = new ProgressReporter(webView, url, resultFilePath);
    final String mimeType = request.getMimeType();
    final String fileName = request.getSuggestedFilename() != null ? request.getSuggestedFilename()
            : URLUtil.guessFileName(url, request.getContentDisposition(), mimeType);
    try {
      if (url.startsWith("data:")) {
        writeAsync(context, decodeDataUrl(url), resultFilePath, fileName, mimeType, reporter);
      } else if (url.startsWith("blob:")) {
        String body = "const r = await fetch(url); const b = await r.blob();"
                + "return await new Promise((res, rej) => { const fr = new FileReader();"
                + "fr.onload = () => res(fr.result); fr.onerror = () => rej(fr.error); fr.readAsDataURL(b); });";
        Map<String, Object> args = new HashMap<>();
        args.put("url", url);
        webView.callAsyncJavaScript(body, args, null, new ValueCallback<String>() {
          @Override
          public void onReceiveValue(String value) {
            try {
              JSONObject json = new JSONObject(value);
              String dataUrl = json.optString("value", null);
              if (dataUrl == null || !dataUrl.startsWith("data:")) {
                Log.e(LOG_TAG, "blob download failed: " + json.optString("error"));
                reporter.finish(STATE_FAILED, 0, -1, json.optString("error", "blob download failed"));
                return;
              }
              writeAsync(context, decodeDataUrl(dataUrl), resultFilePath, fileName, mimeType, reporter);
            } catch (Exception e) {
              Log.e(LOG_TAG, "blob download failed", e);
              reporter.finish(STATE_FAILED, 0, -1, e.toString());
            }
          }
        });
      } else if (resultFilePath != null) {
        downloadToPath(url, request.getUserAgent(), resultFilePath, reporter);
      } else {
        DownloadManager.Request dm = new DownloadManager.Request(Uri.parse(url));
        String cookies = CookieManager.getInstance().getCookie(url);
        if (cookies != null) dm.addRequestHeader("Cookie", cookies);
        if (request.getUserAgent() != null) dm.addRequestHeader("User-Agent", request.getUserAgent());
        if (mimeType != null) dm.setMimeType(mimeType);
        dm.setTitle(fileName);
        dm.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
        dm.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, fileName);
        DownloadManager manager = (DownloadManager) context.getSystemService(Context.DOWNLOAD_SERVICE);
        if (manager != null) {
          long id = manager.enqueue(dm);
          pollDownloadManager(manager, id, reporter);
        } else {
          reporter.finish(STATE_FAILED, 0, -1, "DownloadManager unavailable");
        }
      }
    } catch (Exception e) {
      Log.e(LOG_TAG, "download failed", e);
      reporter.finish(STATE_FAILED, 0, -1, e.toString());
    }
  }

  static byte[] decodeDataUrl(String url) throws Exception {
    int comma = url.indexOf(',');
    if (comma < 0) throw new IllegalArgumentException("bad data url");
    String meta = url.substring(5, comma);
    String data = url.substring(comma + 1);
    if (meta.endsWith(";base64")) {
      return Base64.decode(data, Base64.DEFAULT);
    }
    return URLDecoder.decode(data.replace("+", "%2B"), "UTF-8").getBytes("UTF-8");
  }

  private static void writeAsync(final Context context, final byte[] bytes, @Nullable final String path,
                                 final String fileName, @Nullable final String mimeType,
                                 final ProgressReporter reporter) {
    io.execute(new Runnable() {
      @Override
      public void run() {
        try {
          if (path != null) {
            File f = new File(path);
            File parent = f.getParentFile();
            if (parent != null) parent.mkdirs();
            OutputStream os = new FileOutputStream(f, false);
            try { os.write(bytes); } finally { os.close(); }
          } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ContentResolver resolver = context.getContentResolver();
            ContentValues values = new ContentValues();
            values.put(MediaStore.Downloads.DISPLAY_NAME, fileName);
            if (mimeType != null) values.put(MediaStore.Downloads.MIME_TYPE, mimeType);
            values.put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS);
            Uri uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values);
            if (uri == null) throw new IllegalStateException("MediaStore insert failed");
            reporter.resultFilePath = uri.toString();
            OutputStream os = resolver.openOutputStream(uri);
            if (os == null) throw new IllegalStateException("MediaStore open failed");
            try { os.write(bytes); } finally { os.close(); }
          } else {
            File dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
            dir.mkdirs();
            File f = new File(dir, fileName);
            reporter.resultFilePath = f.getAbsolutePath();
            OutputStream os = new FileOutputStream(f, false);
            try { os.write(bytes); } finally { os.close(); }
          }
          reporter.finish(STATE_COMPLETED, bytes.length, bytes.length, null);
        } catch (Exception e) {
          Log.e(LOG_TAG, "write download failed", e);
          reporter.finish(STATE_FAILED, 0, bytes.length, e.toString());
        }
      }
    });
  }

  private static void downloadToPath(final String url, @Nullable final String userAgent, final String path,
                                     final ProgressReporter reporter) {
    io.execute(new Runnable() {
      @Override
      public void run() {
        HttpURLConnection conn = null;
        try {
          conn = (HttpURLConnection) new URL(url).openConnection();
          String cookies = CookieManager.getInstance().getCookie(url);
          if (cookies != null) conn.setRequestProperty("Cookie", cookies);
          if (userAgent != null) conn.setRequestProperty("User-Agent", userAgent);
          conn.setInstanceFollowRedirects(true);
          File f = new File(path);
          File parent = f.getParentFile();
          if (parent != null) parent.mkdirs();
          InputStream is = conn.getInputStream();
          long total = conn.getContentLength();
          long received = 0;
          OutputStream os = new FileOutputStream(f, false);
          try {
            byte[] buf = new byte[16384];
            int n;
            while ((n = is.read(buf)) > 0) {
              os.write(buf, 0, n);
              received += n;
              reporter.progress(received, total);
            }
          } finally {
            os.close();
            is.close();
          }
          reporter.finish(STATE_COMPLETED, received, total > 0 ? total : received, null);
        } catch (Exception e) {
          Log.e(LOG_TAG, "download to path failed", e);
          reporter.finish(STATE_FAILED, 0, -1, e.toString());
        } finally {
          if (conn != null) conn.disconnect();
        }
      }
    });
  }

  // ---------------------------------------------------------------- pdf

  @SuppressWarnings("unchecked")
  public static void createPdf(@NonNull InAppWebView webView, @Nullable Map<String, Object> pdfConfiguration,
                               @NonNull final MethodChannel.Result result) {
    try {
      PrintAttributes.MediaSize mediaSize = PrintAttributes.MediaSize.ISO_A4;
      PrintAttributes.Margins margins = PrintAttributes.Margins.NO_MARGINS;
      Map<String, Object> settingsMap = pdfConfiguration != null
              ? (Map<String, Object>) pdfConfiguration.get("settings") : null;
      if (settingsMap != null) {
        PrintJobSettings settings = new PrintJobSettings().parse(settingsMap);
        if (settings.mediaSize != null) mediaSize = settings.mediaSize.toMediaSize();
        // PrintJobOrientation: 0 = portrait, 1 = landscape
        mediaSize = (settings.orientation != null && settings.orientation == 1)
                ? mediaSize.asLandscape() : mediaSize.asPortrait();
        Object m = settingsMap.get("margins");
        if (m instanceof Map) {
          Map<String, Object> mm = (Map<String, Object>) m;
          margins = new MarginsExt(num(mm.get("top")), num(mm.get("right")),
                  num(mm.get("bottom")), num(mm.get("left"))).toMargins();
        }
      }
      PrintAttributes attributes = new PrintAttributes.Builder()
              .setMediaSize(mediaSize)
              .setResolution(new PrintAttributes.Resolution("pdf", "pdf", 300, 300))
              .setMinMargins(margins)
              .setColorMode(PrintAttributes.COLOR_MODE_COLOR)
              .build();
      final PrintDocumentAdapter adapter = webView.createPrintDocumentAdapter("drago_pdf");
      final File out = File.createTempFile("drago_pdf", ".pdf", webView.getContext().getCacheDir());
      DragoPdfPrinter.print(adapter, attributes, out, new DragoPdfPrinter.Callback() {
        @Override
        public void onDone(final boolean success) {
          io.execute(new Runnable() {
            @Override
            public void run() {
              byte[] bytes = null;
              if (success) {
                try {
                  InputStream is = new FileInputStream(out);
                  ByteArrayOutputStream bos = new ByteArrayOutputStream();
                  byte[] buf = new byte[16384];
                  int n;
                  while ((n = is.read(buf)) > 0) bos.write(buf, 0, n);
                  is.close();
                  bytes = bos.toByteArray();
                } catch (Exception e) {
                  Log.e(LOG_TAG, "read pdf failed", e);
                }
              }
              //noinspection ResultOfMethodCallIgnored
              out.delete();
              final byte[] finalBytes = (bytes != null && bytes.length > 0) ? bytes : null;
              mainHandler.post(new Runnable() {
                @Override
                public void run() {
                  result.success(finalBytes);
                }
              });
            }
          });
        }
      });
    } catch (Exception e) {
      Log.e(LOG_TAG, "createPdf failed", e);
      result.success(null);
    }
  }

  private static double num(Object o) {
    return o instanceof Number ? ((Number) o).doubleValue() : 0;
  }
}
