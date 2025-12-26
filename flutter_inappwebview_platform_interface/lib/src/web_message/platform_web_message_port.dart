import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../inappwebview_platform.dart';
import '../types/enum_method.dart';
import '../types/web_message_callback.dart';
import 'web_message.dart';

/// Object specifying creation parameters for creating a [PlatformWebMessagePort].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@immutable
class PlatformWebMessagePortCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebMessagePort].
  const PlatformWebMessagePortCreationParams({required this.index});

  ///Port index.
  final int index;

  @override
  String toString() {
    return 'PlatformWebMessagePortCreationParams{index: $index}';
  }
}

///{@template flutter_inappwebview_platform_interface.PlatformWebMessagePort}
///The representation of the [HTML5 message ports](https://html.spec.whatwg.org/multipage/comms.html#messageport).
///
///A Message port represents one endpoint of a Message Channel. In Android webview, there is no separate Message Channel object.
///When a message channel is created, both ports are tangled to each other and started.
///See [InAppWebViewController.createWebMessageChannel] for creating a message channel.
///
///When a message port is first created or received via transfer, it does not have a [WebMessageCallback] to receive web messages.
///On Android, the messages are queued until a [WebMessageCallback] is set.
///
///A message port should be closed when it is not used by the embedder application anymore.
///A closed port cannot be transferred or cannot be reopened to send messages.
///Close can be called multiple times.
///
///When a port is transferred to JavaScript, it cannot be used to send or receive messages at the Dart side anymore.
///Different from HTML5 Spec, a port cannot be transferred if one of these has ever happened: i. a message callback was set, ii. a message was posted on it.
///A transferred port cannot be closed by the application, since the ownership is also transferred.
///
///It is possible to transfer both ports of a channel to JavaScript, for example for communication between subframes.
///{@endtemplate}
abstract class PlatformWebMessagePort extends PlatformInterface
    implements IWebMessagePort {
  /// Creates a new [PlatformWebMessagePort]
  factory PlatformWebMessagePort(PlatformWebMessagePortCreationParams params) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebMessagePort webMessagePort =
        InAppWebViewPlatform.instance!.createPlatformWebMessagePort(params);
    PlatformInterface.verify(webMessagePort, _token);
    return webMessagePort;
  }

  /// Used by the platform implementation to create a new [PlatformWebMessagePort].
  ///
  /// Should only be used by platform implementations because they can't extend
  /// a class that only contains a factory constructor.
  @protected
  PlatformWebMessagePort.implementation(this.params) : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformWebMessagePort].
  final PlatformWebMessagePortCreationParams params;

  @override
  String toString() {
    return 'PlatformWebMessagePort{index: ${params.index}}';
  }
}

abstract class IWebMessagePort {
  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessagePort.setWebMessageCallback}
  ///Sets a callback to receive message events on the main thread.
  ///{@endtemplate}
  Future<void> setWebMessageCallback(WebMessageCallback? onMessage) {
    throw UnimplementedError(
        'setWebMessageCallback is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessagePort.postMessage}
  ///Post a WebMessage to the entangled port.
  ///{@endtemplate}
  Future<void> postMessage(WebMessage message) {
    throw UnimplementedError(
        'postMessage is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessagePort.close}
  ///Close the message port and free any resources associated with it.
  ///{@endtemplate}
  Future<void> close() {
    throw UnimplementedError(
        'close is not implemented on the current platform');
  }

  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    throw UnimplementedError(
        'toMap is not implemented on the current platform');
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError(
        'toJson is not implemented on the current platform');
  }
}
