import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [AndroidContainerController].
@immutable
class AndroidContainerControllerCreationParams
    extends PlatformContainerControllerCreationParams {
  /// Creates a new [AndroidContainerControllerCreationParams] instance.
  const AndroidContainerControllerCreationParams(
    // ignore: avoid_unused_constructor_parameters
    PlatformContainerControllerCreationParams params,
  ) : super();

  /// Creates a [AndroidContainerControllerCreationParams] instance based on [PlatformContainerControllerCreationParams].
  factory AndroidContainerControllerCreationParams.fromPlatformContainerControllerCreationParams(
    PlatformContainerControllerCreationParams params,
  ) {
    return AndroidContainerControllerCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformContainerController}
class AndroidContainerController extends PlatformContainerController
    with ChannelController {
  /// Creates a new [AndroidContainerController].
  AndroidContainerController(PlatformContainerControllerCreationParams params)
    : super.implementation(
        params is AndroidContainerControllerCreationParams
            ? params
            : AndroidContainerControllerCreationParams.fromPlatformContainerControllerCreationParams(
                params,
              ),
      ) {
    channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_containercontroller',
    );
    handler = handleMethod;
    initMethodCallHandler();
  }

  static AndroidContainerController? _instance;

  ///Gets the [AndroidContainerController] shared instance.
  static AndroidContainerController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static AndroidContainerController _init() {
    _instance = AndroidContainerController(
      AndroidContainerControllerCreationParams(
        const PlatformContainerControllerCreationParams(),
      ),
    );
    return _instance!;
  }

  static final AndroidContainerController _staticValue =
      AndroidContainerController(
        AndroidContainerControllerCreationParams(
          const PlatformContainerControllerCreationParams(),
        ),
      );

  /// Provide static access.
  factory AndroidContainerController.static() {
    return _staticValue;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {}

  @override
  Future<List<String>> getAllContainerNames() async {
    final names = await channel?.invokeMethod<List>('getAllContainerNames');
    return names?.cast<String>() ?? const <String>[];
  }

  @override
  Future<bool> hasContainer(String containerId) async {
    final ok = await channel?.invokeMethod<bool>('hasContainer', {
      'containerId': containerId,
    });
    return ok ?? false;
  }

  @override
  Future<bool> deleteContainer(String containerId) async {
    final ok = await channel?.invokeMethod<bool>('deleteContainer', {
      'containerId': containerId,
    });
    return ok ?? false;
  }

  @override
  Future<bool> clearContainerData(String containerId) async {
    final ok = await channel?.invokeMethod<bool>('clearContainerData', {
      'containerId': containerId,
    });
    return ok ?? false;
  }

  @override
  void dispose() {
    // empty
  }
}

extension InternalContainerController on AndroidContainerController {
  get handleMethod => _handleMethod;
}
