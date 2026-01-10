import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import 'web_message_channel.dart';

/// Object specifying creation parameters for creating a [LinuxWebMessagePort].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebMessagePortCreationParams] for
/// more information.
@immutable
class LinuxWebMessagePortCreationParams
    extends PlatformWebMessagePortCreationParams {
  /// Creates a new [LinuxWebMessagePortCreationParams] instance.
  const LinuxWebMessagePortCreationParams({required super.index});

  /// Creates a [LinuxWebMessagePortCreationParams] instance based on [PlatformWebMessagePortCreationParams].
  factory LinuxWebMessagePortCreationParams.fromPlatformWebMessagePortCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebMessagePortCreationParams params,
  ) {
    return LinuxWebMessagePortCreationParams(index: params.index);
  }

  @override
  String toString() {
    return 'LinuxWebMessagePortCreationParams{index: $index}';
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformWebMessagePort}
class LinuxWebMessagePort extends PlatformWebMessagePort {
  WebMessageCallback? _onMessage;
  late LinuxWebMessageChannel _webMessageChannel;

  /// Constructs a [LinuxWebMessagePort].
  LinuxWebMessagePort(PlatformWebMessagePortCreationParams params)
    : super.implementation(
        params is LinuxWebMessagePortCreationParams
            ? params
            : LinuxWebMessagePortCreationParams.fromPlatformWebMessagePortCreationParams(
                params,
              ),
      );

  @override
  Future<void> setWebMessageCallback(WebMessageCallback? onMessage) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => params.index);
    await _webMessageChannel.internalChannel?.invokeMethod(
      'setWebMessageCallback',
      args,
    );
    _onMessage = onMessage;
  }

  @override
  Future<void> postMessage(WebMessage message) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => params.index);
    args.putIfAbsent('message', () => message.toMap());
    await _webMessageChannel.internalChannel?.invokeMethod('postMessage', args);
  }

  @override
  Future<void> close() async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('index', () => params.index);
    await _webMessageChannel.internalChannel?.invokeMethod('close', args);
  }

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "index": params.index,
      "webMessageChannelId": _webMessageChannel.params.id,
    };
  }

  @override
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'LinuxWebMessagePort{index: ${params.index}}';
  }
}

extension InternalWebMessagePort on LinuxWebMessagePort {
  WebMessageCallback? get onMessage => _onMessage;
  set onMessage(WebMessageCallback? value) => _onMessage = value;

  LinuxWebMessageChannel get webMessageChannel => _webMessageChannel;
  set webMessageChannel(LinuxWebMessageChannel value) =>
      _webMessageChannel = value;
}
