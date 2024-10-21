import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

class IosProxyControllerCreationParams extends PlatformProxyControllerCreationParams {
  /// Creates a new [IosProxyControllerCreationParams] instance.
  const IosProxyControllerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformProxyControllerCreationParams params,
  ) : super();

  /// Creates a [IosProxyControllerCreationParams] instance based on [PlatformProxyControllerCreationParams].
  factory IosProxyControllerCreationParams.fromPlatformProxyControllerCreationParams(
    PlatformProxyControllerCreationParams params,
  ) {
    return IosProxyControllerCreationParams(params);
  }
}

class IosProxyController extends PlatformProxyController with ChannelController {
  IosProxyController(PlatformProxyControllerCreationParams params)
      : super.implementation(
          params is IosProxyControllerCreationParams
              ? params
              : IosProxyControllerCreationParams.fromPlatformProxyControllerCreationParams(params),
        ) {
    channel = const MethodChannel('com.pichillilorenzo/flutter_inappwebview_proxycontroller');
    handler = _handleMethod;
    initMethodCallHandler();
  }

  static IosProxyController? _instance;

  static IosProxyController instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static IosProxyController _init() {
    _instance = IosProxyController(IosProxyControllerCreationParams(const PlatformProxyControllerCreationParams()));
    return _instance!;
  }

  @override
  Future<void> setProxyOverride({required ProxySettings settings}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("settings", () => settings.iOSProxySettings?.toMap());
    await channel?.invokeMethod('setProxyOverride', args);
  }

  @override
  Future<void> clearProxyOverride() async {
    await channel?.invokeMethod('clearProxyOverride');
  }

  Future<dynamic> _handleMethod(MethodCall call) async {}

  @override
  void dispose() {
    // empty.
  }
}
