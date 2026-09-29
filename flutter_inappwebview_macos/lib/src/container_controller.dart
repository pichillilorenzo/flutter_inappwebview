import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [MacOSContainerController].
@immutable
class MacOSContainerControllerCreationParams
    extends PlatformContainerControllerCreationParams {
  /// Creates a new [MacOSContainerControllerCreationParams] instance.
  const MacOSContainerControllerCreationParams(
    // ignore: avoid_unused_constructor_parameters
    PlatformContainerControllerCreationParams params,
  ) : super();

  /// Creates a [MacOSContainerControllerCreationParams] instance based on [PlatformContainerControllerCreationParams].
  factory MacOSContainerControllerCreationParams.fromPlatformContainerControllerCreationParams(
    PlatformContainerControllerCreationParams params,
  ) {
    return MacOSContainerControllerCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformContainerController}
class MacOSContainerController extends PlatformContainerController
    with ChannelController {
  /// Creates a new [MacOSContainerController].
  MacOSContainerController(PlatformContainerControllerCreationParams params)
    : super.implementation(
        params is MacOSContainerControllerCreationParams
            ? params
            : MacOSContainerControllerCreationParams.fromPlatformContainerControllerCreationParams(
                params,
              ),
      ) {
    channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_containercontroller',
    );
    handler = handleMethod;
    initMethodCallHandler();
  }

  static MacOSContainerController? _instance;

  ///Gets the [MacOSContainerController] shared instance.
  static MacOSContainerController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static MacOSContainerController _init() {
    _instance = MacOSContainerController(
      MacOSContainerControllerCreationParams(
        const PlatformContainerControllerCreationParams(),
      ),
    );
    return _instance!;
  }

  static final MacOSContainerController _staticValue = MacOSContainerController(
    MacOSContainerControllerCreationParams(
      const PlatformContainerControllerCreationParams(),
    ),
  );

  /// Provide static access.
  factory MacOSContainerController.static() {
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

extension InternalContainerController on MacOSContainerController {
  get handleMethod => _handleMethod;
}
