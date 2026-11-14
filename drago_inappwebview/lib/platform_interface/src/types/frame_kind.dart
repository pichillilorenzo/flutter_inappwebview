import 'package:flutter/foundation.dart';
import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

part 'frame_kind.g.dart';

///Class used to indicate the the frame kind.
@ExchangeableEnum()
class FrameKind_ {
  // ignore: unused_field
  final String _value;
  // ignore: unused_field
  final int? _nativeValue = null;
  const FrameKind_._internal(this._value);

  ///Indicates that the frame is an unknown type frame. We may extend this enum type to identify more frame kinds in the future.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_FRAME_KIND_UNKNOWN',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_frame_kind',
        value: 0,
      ),
    ],
  )
  static const UNKNOWN = FrameKind_._internal('UNKNOWN');

  ///Indicates that the frame is a primary main frame(webview).
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_FRAME_KIND_MAIN_FRAME',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_frame_kind',
        value: 1,
      ),
    ],
  )
  static const MAIN_FRAME = FrameKind_._internal('MAIN_FRAME');

  ///Indicates that the frame is an iframe.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_FRAME_KIND_IFRAME',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_frame_kind',
        value: 2,
      ),
    ],
  )
  static const IFRAME = FrameKind_._internal('IFRAME');

  ///Indicates that the frame is an embed element.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_FRAME_KIND_EMBED',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_frame_kind',
        value: 3,
      ),
    ],
  )
  static const EMBED = FrameKind_._internal('EMBED');

  ///Indicates that the frame is an object element.
  @EnumSupportedPlatforms(
    platforms: [
      EnumWindowsPlatform(
        apiName: 'COREWEBVIEW2_FRAME_KIND_OBJECT',
        apiUrl:
            'https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/webview2-idl?view=webview2-1.0.2849.39#corewebview2_frame_kind',
        value: 4,
      ),
    ],
  )
  static const OBJECT = FrameKind_._internal('OBJECT');
}
