import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

part 'window_style_mask.g.dart';

///Class that represents the flags that describe the browser window’s current style, such as if it’s resizable or in full-screen mode.
@ExchangeableEnum(bitwiseOrOperator: true)
class WindowStyleMask_ {
  // ignore: unused_field
  final int _value;
  // ignore: unused_field
  final int? _nativeValue = null;
  const WindowStyleMask_._internal(this._value);

  ///The window displays none of the usual peripheral elements. Useful only for display or caching purposes.
  @EnumSupportedPlatforms(
    platforms: [
      EnumMacOSPlatform(
        value: 0,
        apiName: "NSWindow.StyleMask.borderless",
        apiUrl:
            "https://developer.apple.com/documentation/appkit/nswindow/stylemask/1644698-borderless",
      ),
    ],
  )
  static const BORDERLESS = const WindowStyleMask_._internal(0);

  ///The window displays a title bar.
  @EnumSupportedPlatforms(
    platforms: [
      EnumMacOSPlatform(
        value: 1,
        apiName: "NSWindow.StyleMask.titled",
        apiUrl:
            "https://developer.apple.com/documentation/appkit/nswindow/stylemask/1644724-titled",
      ),
    ],
  )
  static const TITLED = const WindowStyleMask_._internal(1);

  ///The window displays a close button.
  @EnumSupportedPlatforms(
    platforms: [
      EnumMacOSPlatform(
        value: 2,
        apiName: "NSWindow.StyleMask.closable",
        apiUrl:
            "https://developer.apple.com/documentation/appkit/nswindow/stylemask/1644610-closable",
      ),
    ],
  )
  static const CLOSABLE = const WindowStyleMask_._internal(2);

  ///The window displays a minimize button.
  @EnumSupportedPlatforms(
    platforms: [
      EnumMacOSPlatform(
        value: 4,
        apiName: "NSWindow.StyleMask.miniaturizable",
        apiUrl:
            "https://developer.apple.com/documentation/appkit/nswindow/stylemask/1644650-miniaturizable",
      ),
    ],
  )
  static const MINIATURIZABLE = const WindowStyleMask_._internal(4);

  ///The window can be resized by the user.
  @EnumSupportedPlatforms(
    platforms: [
      EnumMacOSPlatform(
        value: 8,
        apiName: "NSWindow.StyleMask.miniaturizable",
        apiUrl:
            "https://developer.apple.com/documentation/appkit/nswindow/stylemask/1644717-resizable",
      ),
    ],
  )
  static const RESIZABLE = const WindowStyleMask_._internal(8);

  ///The window can appear full screen. A fullscreen window does not draw its title bar, and may have special handling for its toolbar.
  @EnumSupportedPlatforms(
    platforms: [
      EnumMacOSPlatform(
        value: 16384,
        apiName: "NSWindow.StyleMask.fullScreen",
        apiUrl:
            "https://developer.apple.com/documentation/appkit/nswindow/stylemask/1644530-fullscreen",
      ),
    ],
  )
  static const FULLSCREEN = const WindowStyleMask_._internal(16384);

  ///When set, the window’s contentView consumes the full size of the window.
  ///Although you can combine this constant with other window style masks, it is respected only for windows with a title bar.
  ///Note that using this mask opts in to layer-backing.
  @EnumSupportedPlatforms(
    platforms: [
      EnumMacOSPlatform(
        value: 32768,
        apiName: "NSWindow.StyleMask.fullSizeContentView",
        apiUrl:
            "https://developer.apple.com/documentation/appkit/nswindow/stylemask/1644646-fullsizecontentview",
      ),
    ],
  )
  static const FULL_SIZE_CONTENT_VIEW = const WindowStyleMask_._internal(32768);

  ///The window is a panel.
  @EnumSupportedPlatforms(
    platforms: [
      EnumMacOSPlatform(
        value: 16,
        apiName: "NSWindow.StyleMask.utilityWindow",
        apiUrl:
            "https://developer.apple.com/documentation/appkit/nswindow/stylemask/1644672-utilitywindow",
      ),
    ],
  )
  static const UTILITY_WINDOW = const WindowStyleMask_._internal(16);

  ///The window is a document-modal panel.
  @EnumSupportedPlatforms(
    platforms: [
      EnumMacOSPlatform(
        value: 64,
        apiName: "NSWindow.StyleMask.docModalWindow",
        apiUrl:
            "https://developer.apple.com/documentation/appkit/nswindow/stylemask/1644253-docmodalwindow",
      ),
    ],
  )
  static const DOC_MODAL_WINDOW = const WindowStyleMask_._internal(64);

  ///The window is a panel that does not activate the owning app.
  @EnumSupportedPlatforms(
    platforms: [
      EnumMacOSPlatform(
        value: 128,
        apiName: "NSWindow.StyleMask.nonactivatingPanel",
        apiUrl:
            "https://developer.apple.com/documentation/appkit/nswindow/stylemask/1644696-nonactivatingpanel",
      ),
    ],
  )
  static const NONACTIVATING_PANEL = const WindowStyleMask_._internal(128);

  ///The window is a HUD panel.
  @EnumSupportedPlatforms(
    platforms: [
      EnumMacOSPlatform(
        value: 8192,
        apiName: "NSWindow.StyleMask.hudWindow",
        apiUrl:
            "https://developer.apple.com/documentation/appkit/nswindow/stylemask/1644653-hudwindow",
      ),
    ],
  )
  static const HUD_WINDOW = const WindowStyleMask_._internal(8192);
}
