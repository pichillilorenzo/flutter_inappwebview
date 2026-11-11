#!/usr/bin/env python3
"""Probe the real Java wait helper with synchronous Android/channel test doubles.

This is a JVM concurrency check, not an Android WebView or ANR reproduction.
Requires a JDK, Android SDK 36, and the existing AndroidX WebKit artifact.
Run: python3 flutter_inappwebview_android/android/test/run_callback_lifecycle_tests.py
No test framework, downloads, emulator, or production-source copies are used.
"""
from pathlib import Path
import os
import subprocess
import tempfile
import zipfile

repository = Path(__file__).resolve().parents[3]
native = repository / 'flutter_inappwebview_android/android/src/main/java'
package = 'com/pichillilorenzo/flutter_inappwebview_android'
sdk_location = os.environ.get('ANDROID_HOME') or os.environ.get('ANDROID_SDK_ROOT')
if not sdk_location:
    raise SystemExit('Set ANDROID_HOME to your existing Android SDK directory.')
sdk = Path(sdk_location)
android_jar = sdk / 'platforms/android-36/android.jar'
sources = {
    'io/flutter/plugin/common/MethodCall.java': '''package io.flutter.plugin.common;
public class MethodCall { public String method; public <T> T argument(String name) { return null; } }
''',
    package + '/service_worker/ServiceWorkerManager.java': '''package com.pichillilorenzo.flutter_inappwebview_android.service_worker;
public class ServiceWorkerManager {
  public static androidx.webkit.ServiceWorkerControllerCompat serviceWorkerController;
  public static void init() {}
  public void setServiceWorkerClient(Boolean isNull) {}
}
''',
    'android/os/Looper.java': '''package android.os;
public class Looper { public static Looper getMainLooper() { return new Looper(); } }
''',
    'android/os/Handler.java': '''package android.os;
public class Handler {
  public static volatile boolean paused;
  public static volatile Runnable pending;
  public Handler(Looper looper) {}
  public boolean post(Runnable runnable) {
    if (paused) pending = runnable;
    else runnable.run();
    return true;
  }
}
''',
    'io/flutter/plugin/common/MethodChannel.java': '''package io.flutter.plugin.common;
import java.util.function.Consumer;
public class MethodChannel {
  public interface MethodCallHandler { void onMethodCall(MethodCall call, Result result); }
  public void setMethodCallHandler(MethodCallHandler handler) {}
  public interface Result {
    void success(Object value);
    void error(String code, String message, Object details);
    void notImplemented();
  }
  private final Consumer<Result> handler;
  public MethodChannel(Consumer<Result> handler) { this.handler = handler; }
  public void invokeMethod(String name, Object arguments, Result result) {
    handler.accept(result);
  }
}
''',
    package + '/InAppWebViewFlutterPlugin.java': '''package com.pichillilorenzo.flutter_inappwebview_android;
public class InAppWebViewFlutterPlugin {
  public android.content.Context applicationContext;
  public Assets flutterAssets;
  public interface Assets { String getAssetFilePathByName(String path); }
}
''',

}
for annotation in ('NonNull', 'Nullable', 'RequiresApi', 'CallSuper'):
    sources[f'androidx/annotation/{annotation}.java'] = (
        f'package androidx.annotation; public @interface {annotation} {{ int api() default 1; int value() default 1; }}')

with tempfile.TemporaryDirectory(prefix='webview-wait-probe-') as directory:
    temporary = Path(directory)
    generated = []
    for relative, content in sources.items():
        file = temporary / relative
        file.parent.mkdir(parents=True, exist_ok=True)
        file.write_text(content)
        generated.append(str(file))
    production = [native / package / 'Util.java']
    production += [native / package / 'types' / name for name in (
        'Size2D.java', 'ICallbackResult.java', 'BaseCallbackResultImpl.java',
        'SyncBaseCallbackResultImpl.java')]
    production += [native / package / 'types' / name for name in (
        'ChannelDelegateImpl.java', 'IChannelDelegate.java', 'Disposable.java',
        'WebResourceRequestExt.java', 'WebResourceResponseExt.java')]
    production.append(native / package / 'service_worker/ServiceWorkerChannelDelegate.java')
    generated.append(str(Path(__file__).with_name('CallbackLifecycleTest.java')))
    # Uses the same AndroidX dependency already resolved by the plugin build.
    cache = Path(os.environ.get('GRADLE_USER_HOME', Path.home() / '.gradle'))
    build = repository / 'flutter_inappwebview_android/android/build.gradle'
    version = build.read_text().split('androidx.webkit:webkit:', 1)[1].split("'", 1)[0]
    artifacts = list((cache / 'caches/modules-2/files-2.1/androidx.webkit/webkit' / version).rglob('*.aar'))
    if not artifacts:
        raise SystemExit('Build the existing Android example first to resolve androidx.webkit.')
    webkit = temporary / 'webkit.jar'
    with zipfile.ZipFile(max(artifacts, key=lambda path: path.stat().st_mtime)) as archive:
        webkit.write_bytes(archive.read('classes.jar'))
    classpath = f'{android_jar}{os.pathsep}{webkit}'
    output = temporary / 'classes'
    subprocess.run(['javac', '-cp', classpath, '-d', str(output),
                    *generated, *map(str, production)], check=True)
    subprocess.run(['java', '-cp', f'{output}{os.pathsep}{classpath}',
                    'CallbackLifecycleTest'], check=True, timeout=10)
