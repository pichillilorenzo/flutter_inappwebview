import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'web_message_port.dart';

/// Object specifying creation parameters for creating a [LinuxWebMessageChannel].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebMessageChannelCreationParams] for
/// more information.
@immutable
class LinuxWebMessageChannelCreationParams
    extends PlatformWebMessageChannelCreationParams {
  /// Creates a new [LinuxWebMessageChannelCreationParams] instance.
  const LinuxWebMessageChannelCreationParams({
    required super.id,
    required super.port1,
    required super.port2,
  });

  /// Creates a [LinuxWebMessageChannelCreationParams] instance based on [PlatformWebMessageChannelCreationParams].
  factory LinuxWebMessageChannelCreationParams.fromPlatformWebMessageChannelCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebMessageChannelCreationParams params,
  ) {
    return LinuxWebMessageChannelCreationParams(
      id: params.id,
      port1: params.port1,
      port2: params.port2,
    );
  }

  @override
  String toString() {
    return 'LinuxWebMessageChannelCreationParams{id: $id, port1: $port1, port2: $port2}';
  }
}

///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannel}
class LinuxWebMessageChannel extends PlatformWebMessageChannel
    with ChannelController {
  /// Constructs a [LinuxWebMessageChannel].
  LinuxWebMessageChannel(PlatformWebMessageChannelCreationParams params)
    : super.implementation(
        params is LinuxWebMessageChannelCreationParams
            ? params
            : LinuxWebMessageChannelCreationParams.fromPlatformWebMessageChannelCreationParams(
                params,
              ),
      ) {
    channel = MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_web_message_channel_${params.id}',
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  static final LinuxWebMessageChannel _staticValue = LinuxWebMessageChannel(
    LinuxWebMessageChannelCreationParams(
      id: '',
      port1: LinuxWebMessagePort(LinuxWebMessagePortCreationParams(index: 0)),
      port2: LinuxWebMessagePort(LinuxWebMessagePortCreationParams(index: 1)),
    ),
  );

  /// Provide static access.
  factory LinuxWebMessageChannel.static() {
    return _staticValue;
  }

  LinuxWebMessagePort get _linuxPort1 => port1 as LinuxWebMessagePort;

  LinuxWebMessagePort get _linuxPort2 => port2 as LinuxWebMessagePort;

  static LinuxWebMessageChannel? _fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    var webMessageChannel = LinuxWebMessageChannel(
      LinuxWebMessageChannelCreationParams(
        id: map["id"],
        port1: LinuxWebMessagePort(LinuxWebMessagePortCreationParams(index: 0)),
        port2: LinuxWebMessagePort(LinuxWebMessagePortCreationParams(index: 1)),
      ),
    );
    webMessageChannel._linuxPort1.webMessageChannel = webMessageChannel;
    webMessageChannel._linuxPort2.webMessageChannel = webMessageChannel;
    return webMessageChannel;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onMessage":
        int index = call.arguments["index"];
        var port = index == 0 ? _linuxPort1 : _linuxPort2;
        if (port.onMessage != null) {
          WebMessage? message = call.arguments["message"] != null
              ? WebMessage.fromMap(
                  call.arguments["message"].cast<String, dynamic>(),
                )
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
  LinuxWebMessageChannel? fromMap(Map<String, dynamic>? map) {
    return _fromMap(map);
  }

  @override
  void dispose() {
    disposeChannel();
  }

  @override
  String toString() {
    return 'LinuxWebMessageChannel{id: $id, port1: $port1, port2: $port2}';
  }
}

extension InternalWebMessageChannel on LinuxWebMessageChannel {
  MethodChannel? get internalChannel => channel;
}
