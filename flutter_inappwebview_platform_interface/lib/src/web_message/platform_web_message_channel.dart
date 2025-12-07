import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';
import 'package:flutter_inappwebview_platform_interface/src/types/disposable.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../inappwebview_platform.dart';
import 'platform_web_message_port.dart';

// ignore: uri_has_not_been_generated
part 'platform_web_message_channel.g.dart';

///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams}
/// Object specifying creation parameters for creating a [PlatformWebMessageChannel].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.supported_platforms}
@SupportedPlatforms(platforms: [
  AndroidPlatform(),
  IOSPlatform(),
  MacOSPlatform(),
])
@immutable
class PlatformWebMessageChannelCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebMessageChannel].
  const PlatformWebMessageChannelCreationParams(
      {required this.id, required this.port1, required this.port2});

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.id}
  ///Message Channel ID used internally.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.id.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  final String id;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.port1}
  ///The first [PlatformWebMessagePort] object of the channel.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.port1.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  final PlatformWebMessagePort port1;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.port2}
  ///The second [PlatformWebMessagePort] object of the channel.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.port2.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  final PlatformWebMessagePort port2;

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebMessageChannelCreationParamsClassSupported.isClassSupported(
          platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
          PlatformWebMessageChannelCreationParamsProperty property,
          {TargetPlatform? platform}) =>
      _PlatformWebMessageChannelCreationParamsPropertySupported
          .isPropertySupported(property, platform: platform);

  @override
  String toString() {
    return 'PlatformWebMessageChannelCreationParams{id: $id, port1: $port1, port2: $port2}';
  }
}

///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannel}
///The representation of the [HTML5 message channels](https://html.spec.whatwg.org/multipage/web-messaging.html#message-channels).
///{@endtemplate}
///
///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannel.supported_platforms}
@SupportedPlatforms(platforms: [
  AndroidPlatform(),
  IOSPlatform(),
  MacOSPlatform(),
])
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

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.id}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.id.supported_platforms}
  String get id => params.id;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.port1}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.port1.supported_platforms}
  PlatformWebMessagePort get port1 => params.port1;

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.port2}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.port2.supported_platforms}
  PlatformWebMessagePort get port2 => params.port2;

  PlatformWebMessageChannel? fromMap(Map<String, dynamic>? map) {
    throw UnimplementedError(
        'fromMap is not implemented on the current platform');
  }

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannel.dispose}
  ///Disposes the web message channel.
  ///{@endtemplate}
  ///
  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannel.dispose.supported_platforms}
  @SupportedPlatforms(platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
  ])
  @override
  void dispose() {
    throw UnimplementedError(
        'dispose is not implemented on the current platform');
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformWebMessageChannelCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebMessageChannelClassSupported.isClassSupported(
          platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannel.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
          PlatformWebMessageChannelCreationParamsProperty property,
          {TargetPlatform? platform}) =>
      params.isPropertySupported(property, platform: platform);

  ///{@template flutter_inappwebview_platform_interface.PlatformWebMessageChannel.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(PlatformWebMessageChannelMethod method,
          {TargetPlatform? platform}) =>
      _PlatformWebMessageChannelMethodSupported.isMethodSupported(method,
          platform: platform);

  @override
  String toString() {
    return 'PlatformWebMessageChannel{id: $id, port1: $port1, port2: $port2}';
  }
}
