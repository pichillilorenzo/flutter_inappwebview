import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'inappwebview_platform.dart';
import 'types/tracing_mode.dart';
import 'types/main.dart';

part 'platform_tracing_controller.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformTracingControllerCreationParams}
/// Object specifying creation parameters for creating a [PlatformTracingController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformTracingControllerCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [AndroidPlatform()])
@immutable
class PlatformTracingControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformTracingController].
  const PlatformTracingControllerCreationParams();

  ///{@template flutter_inappwebview_platform_interface.PlatformTracingControllerCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformTracingControllerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

///{@template flutter_inappwebview_platform_interface.PlatformTracingController}
///Manages tracing of `WebView`s.
///In particular provides functionality for the app to enable/disable tracing of parts of code and to collect tracing data.
///This is useful for profiling performance issues, debugging and memory usage analysis in production and real life scenarios.
///
///The resulting trace data is sent back as a byte sequence in json format.
///This file can be loaded in "chrome://tracing" for further analysis.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformTracingController.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      apiName: 'TracingController',
      apiUrl:
          'https://developer.android.com/reference/androidx/webkit/TracingController',
    ),
  ],
)
abstract class PlatformTracingController extends PlatformInterface {
  /// Creates a new [PlatformTracingController]
  factory PlatformTracingController(
    PlatformTracingControllerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformTracingController tracingController = InAppWebViewPlatform
        .instance!
        .createPlatformTracingController(params);
    PlatformInterface.verify(tracingController, _token);
    return tracingController;
  }

  /// Creates a new [PlatformTracingController]
  factory PlatformTracingController.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`WebViewPlatform.instance` before use. For unit testing, '
      '`WebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformTracingController tracingControllerStatic =
        InAppWebViewPlatform.instance!.createPlatformTracingControllerStatic();
    PlatformInterface.verify(tracingControllerStatic, _token);
    return tracingControllerStatic;
  }

  /// Used by the platform implementation to create a new
  /// [PlatformTracingController].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformTracingController.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformTracingController].
  final PlatformTracingControllerCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformTracingController.start}
  ///Starts tracing all `WebView`s.
  ///Depending on the trace mode in trace config specifies how the trace events are recorded.
  ///For tracing modes [TracingMode.RECORD_UNTIL_FULL] and [TracingMode.RECORD_CONTINUOUSLY]
  ///the events are recorded using an internal buffer and flushed to the outputStream
  ///when [stop] is called.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformTracingController.start.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'TracingController.start',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/TracingController#start(android.webkit.TracingConfig)',
      ),
    ],
  )
  Future<void> start({required TracingSettings settings}) {
    throw UnimplementedError(
      'start is not implemented on the current platform',
    );
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformTracingController.stop}
  ///Stops tracing and flushes tracing data to the specified output stream.
  ///The data is sent to the specified output stream in json format typically in
  ///chunks.
  ///
  ///Returns `false` if the WebView framework was not tracing at the time of the call,
  ///`true` otherwise.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformTracingController.stop.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'TracingController.stop',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/TracingController#stop(java.io.OutputStream,%20java.util.concurrent.Executor)',
      ),
    ],
  )
  Future<bool> stop({String? filePath}) {
    throw UnimplementedError('stop is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformTracingController.isTracing}
  ///Returns whether the WebView framework is tracing.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformTracingController.isTracing.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'TracingController.isTracing',
        apiUrl:
            'https://developer.android.com/reference/android/webkit/TracingController#isTracing()',
      ),
    ],
  )
  Future<bool> isTracing() {
    throw UnimplementedError(
      'isTracing is not implemented on the current platform',
    );
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformTracingControllerCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformTracingController.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformTracingControllerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformTracingControllerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}

List<dynamic> _deserializeCategories(
  List<dynamic> categories, {
  EnumMethod? enumMethod,
}) {
  List<dynamic> deserializedCategories = [];
  for (dynamic category in categories) {
    if (category is String) {
      deserializedCategories.add(category);
    } else if (category is int) {
      final mode = switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => TracingCategory.fromNativeValue(category),
        EnumMethod.value => TracingCategory.fromValue(category),
        EnumMethod.name => null,
      };
      if (mode != null) {
        deserializedCategories.add(mode);
      }
    }
  }
  return deserializedCategories;
}

List<dynamic> _serializeCategories(
  List<dynamic> categories, {
  EnumMethod? enumMethod,
}) {
  List<dynamic> serializedCategories = [];
  for (dynamic category in categories) {
    if (category is String) {
      serializedCategories.add(category);
    } else if (category is TracingCategory) {
      serializedCategories.add(switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => category.toNativeValue(),
        EnumMethod.value => category.toValue(),
        EnumMethod.name => null,
      });
    }
  }
  return serializedCategories;
}

///{@template flutter_inappwebview_platform_interface.TracingSettings}
///Class that represents the settings used to configure the [PlatformTracingController].
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.TracingSettings.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      apiName: 'TracingConfig',
      apiUrl:
          'https://developer.android.com/reference/androidx/webkit/TracingConfig',
    ),
  ],
)
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
    deserializer: _deserializeCategories,
    serializer: _serializeCategories,
  )
  List<dynamic> categories;

  ///The tracing mode for this configuration.
  ///When tracingMode is not set explicitly, the default is [TracingMode.RECORD_CONTINUOUSLY].
  ///
  ///{@macro flutter_inappwebview_platform_interface.TracingSettings.tracingMode.supported_platforms}
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  TracingMode_? tracingMode;

  @ExchangeableObjectConstructor()
  TracingSettings_({this.categories = const [], this.tracingMode}) {
    assert(
      this.categories
          .map(
            (e) => e.runtimeType is String || e.runtimeType is TracingCategory,
          )
          .contains(false),
      "categories must contain only String or TracingCategory items",
    );
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
}
