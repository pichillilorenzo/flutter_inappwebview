// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_tracing_controller.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///{@template flutter_inappwebview_platform_interface.TracingSettings}
///Class that represents the settings used to configure the [PlatformTracingController].
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.TracingSettings.supported_platforms}
///
///**Officially Supported Platforms/Implementations**:
///- Android WebView ([Official API - TracingConfig](https://developer.android.com/reference/androidx/webkit/TracingConfig))
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
  ///
  ///{@macro flutter_inappwebview_platform_interface.TracingSettings.tracingMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  TracingMode? tracingMode;

  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - TracingConfig](https://developer.android.com/reference/androidx/webkit/TracingConfig))
  TracingSettings({this.categories = const [], this.tracingMode}) {
    assert(
      this.categories
          .map(
            (e) => e.runtimeType is String || e.runtimeType is TracingCategory,
          )
          .contains(false),
      "categories must contain only String or TracingCategory items",
    );
  }

  ///Gets a possible [TracingSettings] instance from a [Map] value.
  static TracingSettings? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = TracingSettings(
      tracingMode: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => TracingMode.fromNativeValue(
          map['tracingMode'],
        ),
        EnumMethod.value => TracingMode.fromValue(map['tracingMode']),
        EnumMethod.name => TracingMode.byName(map['tracingMode']),
      },
    );
    if (map['categories'] != null) {
      instance.categories = _deserializeCategories(
        map['categories'],
        enumMethod: enumMethod,
      );
    }
    return instance;
  }

  ///{@template flutter_inappwebview_platform_interface.TracingSettings.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) =>
      _TracingSettingsClassSupported.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.TracingSettings.isPropertySupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  static bool isPropertySupported(
    TracingSettingsProperty property, {
    TargetPlatform? platform,
  }) => _TracingSettingsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "categories": _serializeCategories(categories, enumMethod: enumMethod),
      "tracingMode": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => tracingMode?.toNativeValue(),
        EnumMethod.value => tracingMode?.toValue(),
        EnumMethod.name => tracingMode?.name(),
      },
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

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformTracingControllerCreationParamsClassSupported
    on PlatformTracingControllerCreationParams {
  ///{@template flutter_inappwebview_platform_interface.PlatformTracingControllerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [PlatformTracingControllerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformTracingControllerClassSupported
    on PlatformTracingController {
  ///{@template flutter_inappwebview_platform_interface.PlatformTracingController.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - TracingController](https://developer.android.com/reference/androidx/webkit/TracingController))
  ///
  ///Use the [PlatformTracingController.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformTracingController]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformTracingControllerMethod {
  ///Can be used to check if the [PlatformTracingController.isTracing] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformTracingController.isTracing.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - TracingController.isTracing](https://developer.android.com/reference/android/webkit/TracingController#isTracing()))
  ///
  ///Use the [PlatformTracingController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  isTracing,

  ///Can be used to check if the [PlatformTracingController.start] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformTracingController.start.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - TracingController.start](https://developer.android.com/reference/android/webkit/TracingController#start(android.webkit.TracingConfig)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [settings]: all platforms
  ///
  ///Use the [PlatformTracingController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  start,

  ///Can be used to check if the [PlatformTracingController.stop] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.PlatformTracingController.stop.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - TracingController.stop](https://developer.android.com/reference/android/webkit/TracingController#stop(java.io.OutputStream,%20java.util.concurrent.Executor)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [filePath]: all platforms
  ///
  ///Use the [PlatformTracingController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  stop,
}

extension _PlatformTracingControllerMethodSupported
    on PlatformTracingController {
  static bool isMethodSupported(
    PlatformTracingControllerMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformTracingControllerMethod.isTracing:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformTracingControllerMethod.start:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformTracingControllerMethod.stop:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

extension _TracingSettingsClassSupported on TracingSettings {
  ///{@template flutter_inappwebview_platform_interface.TracingSettings.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - TracingConfig](https://developer.android.com/reference/androidx/webkit/TracingConfig))
  ///
  ///Use the [TracingSettings.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [TracingSettings]'s properties that can be used to check i they are supported or not by the current platform.
enum TracingSettingsProperty {
  ///Can be used to check if the [TracingSettings.tracingMode] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_platform_interface.TracingSettings.tracingMode.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///
  ///Use the [TracingSettings.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  tracingMode,
}

extension _TracingSettingsPropertySupported on TracingSettings {
  static bool isPropertySupported(
    TracingSettingsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case TracingSettingsProperty.tracingMode:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
