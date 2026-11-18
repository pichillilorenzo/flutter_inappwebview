import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

///{@macro drago_inappwebview.PlatformWebMessagePort}
///
///{@macro drago_inappwebview.PlatformWebMessagePort.supported_platforms}
class WebMessagePort implements IWebMessagePort {
  ///{@macro drago_inappwebview.PlatformWebMessagePort}
  WebMessagePort({required int index})
    : this.fromPlatformCreationParams(
        params: PlatformWebMessagePortCreationParams(index: index),
      );

  /// Constructs a [WebMessagePort].
  ///
  /// See [WebMessagePort.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  WebMessagePort.fromPlatformCreationParams({
    required PlatformWebMessagePortCreationParams params,
  }) : this.fromPlatform(platform: PlatformWebMessagePort(params));

  /// Constructs a [WebMessagePort] from a specific platform implementation.
  WebMessagePort.fromPlatform({required this.platform});

  /// Implementation of [PlatformWebMessagePort] for the current platform.
  final PlatformWebMessagePort platform;

  ///{@macro drago_inappwebview.PlatformWebMessagePort.setWebMessageCallback}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessagePort.setWebMessageCallback.supported_platforms}
  @override
  Future<void> setWebMessageCallback(WebMessageCallback? onMessage) =>
      platform.setWebMessageCallback(onMessage);

  ///{@macro drago_inappwebview.PlatformWebMessagePort.postMessage}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessagePort.postMessage.supported_platforms}
  @override
  Future<void> postMessage(WebMessage message) => platform.postMessage(message);

  ///{@macro drago_inappwebview.PlatformWebMessagePort.close}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessagePort.close.supported_platforms}
  @override
  Future<void> close() => platform.close();

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) =>
      platform.toMap(enumMethod: enumMethod);

  @override
  Map<String, dynamic> toJson() => platform.toJson();

  @override
  String toString() => platform.toString();
}
