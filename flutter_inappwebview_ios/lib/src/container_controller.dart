import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [IOSContainerController].
@immutable
class IOSContainerControllerCreationParams
    extends PlatformContainerControllerCreationParams {
  /// Creates a new [IOSContainerControllerCreationParams] instance.
  const IOSContainerControllerCreationParams(
    // ignore: avoid_unused_constructor_parameters
    PlatformContainerControllerCreationParams params,
  ) : super();

  /// Creates a [IOSContainerControllerCreationParams] instance based on [PlatformContainerControllerCreationParams].
  factory IOSContainerControllerCreationParams.fromPlatformContainerControllerCreationParams(
    PlatformContainerControllerCreationParams params,
  ) {
    return IOSContainerControllerCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformContainerController}
class IOSContainerController extends PlatformContainerController
    with ChannelController {
  /// Creates a new [IOSContainerController].
  IOSContainerController(PlatformContainerControllerCreationParams params)
    : super.implementation(
        params is IOSContainerControllerCreationParams
            ? params
            : IOSContainerControllerCreationParams.fromPlatformContainerControllerCreationParams(
                params,
              ),
      ) {
    channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_containercontroller',
    );
    handler = handleMethod;
    initMethodCallHandler();
  }

  static IOSContainerController? _instance;

  ///Gets the [IOSContainerController] shared instance.
  static IOSContainerController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static IOSContainerController _init() {
    _instance = IOSContainerController(
      IOSContainerControllerCreationParams(
        const PlatformContainerControllerCreationParams(),
      ),
    );
    return _instance!;
  }

  static final IOSContainerController _staticValue = IOSContainerController(
    IOSContainerControllerCreationParams(
      const PlatformContainerControllerCreationParams(),
    ),
  );

  /// Provide static access.
  factory IOSContainerController.static() {
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

extension InternalContainerController on IOSContainerController {
  get handleMethod => _handleMethod;
}
