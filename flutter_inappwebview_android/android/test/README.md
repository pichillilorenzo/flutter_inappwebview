# Resource callback lifecycle check

From the repository root:

```sh
python3 flutter_inappwebview_android/android/test/run_callback_lifecycle_tests.py
```

Set `ANDROID_HOME` (or `ANDROID_SDK_ROOT`) to an existing Android SDK with platform 36. A JDK, Python 3, and the plugin's AndroidX WebKit artifact in the Gradle cache are required. The existing example Android build resolves that artifact; the check does not download dependencies.

The runner compiles the actual Java wait helper, channel delegate, service-worker delegate, response decoder, and callback classes. It supplies explicit Handler, Looper, method-channel, annotation, and unused manager/plugin doubles. These checks exercise native lifecycle and concurrency logic, not Android WebView rendering, the Flutter engine, or an ANR.

Covered behavior: successful, null, error, and unimplemented replies; disposal while waiting; disposal before dispatch; a request after disposal; preserving an already completed reply; ignoring late replies; and reentrant disposal from a callback hook.

Also compile the real plugin through the existing example Android Gradle project:

```sh
cd flutter_inappwebview/example/android
./gradlew :flutter_inappwebview_android:compileDebugJavaWithJavac
```

The lifecycle fix does not impose a timeout on active callbacks. A disposed resource callback raises cancellation, and the request boundaries return the same empty response used by the Android content blocker, preventing network fallback.
