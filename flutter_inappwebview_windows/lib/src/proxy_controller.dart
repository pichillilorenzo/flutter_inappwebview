import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

/// Object specifying creation parameters for creating a [WindowsProxyController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformProxyControllerCreationParams] for
/// more information.
@immutable
class WindowsProxyControllerCreationParams
    extends PlatformProxyControllerCreationParams {
  /// Creates a new [WindowsProxyControllerCreationParams] instance.
  const WindowsProxyControllerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformProxyControllerCreationParams params,
  ) : super();

  /// Creates a [WindowsProxyControllerCreationParams] instance based on [PlatformProxyControllerCreationParams].
  factory WindowsProxyControllerCreationParams.fromPlatformProxyControllerCreationParams(
    PlatformProxyControllerCreationParams params,
  ) {
    return WindowsProxyControllerCreationParams(params);
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformProxyController}
class WindowsProxyController extends PlatformProxyController
    with ChannelController {
  /// Creates a new [WindowsProxyController].
  WindowsProxyController(PlatformProxyControllerCreationParams params)
    : super.implementation(
        params is WindowsProxyControllerCreationParams
            ? params
            : WindowsProxyControllerCreationParams.fromPlatformProxyControllerCreationParams(
                params,
              ),
      ) {
    channel = const MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_proxycontroller',
    );
    handler = handleMethod;
    initMethodCallHandler();
  }

  static WindowsProxyController? _instance;

  ///Gets the [WindowsProxyController] shared instance.
  static WindowsProxyController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static WindowsProxyController _init() {
    _instance = WindowsProxyController(
      WindowsProxyControllerCreationParams(
        const PlatformProxyControllerCreationParams(),
      ),
    );
    return _instance!;
  }

  static final WindowsProxyController _staticValue = WindowsProxyController(
    WindowsProxyControllerCreationParams(
      const PlatformProxyControllerCreationParams(),
    ),
  );

  /// Provide static access.
  factory WindowsProxyController.static() {
    return _staticValue;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {}

  @override
  Future<void> setProxyOverride({required ProxySettings settings}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("settings", () => settings.toMap());
    await channel?.invokeMethod('setProxyOverride', args);
  }

  @override
  Future<void> clearProxyOverride() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await channel?.invokeMethod('clearProxyOverride', args);
  }

  @override
  void dispose() {
    // empty
  }
}

extension InternalProxyController on WindowsProxyController {
  get handleMethod => _handleMethod;
}
