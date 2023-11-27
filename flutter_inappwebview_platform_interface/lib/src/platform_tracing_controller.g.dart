// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_tracing_controller.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the settings used to configure the [PlatformTracingController].
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView ([Official API - TracingConfig](https://developer.android.com/reference/androidx/webkit/TracingConfig))
class TracingSettings {
  ///Adds predefined [TracingCategory] and/or custom [String] sets of categories to be included in the trace output.
  ///
  ///Note that the categories are defined by the currently-in-use version of WebView.
  ///They live in chromium code and are not part of the Android API.
  ///See [chromium documentation on tracing](https://www.chromium.org/developers/how-tos/trace-event-profiling-tool)
  ///for more details.
  ///
  ///A category pattern can contain wildcards, e.g. `"blink*"` or full category name e.g. `"renderer.scheduler"`.
  List<dynamic> categories;

  ///The tracing mode for this configuration.
  ///When tracingMode is not set explicitly, the default is [TracingMode.RECORD_CONTINUOUSLY].
  TracingMode? tracingMode;
  TracingSettings({this.categories = const [], this.tracingMode}) {
    assert(
        this
            .categories
            .map((e) =>
                e.runtimeType is String || e.runtimeType is TracingCategory)
            .contains(false),
        "categories must contain only String or TracingCategory items");
  }

  ///Gets a possible [TracingSettings] instance from a [Map] value.
  static TracingSettings? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = TracingSettings(
      tracingMode: TracingMode.fromNativeValue(map['tracingMode']),
    );
    instance.categories = _deserializeCategories(map['categories']);
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "categories": _serializeCategories(categories),
      "tracingMode": tracingMode?.toNativeValue(),
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of TracingSettings.
  TracingSettings copy() {
    return TracingSettings.fromMap(toMap()) ?? TracingSettings();
  }

  @override
  String toString() {
    return 'TracingSettings{categories: $categories, tracingMode: $tracingMode}';
  }
}
