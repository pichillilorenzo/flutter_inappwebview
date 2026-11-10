package com.pichillilorenzo.flutter_inappwebview_android.webview_environment;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.webkit.WebViewCompat;
import androidx.webkit.WebViewStartUpConfig;

import com.pichillilorenzo.flutter_inappwebview_android.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview_android.types.ChannelDelegateImpl;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/** Explicit, background-only startup. Constructing this manager does not initialize WebView. */
public final class WebViewEnvironmentManager extends ChannelDelegateImpl {
  public static final String METHOD_CHANNEL_NAME =
      "com.pichillilorenzo/flutter_webview_environment";

  private final Handler mainHandler = new Handler(Looper.getMainLooper());
  @Nullable private InAppWebViewFlutterPlugin plugin;
  @Nullable private PendingWebViewPrewarm operation;
  @Nullable private ExecutorService executor;
  private final Runnable timeout = () -> finish("timeout");

  public WebViewEnvironmentManager(@NonNull InAppWebViewFlutterPlugin plugin) {
    super(new MethodChannel(plugin.messenger, METHOD_CHANNEL_NAME));
    this.plugin = plugin;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    if (!"prewarm".equals(call.method)) {
      result.notImplemented();
      return;
    }
    if (operation != null) {
      operation.add(result::success);
      return;
    }
    operation = new PendingWebViewPrewarm();
    operation.add(result::success);
    if (plugin == null || plugin.applicationContext == null) {
      finish("unavailable");
      return;
    }
    start(plugin.applicationContext.getApplicationContext());
  }

  @SuppressLint("UnsafeOptInUsageError")
  private void start(Context applicationContext) {
    mainHandler.postDelayed(timeout, 30_000);
    try {
      final ExecutorService background = Executors.newSingleThreadExecutor(runnable -> {
        Thread thread = new Thread(runnable, "flutter-webview-prewarm");
        thread.setDaemon(true);
        return thread;
      });
      executor = background;
      WebViewStartUpConfig config = new WebViewStartUpConfig.Builder(command -> {
        try {
          background.execute(() -> {
            try {
              command.run();
            } catch (RuntimeException | LinkageError error) {
              // AndroidX 1.14's experimental API has no failure callback.
              mainHandler.post(() -> finish("create_failed"));
            }
          });
        } catch (RuntimeException error) {
          mainHandler.post(() -> finish("thread_failed"));
        }
      }).setShouldRunUiThreadStartUpTasks(false).build();
      // No WebViewFeature query here: even that could start WebView synchronously.
      // Background-only mode also avoids the blocking user-agent fallback on old providers.
      WebViewCompat.startUpWebView(applicationContext, config, ignored -> finish("ok"));
    } catch (RuntimeException | LinkageError error) {
      finish("unavailable");
    }
  }

  private void finish(String status) {
    mainHandler.removeCallbacks(timeout);
    if (executor != null) {
      // Interrupting Chromium/provider initialization is unsafe. It may finish after timeout.
      executor.shutdown();
      executor = null;
    }
    if (operation != null) {
      operation.complete(status);
    }
  }

  @Override
  public void dispose() {
    finish("unavailable");
    super.dispose();
    plugin = null;
  }
}
