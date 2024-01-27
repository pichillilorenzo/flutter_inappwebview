import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'web_message_port.dart';

/// Object specifying creation parameters for creating a [WindowsWebMessageChannel].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebMessageChannelCreationParams] for
/// more information.
@immutable
class MacOSWebMessageChannelCreationParams
    extends PlatformWebMessageChannelCreationParams {
  /// Creates a new [MacOSWebMessageChannelCreationParams] instance.
  const MacOSWebMessageChannelCreationParams(
      {required super.id, required super.port1, required super.port2});

  /// Creates a [MacOSWebMessageChannelCreationParams] instance based on [PlatformWebMessageChannelCreationParams].
  factory MacOSWebMessageChannelCreationParams.fromPlatformWebMessageChannelCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformWebMessageChannelCreationParams params) {
    return MacOSWebMessageChannelCreationParams(
        id: params.id, port1: params.port1, port2: params.port2);
  }

  @override
  String toString() {
    return 'MacOSWebMessageChannelCreationParams{id: $id, port1: $port1, port2: $port2}';
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannel}
class WindowsWebMessageChannel extends PlatformWebMessageChannel
    with ChannelController {
  /// Constructs a [WindowsWebMessageChannel].
  WindowsWebMessageChannel(PlatformWebMessageChannelCreationParams params)
      : super.implementation(
          params is MacOSWebMessageChannelCreationParams
              ? params
              : MacOSWebMessageChannelCreationParams
                  .fromPlatformWebMessageChannelCreationParams(params),
        ) {
    channel = MethodChannel(
        'com.pichillilorenzo/flutter_inappwebview_web_message_channel_${params.id}');
    handler = _handleMethod;
    initMethodCallHandler();
  }

  static final WindowsWebMessageChannel _staticValue = WindowsWebMessageChannel(
      MacOSWebMessageChannelCreationParams(
          id: '',
          port1:
              MacOSWebMessagePort(MacOSWebMessagePortCreationParams(index: 0)),
          port2: MacOSWebMessagePort(
              MacOSWebMessagePortCreationParams(index: 1))));

  /// Provide static access.
  factory WindowsWebMessageChannel.static() {
    return _staticValue;
  }

  MacOSWebMessagePort get _macosPort1 => port1 as MacOSWebMessagePort;

  MacOSWebMessagePort get _macosPort2 => port2 as MacOSWebMessagePort;

  static WindowsWebMessageChannel? _fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    var webMessageChannel = WindowsWebMessageChannel(
        MacOSWebMessageChannelCreationParams(
            id: map["id"],
            port1: MacOSWebMessagePort(
                MacOSWebMessagePortCreationParams(index: 0)),
            port2: MacOSWebMessagePort(
                MacOSWebMessagePortCreationParams(index: 1))));
    webMessageChannel._macosPort1.webMessageChannel = webMessageChannel;
    webMessageChannel._macosPort2.webMessageChannel = webMessageChannel;
    return webMessageChannel;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onMessage":
        int index = call.arguments["index"];
        var port = index == 0 ? _macosPort1 : _macosPort2;
        if (port.onMessage != null) {
          WebMessage? message = call.arguments["message"] != null
              ? WebMessage.fromMap(
                  call.arguments["message"].cast<String, dynamic>())
              : null;
          port.onMessage!(message);
        }
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  @override
  WindowsWebMessageChannel? fromMap(Map<String, dynamic>? map) {
    return _fromMap(map);
  }

  @override
  void dispose() {
    disposeChannel();
  }

  @override
  String toString() {
    return 'MacOSWebMessageChannel{id: $id, port1: $port1, port2: $port2}';
  }
}

extension InternalWebMessageChannel on WindowsWebMessageChannel {
  MethodChannel? get internalChannel => channel;
}
