import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [AndroidTracingController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformTracingControllerCreationParams] for
/// more information.
@immutable
class AndroidTracingControllerCreationParams
    extends PlatformTracingControllerCreationParams {
  /// Creates a new [AndroidTracingControllerCreationParams] instance.
  const AndroidTracingControllerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformTracingControllerCreationParams params,
  ) : super();

  /// Creates a [AndroidTracingControllerCreationParams] instance based on [PlatformTracingControllerCreationParams].
  factory AndroidTracingControllerCreationParams.fromPlatformTracingControllerCreationParams(
      PlatformTracingControllerCreationParams params) {
    return AndroidTracingControllerCreationParams(params);
  }
}

///Manages tracing of [WebView]s.
///In particular provides functionality for the app to enable/disable tracing of parts of code and to collect tracing data.
///This is useful for profiling performance issues, debugging and memory usage analysis in production and real life scenarios.
///
///The resulting trace data is sent back as a byte sequence in json format.
///This file can be loaded in "chrome://tracing" for further analysis.
///
///**Supported Platforms/Implementations**:
///- Android native WebView ([Official API - TracingController](https://developer.android.com/reference/androidx/webkit/TracingController))
class AndroidTracingController extends PlatformTracingController
    with ChannelController {
  /// Creates a new [AndroidTracingController].
  AndroidTracingController(PlatformTracingControllerCreationParams params)
      : super.implementation(
          params is AndroidTracingControllerCreationParams
              ? params
              : AndroidTracingControllerCreationParams
                  .fromPlatformTracingControllerCreationParams(params),
        ) {
    channel = const MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_tracingcontroller');
    handler = handleMethod;
    initMethodCallHandler();
  }

  static AndroidTracingController? _instance;

  ///Gets the [AndroidTracingController] shared instance.
  static AndroidTracingController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidTracingController _init() {
    _instance = AndroidTracingController(AndroidTracingControllerCreationParams(
        const PlatformTracingControllerCreationParams()));
    return _instance!;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {}

  ///Starts tracing all [WebView]s.
  ///Depending on the trace mode in trace config specifies how the trace events are recorded.
  ///For tracing modes [TracingMode.RECORD_UNTIL_FULL] and [TracingMode.RECORD_CONTINUOUSLY]
  ///the events are recorded using an internal buffer and flushed to the outputStream
  ///when [stop] is called.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - TracingController.start](https://developer.android.com/reference/android/webkit/TracingController#start(android.webkit.TracingConfig)))
  Future<void> start({required TracingSettings settings}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("settings", () => settings.toMap());
    await channel?.invokeMethod('start', args);
  }

  ///Stops tracing and flushes tracing data to the specified output stream.
  ///The data is sent to the specified output stream in json format typically in
  ///chunks.
  ///
  ///Returns `false` if the WebView framework was not tracing at the time of the call,
  ///`true` otherwise.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - TracingController.stop](https://developer.android.com/reference/android/webkit/TracingController#stop(java.io.OutputStream,%20java.util.concurrent.Executor)))
  Future<bool> stop({String? filePath}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("filePath", () => filePath);
    return await channel?.invokeMethod<bool>('stop', args) ?? false;
  }

  ///Returns whether the WebView framework is tracing.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - TracingController.isTracing](https://developer.android.com/reference/android/webkit/TracingController#isTracing()))
  Future<bool> isTracing() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('isTracing', args) ?? false;
  }

  @override
  void dispose() {
    // empty
  }
}

extension InternalTracingController on AndroidTracingController {
  get handleMethod => _handleMethod;
}
