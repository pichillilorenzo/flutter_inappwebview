import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

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
    PlatformTracingControllerCreationParams params,
  ) {
    return AndroidTracingControllerCreationParams(params);
  }
}

///{@macro drago_inappwebview.PlatformTracingController}
class AndroidTracingController extends PlatformTracingController
    with ChannelController {
  /// Creates a new [AndroidTracingController].
  AndroidTracingController(PlatformTracingControllerCreationParams params)
    : super.implementation(
        params is AndroidTracingControllerCreationParams
            ? params
            : AndroidTracingControllerCreationParams.fromPlatformTracingControllerCreationParams(
                params,
              ),
      ) {
    channel = const MethodChannel(
      'com.pichillilorenzo/drago_inappwebview_tracingcontroller',
    );
    handler = handleMethod;
    initMethodCallHandler();
  }

  static AndroidTracingController? _instance;

  ///Gets the [AndroidTracingController] shared instance.
  static AndroidTracingController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidTracingController _init() {
    _instance = AndroidTracingController(
      AndroidTracingControllerCreationParams(
        const PlatformTracingControllerCreationParams(),
      ),
    );
    return _instance!;
  }

  static final AndroidTracingController _staticValue = AndroidTracingController(
    AndroidTracingControllerCreationParams(
      const PlatformTracingControllerCreationParams(),
    ),
  );

  /// Provide static access.
  factory AndroidTracingController.static() {
    return _staticValue;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {}

  @override
  Future<void> start({required TracingSettings settings}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("settings", () => settings.toMap());
    await channel?.invokeMethod('start', args);
  }

  @override
  Future<bool> stop({String? filePath}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("filePath", () => filePath);
    return await channel?.invokeMethod<bool>('stop', args) ?? false;
  }

  @override
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
  Future<dynamic> Function(MethodCall call) get handleMethod => _handleMethod;
}
