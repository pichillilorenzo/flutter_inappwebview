import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';
import 'package:drago_inappwebview/platform_interface/src/types/disposable.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../inappwebview_platform.dart';
import 'platform_web_message_port.dart';

// ignore: uri_has_not_been_generated
part 'platform_web_message_channel.g.dart';

///{@template drago_inappwebview.PlatformWebMessageChannelCreationParams}
/// Object specifying creation parameters for creating a [PlatformWebMessageChannel].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
///{@endtemplate}
///
///{@macro drago_inappwebview.PlatformWebMessageChannelCreationParams.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    LinuxPlatform(note: 'Implemented via JavaScript MessageChannel API.'),
    WindowsPlatform(note: 'Implemented via JavaScript MessageChannel API.'),
  ],
)
@immutable
class PlatformWebMessageChannelCreationParams {
  /// Used by the platform implementation to create a new [PlatformWebMessageChannel].
  const PlatformWebMessageChannelCreationParams({
    required this.id,
    required this.port1,
    required this.port2,
  });

  ///{@template drago_inappwebview.PlatformWebMessageChannelCreationParams.id}
  ///Message Channel ID used internally.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessageChannelCreationParams.id.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(note: 'Implemented via JavaScript MessageChannel API.'),
      WindowsPlatform(note: 'Implemented via JavaScript MessageChannel API.'),
    ],
  )
  final String id;

  ///{@template drago_inappwebview.PlatformWebMessageChannelCreationParams.port1}
  ///The first [PlatformWebMessagePort] object of the channel.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessageChannelCreationParams.port1.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(note: 'Implemented via JavaScript MessageChannel API.'),
      WindowsPlatform(note: 'Implemented via JavaScript MessageChannel API.'),
    ],
  )
  final PlatformWebMessagePort port1;

  ///{@template drago_inappwebview.PlatformWebMessageChannelCreationParams.port2}
  ///The second [PlatformWebMessagePort] object of the channel.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessageChannelCreationParams.port2.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(note: 'Implemented via JavaScript MessageChannel API.'),
      WindowsPlatform(note: 'Implemented via JavaScript MessageChannel API.'),
    ],
  )
  final PlatformWebMessagePort port2;

  ///{@template drago_inappwebview.PlatformWebMessageChannelCreationParams.isClassSupported}
  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebMessageChannelCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template drago_inappwebview.PlatformWebMessageChannelCreationParams.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformWebMessageChannelCreationParamsProperty property, {
    TargetPlatform? platform,
  }) =>
      _PlatformWebMessageChannelCreationParamsPropertySupported.isPropertySupported(
        property,
        platform: platform,
      );

  @override
  String toString() {
    return 'PlatformWebMessageChannelCreationParams{id: $id, port1: $port1, port2: $port2}';
  }
}

///{@template drago_inappwebview.PlatformWebMessageChannel}
///The representation of the [HTML5 message channels](https://html.spec.whatwg.org/multipage/web-messaging.html#message-channels).
///{@endtemplate}
///
///{@macro drago_inappwebview.PlatformWebMessageChannel.supported_platforms}
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(),
    IOSPlatform(),
    MacOSPlatform(),
    LinuxPlatform(note: 'Implemented via JavaScript MessageChannel API.'),
    WindowsPlatform(note: 'Implemented via JavaScript MessageChannel API.'),
  ],
)
abstract class PlatformWebMessageChannel extends PlatformInterface
    implements Disposable {
  /// Creates a new [PlatformWebMessageChannel]
  factory PlatformWebMessageChannel(
    PlatformWebMessageChannelCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `drago_inappwebview` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set to '
      '`InAppWebViewPlatform.instance` before use. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final PlatformWebMessageChannel webMessageChannel = InAppWebViewPlatform
        .instance!
        .createPlatformWebMessageChannel(params);
    PlatformInterface.verify(webMessageChannel, _token);
    return webMessageChannel;
  }

  /// Creates a new [PlatformWebMessageChannel] to access static methods.
  factory PlatformWebMessageChannel.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `drago_inappwebview` has not been set. Please '
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

  ///{@macro drago_inappwebview.PlatformWebMessageChannelCreationParams.id}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessageChannelCreationParams.id.supported_platforms}
  String get id => params.id;

  ///{@macro drago_inappwebview.PlatformWebMessageChannelCreationParams.port1}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessageChannelCreationParams.port1.supported_platforms}
  PlatformWebMessagePort get port1 => params.port1;

  ///{@macro drago_inappwebview.PlatformWebMessageChannelCreationParams.port2}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessageChannelCreationParams.port2.supported_platforms}
  PlatformWebMessagePort get port2 => params.port2;

  PlatformWebMessageChannel? fromMap(Map<String, dynamic>? map) {
    throw UnimplementedError(
      'fromMap is not implemented on the current platform',
    );
  }

  ///{@template drago_inappwebview.PlatformWebMessageChannel.dispose}
  ///Disposes the web message channel.
  ///{@endtemplate}
  ///
  ///{@macro drago_inappwebview.PlatformWebMessageChannel.dispose.supported_platforms}
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      LinuxPlatform(note: 'Implemented via JavaScript MessageChannel API.'),
      WindowsPlatform(note: 'Implemented via JavaScript MessageChannel API.'),
    ],
  )
  @override
  void dispose() {
    throw UnimplementedError(
      'dispose is not implemented on the current platform',
    );
  }

  ///{@macro drago_inappwebview.PlatformWebMessageChannelCreationParams.isClassSupported}
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformWebMessageChannelClassSupported.isClassSupported(
        platform: platform,
      );

  ///{@template drago_inappwebview.PlatformWebMessageChannel.isPropertySupported}
  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isPropertySupported(
    PlatformWebMessageChannelCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => params.isPropertySupported(property, platform: platform);

  ///{@template drago_inappwebview.PlatformWebMessageChannel.isMethodSupported}
  ///Check if the given [method] is supported by the [defaultTargetPlatform] or a specific [platform].
  ///{@endtemplate}
  bool isMethodSupported(
    PlatformWebMessageChannelMethod method, {
    TargetPlatform? platform,
  }) => _PlatformWebMessageChannelMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );

  @override
  String toString() {
    return 'PlatformWebMessageChannel{id: $id, port1: $port1, port2: $port2}';
  }
}
