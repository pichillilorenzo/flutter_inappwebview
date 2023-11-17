import 'dart:async';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///Manages tracing of [WebView]s.
///In particular provides functionality for the app to enable/disable tracing of parts of code and to collect tracing data.
///This is useful for profiling performance issues, debugging and memory usage analysis in production and real life scenarios.
///
///The resulting trace data is sent back as a byte sequence in json format.
///This file can be loaded in "chrome://tracing" for further analysis.
///
///**Supported Platforms/Implementations**:
///- Android native WebView ([Official API - TracingController](https://developer.android.com/reference/androidx/webkit/TracingController))
class TracingController {
  /// Constructs a [TracingController].
  ///
  /// See [TracingController.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
  TracingController()
      : this.fromPlatformCreationParams(
    const PlatformTracingControllerCreationParams(),
  );

  /// Constructs a [TracingController] from creation params for a specific
  /// platform.
  TracingController.fromPlatformCreationParams(
      PlatformTracingControllerCreationParams params,
      ) : this.fromPlatform(PlatformTracingController(params));

  /// Constructs a [TracingController] from a specific platform
  /// implementation.
  TracingController.fromPlatform(this.platform);

  /// Implementation of [PlatformWebViewTracingController] for the current platform.
  final PlatformTracingController platform;

  static TracingController? _instance;

  ///Gets the [TracingController] shared instance.
  static TracingController instance() {
    if (_instance == null) {
      _instance = TracingController();
    }
    return _instance!;
  }

  ///Starts tracing all [WebView]s.
  ///Depending on the trace mode in trace config specifies how the trace events are recorded.
  ///For tracing modes [TracingMode.RECORD_UNTIL_FULL] and [TracingMode.RECORD_CONTINUOUSLY]
  ///the events are recorded using an internal buffer and flushed to the outputStream
  ///when [stop] is called.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - TracingController.start](https://developer.android.com/reference/android/webkit/TracingController#start(android.webkit.TracingConfig)))
  Future<void> start({required TracingSettings settings}) => platform.start(settings: settings);

  ///Stops tracing and flushes tracing data to the specified output stream.
  ///The data is sent to the specified output stream in json format typically in
  ///chunks.
  ///
  ///Returns `false` if the WebView framework was not tracing at the time of the call,
  ///`true` otherwise.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - TracingController.stop](https://developer.android.com/reference/android/webkit/TracingController#stop(java.io.OutputStream,%20java.util.concurrent.Executor)))
  Future<bool> stop({String? filePath}) => platform.stop(filePath: filePath);

  ///Returns whether the WebView framework is tracing.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - TracingController.isTracing](https://developer.android.com/reference/android/webkit/TracingController#isTracing()))
  Future<bool> isTracing() => platform.isTracing();
}
