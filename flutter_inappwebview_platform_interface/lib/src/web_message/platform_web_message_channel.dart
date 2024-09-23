import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_platform_interface/src/types/disposable.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../inappwebview_platform.dart';
import 'platform_web_message_port.dart';

/// Object specifying creation parameters for creating a [PlatformWebMessageChannel].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformWebMessageChannelCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebMessageChannel].
  const PlatformWebMessageChannelCreationParams(
      {required this.id, required this.port1, required this.port2});

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannel.id}
  final String id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannel.port1}
  final PlatformWebMessagePort port1;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannel.port2}
  final PlatformWebMessagePort port2;

  @override
  String toString() {
    return 'PlatformWebMessageChannelCreationParams{id: $id, port1: $port1, port2: $port2}';
  }
}

///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannel}
///The representation of the [HTML5 message channels](https://html.spec.whatwg.org/multipage/web-messaging.html#message-channels).
///
///**Officially Supported Platforms/Implementations**:
///- Android native WebView
///- iOS
///- MacOS
///{@endtemplate}
abstract class PlatformWebMessageChannel extends PlatformInterface
    implements Disposable {
  /// Creates a new [PlatformWebMessageChannel]
  factory PlatformWebMessageChannel(
      PlatformWebMessageChannelCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebMessageChannel webMessageChannel =
        InAppWebViewPlatform.instance!.createPlatformWebMessageChannel(params);
    PlatformInterface.verify(webMessageChannel, _token);
    return webMessageChannel;
  }

  /// Creates a new [PlatformWebMessageChannel] to access static methods.
  factory PlatformWebMessageChannel.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebMessageChannel webMessageChannelStatic =
        InAppWebViewPlatform.instance!.createPlatformWebMessageChannelStatic();
    PlatformInterface.verify(webMessageChannelStatic, _token);
    return webMessageChannelStatic;
  }

  /// Used by the platform implementation to create a new [PlatformWebMessageChannel].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformWebMessageChannel.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformWebMessageChannel].
  final PlatformWebMessageChannelCreationParams params;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannel.id}
  ///Message Channel ID used internally.
  ///{@endtemplate}
  String get id => params.id;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannel.port1}
  ///The first [PlatformWebMessagePort] object of the channel.
  ///{@endtemplate}
  PlatformWebMessagePort get port1 => params.port1;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannel.port2}
  ///The second [PlatformWebMessagePort] object of the channel.
  ///{@endtemplate}
  PlatformWebMessagePort get port2 => params.port2;

  PlatformWebMessageChannel? fromMap(Map<String, dynamic>? map) {
    throw UnimplementedError(
        'fromMap is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannel}
  ///Disposes the web message channel.
  ///{@endtemplate}
  @override
  void dispose() {
    throw UnimplementedError(
        'dispose is not implemented on the current platform');
  }

  @override
  String toString() {
    return 'PlatformWebMessageChannel{id: $id, port1: $port1, port2: $port2}';
  }
}
