import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import '../types/tracing_mode.dart';
import 'webview_feature.dart';
import '../in_app_webview/webview.dart';
import '../types/main.dart';

part 'tracing_controller.g.dart';

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
  static TracingController? _instance;
  static const MethodChannel _channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_tracingcontroller');

  TracingController._();

  ///Gets the [TracingController] shared instance.
  ///
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true`
  ///for [WebViewFeature.TRACING_CONTROLLER_BASIC_USAGE].
  static TracingController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static TracingController _init() {
    _channel.setMethodCallHandler((call) async {
      try {
        return await _handleMethod(call);
      } on Error catch (e) {
        print(e);
        print(e.stackTrace);
      }
    });
    _instance = TracingController._();
    return _instance!;
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
    // TracingController controller = TracingController.instance();
    switch (call.method) {
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    // return null;
  }

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
    await _channel.invokeMethod('start', args);
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
    return await _channel.invokeMethod('stop', args);
  }

  ///Returns whether the WebView framework is tracing.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - TracingController.isTracing](https://developer.android.com/reference/android/webkit/TracingController#isTracing()))
  Future<bool> isTracing() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('isTracing', args);
  }
}

List<dynamic> _deserializeCategories(List<dynamic> categories) {
  List<dynamic> deserializedCategories = [];
  for (dynamic category in categories) {
    if (category is String) {
      deserializedCategories.add(category);
    } else if (category is int) {
      final mode = TracingCategory.fromNativeValue(category);
      if (mode != null) {
        deserializedCategories.add(mode);
      }
    }
  }
  return deserializedCategories;
}

List<dynamic> _serializeCategories(List<dynamic> categories) {
  List<dynamic> serializedCategories = [];
  for (dynamic category in categories) {
    if (category is String) {
      serializedCategories.add(category);
    } else if (category is TracingCategory) {
      serializedCategories.add(category.toNativeValue());
    }
  }
  return serializedCategories;
}

///Class that represents the settings used to configure the [TracingController].
///
///**Supported Platforms/Implementations**:
///- Android native WebView ([Official API - TracingConfig](https://developer.android.com/reference/androidx/webkit/TracingConfig))
@ExchangeableObject(copyMethod: true)
class TracingSettings_ {
  ///Adds predefined [TracingCategory] and/or custom [String] sets of categories to be included in the trace output.
  ///
  ///Note that the categories are defined by the currently-in-use version of WebView.
  ///They live in chromium code and are not part of the Android API.
  ///See [chromium documentation on tracing](https://www.chromium.org/developers/how-tos/trace-event-profiling-tool)
  ///for more details.
  ///
  ///A category pattern can contain wildcards, e.g. `"blink*"` or full category name e.g. `"renderer.scheduler"`.
  @ExchangeableObjectProperty(
      deserializer: _deserializeCategories, serializer: _serializeCategories)
  List<dynamic> categories;

  ///The tracing mode for this configuration.
  ///When tracingMode is not set explicitly, the default is [TracingMode.RECORD_CONTINUOUSLY].
  TracingMode_? tracingMode;

  @ExchangeableObjectConstructor()
  TracingSettings_({this.categories = const [], this.tracingMode}) {
    assert(
        this
            .categories
            .map((e) =>
                e.runtimeType is String || e.runtimeType is TracingCategory)
            .contains(false),
        "categories must contain only String or TracingCategory items");
  }
}
