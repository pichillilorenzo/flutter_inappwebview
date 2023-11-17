import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'web_message_port.dart';

///The representation of the [HTML5 message channels](https://html.spec.whatwg.org/multipage/web-messaging.html#message-channels).
///
///**Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
class WebMessageChannel {
  WebMessageChannel(
      {required String id,
      required WebMessagePort port1,
      required WebMessagePort port2})
      : this.fromPlatformCreationParams(
            params: PlatformWebMessageChannelCreationParams(
                id: id, port1: port1.platform, port2: port2.platform));

  /// Constructs a [WebMessageChannel].
  ///
  /// See [WebMessageChannel.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  WebMessageChannel.fromPlatformCreationParams({
    required PlatformWebMessageChannelCreationParams params,
  }) : this.fromPlatform(platform: PlatformWebMessageChannel(params));

  /// Constructs a [WebMessageChannel] from a specific platform implementation.
  WebMessageChannel.fromPlatform({required this.platform});

  /// Implementation of [PlatformWebMessageChannel] for the current platform.
  final PlatformWebMessageChannel platform;

  static PlatformWebMessageChannel? fromMap(Map<String, dynamic>? map) => PlatformWebMessageChannel.static().fromMap(map);

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannel.id}
  String get id => platform.id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannel.port1}
  PlatformWebMessagePort get port1 => platform.port1;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannel.port2}
  PlatformWebMessagePort get port2 => platform.port2;

  ///Disposes the web message channel.
  void dispose() => platform.dispose();

  @override
  String toString() => platform.toString();
}
