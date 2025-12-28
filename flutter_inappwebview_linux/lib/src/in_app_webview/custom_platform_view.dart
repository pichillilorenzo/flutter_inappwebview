import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '_static_channel.dart';

const Map<String, SystemMouseCursor> _cursors = {
  'none': SystemMouseCursors.none,
  'basic': SystemMouseCursors.basic,
  'click': SystemMouseCursors.click,
  'forbidden': SystemMouseCursors.forbidden,
  'wait': SystemMouseCursors.wait,
  'progress': SystemMouseCursors.progress,
  'contextMenu': SystemMouseCursors.contextMenu,
  'help': SystemMouseCursors.help,
  'text': SystemMouseCursors.text,
  'verticalText': SystemMouseCursors.verticalText,
  'cell': SystemMouseCursors.cell,
  'precise': SystemMouseCursors.precise,
  'move': SystemMouseCursors.move,
  'grab': SystemMouseCursors.grab,
  'grabbing': SystemMouseCursors.grabbing,
  'noDrop': SystemMouseCursors.noDrop,
  'alias': SystemMouseCursors.alias,
  'copy': SystemMouseCursors.copy,
  'disappearing': SystemMouseCursors.disappearing,
  'allScroll': SystemMouseCursors.allScroll,
  'resizeLeftRight': SystemMouseCursors.resizeLeftRight,
  'resizeUpDown': SystemMouseCursors.resizeUpDown,
  'resizeUpLeftDownRight': SystemMouseCursors.resizeUpLeftDownRight,
  'resizeUpRightDownLeft': SystemMouseCursors.resizeUpRightDownLeft,
  'resizeUp': SystemMouseCursors.resizeUp,
  'resizeDown': SystemMouseCursors.resizeDown,
  'resizeLeft': SystemMouseCursors.resizeLeft,
  'resizeRight': SystemMouseCursors.resizeRight,
  'resizeUpLeft': SystemMouseCursors.resizeUpLeft,
  'resizeUpRight': SystemMouseCursors.resizeUpRight,
  'resizeDownLeft': SystemMouseCursors.resizeDownLeft,
  'resizeDownRight': SystemMouseCursors.resizeDownRight,
  'resizeColumn': SystemMouseCursors.resizeColumn,
  'resizeRow': SystemMouseCursors.resizeRow,
  'zoomIn': SystemMouseCursors.zoomIn,
  'zoomOut': SystemMouseCursors.zoomOut,
};

SystemMouseCursor _getCursorByName(String name) =>
    _cursors[name] ?? SystemMouseCursors.basic;

/// Pointer button type
enum PointerButton { none, primary, secondary, tertiary }

/// Pointer Event kind
enum InAppWebViewPointerEventKind {
  activate,
  down,
  enter,
  leave,
  up,
  update,
  cancel
}

/// Attempts to translate a button constant such as [kPrimaryMouseButton]
/// to a [PointerButton]
PointerButton _getButton(int value) {
  switch (value) {
    case kPrimaryMouseButton:
      return PointerButton.primary;
    case kSecondaryMouseButton:
      return PointerButton.secondary;
    case kTertiaryButton:
      return PointerButton.tertiary;
    default:
      return PointerButton.none;
  }
}

const MethodChannel _pluginChannel = IN_APP_WEBVIEW_STATIC_CHANNEL;

class CustomFlutterViewControllerValue {
  const CustomFlutterViewControllerValue({
    required this.isInitialized,
  });

  final bool isInitialized;

  CustomFlutterViewControllerValue copyWith({
    bool? isInitialized,
  }) {
    return CustomFlutterViewControllerValue(
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  CustomFlutterViewControllerValue.uninitialized()
      : this(
          isInitialized: false,
        );
}

/// Controls a WebView and provides streams for various change events.
class CustomPlatformViewController
    extends ValueNotifier<CustomFlutterViewControllerValue> {
  Completer<void> _creatingCompleter = Completer<void>();
  int _textureId = 0;
  bool _isDisposed = false;

  Future<void> get ready => _creatingCompleter.future;

  late MethodChannel _methodChannel;
  late EventChannel _eventChannel;
  StreamSubscription? _eventStreamSubscription;

  final StreamController<SystemMouseCursor> _cursorStreamController =
      StreamController<SystemMouseCursor>.broadcast();

  /// A stream reflecting the current cursor style.
  Stream<SystemMouseCursor> get _cursor => _cursorStreamController.stream;

  CustomPlatformViewController()
      : super(CustomFlutterViewControllerValue.uninitialized());

  /// Initializes the underlying platform view.
  Future<void> initialize(
      {Function(int id)? onPlatformViewCreated, dynamic arguments}) async {
    if (_isDisposed) {
      return;
    }
    _textureId = (await _pluginChannel.invokeMethod<int>(
        'createInAppWebView', arguments))!;

    _methodChannel =
        MethodChannel('com.pichillilorenzo/custom_platform_view_$_textureId');
    _eventChannel = EventChannel(
        'com.pichillilorenzo/custom_platform_view_${_textureId}_events');
    _eventStreamSubscription =
        _eventChannel.receiveBroadcastStream().listen((event) {
      final map = event as Map<dynamic, dynamic>;
      switch (map['type']) {
        case 'cursorChanged':
          _cursorStreamController.add(_getCursorByName(map['value']));
          break;
      }
    });

    _methodChannel.setMethodCallHandler((call) {
      throw MissingPluginException('Unknown method ${call.method}');
    });

    value = value.copyWith(isInitialized: true);

    _creatingCompleter.complete();

    onPlatformViewCreated?.call(_textureId);
  }

  @override
  Future<void> dispose() async {
    await _creatingCompleter.future;
    if (!_isDisposed) {
      _isDisposed = true;
      await _eventStreamSubscription?.cancel();
      await _pluginChannel.invokeMethod('dispose', {"id": _textureId});
    }
    super.dispose();
  }

  /// Sets the surface size to the provided [size].
  Future<void> _setSize(Size size, double scaleFactor) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel
        .invokeMethod('setSize', [size.width, size.height, scaleFactor]);
  }

  /// Moves the virtual cursor to [position].
  Future<void> _setCursorPos(Offset position) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel
        .invokeMethod('setCursorPos', [position.dx, position.dy]);
  }

  /// Indicates whether the specified [button] is currently down.
  Future<void> _setPointerButtonState(
      InAppWebViewPointerEventKind kind, PointerButton button) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setPointerButton',
        <String, dynamic>{'kind': kind.index, 'button': button.index, 'clickCount': 1});
  }

  /// Indicates whether the specified [button] is currently down with click count.
  Future<void> _setPointerButtonStateWithClickCount(
      InAppWebViewPointerEventKind kind, PointerButton button, int clickCount) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setPointerButton',
        <String, dynamic>{'kind': kind.index, 'button': button.index, 'clickCount': clickCount});
  }

  /// Sets the horizontal and vertical scroll delta.
  Future<void> _setScrollDelta(double dx, double dy) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setScrollDelta', [dx, dy]);
  }

  /// Sends a key event to the webview.
  Future<void> _sendKeyEvent(int type, int keyCode, int scanCode, int modifiers, String? characters) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('sendKeyEvent', <String, dynamic>{
      'type': type,  // 0=press, 1=release
      'keyCode': keyCode,
      'scanCode': scanCode,
      'modifiers': modifiers,
      'characters': characters,
    });
  }
}

class CustomPlatformView extends StatefulWidget {
  /// An optional scale factor. Defaults to [FlutterView.devicePixelRatio] for
  /// rendering in native resolution.
  /// Setting this to 1.0 will disable high-DPI support.
  final double? scaleFactor;

  /// The [FilterQuality] used for scaling the texture's contents.
  /// Defaults to [FilterQuality.none] as this renders in native resolution.
  final FilterQuality filterQuality;

  final dynamic creationParams;

  final Function(int id)? onPlatformViewCreated;

  const CustomPlatformView(
      {this.creationParams,
      this.onPlatformViewCreated,
      this.scaleFactor,
      this.filterQuality = FilterQuality.none,
      Key? key})
      : super(key: key);

  @override
  _CustomPlatformViewState createState() => _CustomPlatformViewState();
}

class _CustomPlatformViewState extends State<CustomPlatformView> {
  final GlobalKey _key = GlobalKey();
  final _downButtons = <int, PointerButton>{};

  PointerDeviceKind _pointerKind = PointerDeviceKind.unknown;

  MouseCursor _cursor = SystemMouseCursors.basic;

  final _controller = CustomPlatformViewController();
  final _focusNode = FocusNode();

  StreamSubscription? _cursorSubscription;

  // Track click timing for double-click detection
  DateTime? _lastClickTime;
  Offset? _lastClickPosition;
  int _clickCount = 0;
  static const _doubleClickTimeout = Duration(milliseconds: 400);
  static const _doubleClickDistance = 5.0;

  @override
  void initState() {
    super.initState();

    _controller.initialize(
        onPlatformViewCreated: (id) {
          widget.onPlatformViewCreated?.call(id);
          setState(() {});
        },
        arguments: widget.creationParams);

    // Report initial surface size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportSurfaceSize();
    });

    _cursorSubscription = _controller._cursor.listen((cursor) {
      setState(() {
        _cursor = cursor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      focusNode: _focusNode,
      canRequestFocus: true,
      debugLabel: "flutter_inappwebview_linux_custom_platform_view",
      onFocusChange: (focused) {},
      onKeyEvent: _handleKeyEvent,
      child: SizedBox.expand(key: _key, child: _buildInner()),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_controller.value.isInitialized) {
      return KeyEventResult.ignored;
    }

    // Determine event type: 0=press, 1=release
    int type;
    if (event is KeyDownEvent) {
      type = 0;
    } else if (event is KeyUpEvent) {
      type = 1;
    } else if (event is KeyRepeatEvent) {
      type = 2;  // Repeat event
    } else {
      return KeyEventResult.ignored;
    }

    // Build modifiers bitmask first - we need this for keyCode logic
    int modifiers = 0;
    if (HardwareKeyboard.instance.isShiftPressed) modifiers |= 1;
    if (HardwareKeyboard.instance.isControlPressed) modifiers |= 2;
    if (HardwareKeyboard.instance.isAltPressed) modifiers |= 4;
    if (HardwareKeyboard.instance.isMetaPressed) modifiers |= 8;

    // Get key information
    // For WPE, we need X11 keysym values. Flutter's logicalKey.keyId uses a different scheme.
    int keyCode;
    String? characters = event.character;
    
    // For Ctrl/Meta combinations, use the base key code without the character
    // This ensures shortcuts like Ctrl+A, Ctrl+C work correctly
    final hasControlOrMeta = (modifiers & 0xA) != 0;  // Ctrl=2 or Meta=8
    
    // Check for special keys first - these should always use X11 keysyms
    final specialKeysym = _flutterKeyToX11Keysym(event.logicalKey);
    final isSpecialKey = specialKeysym >= 0xff00 || specialKeysym < 0x20;
    
    if (hasControlOrMeta || isSpecialKey) {
      // For shortcuts or special keys, use the X11 keysym
      keyCode = specialKeysym;
      if (hasControlOrMeta) {
        characters = null;  // Don't send character for shortcuts
      }
    } else if (event.character != null && event.character!.isNotEmpty && 
               event.character!.codeUnitAt(0) >= 0x20) {
      // Use the character's Unicode code point as keysym (valid for printable chars)
      keyCode = event.character!.codeUnitAt(0);
    } else {
      // Fallback to key mapping
      keyCode = specialKeysym;
    }
    
    // Use physical key's USB HID usage - the C++ side will convert if needed
    final scanCode = event.physicalKey.usbHidUsage & 0xFFFF;

    _controller._sendKeyEvent(type, keyCode, scanCode, modifiers, characters);

    return KeyEventResult.handled;
  }

  /// Map Flutter LogicalKeyboardKey to X11 keysym
  int _flutterKeyToX11Keysym(LogicalKeyboardKey key) {
    // Use keyId-based lookup since LogicalKeyboardKey can't be used as const map key
    final keyId = key.keyId;
    
    // Common special keys mapping to X11 keysyms (using keyId values)
    // These keyIds are from Flutter's LogicalKeyboardKey constants
    if (keyId == LogicalKeyboardKey.backspace.keyId) return 0xff08;
    if (keyId == LogicalKeyboardKey.tab.keyId) return 0xff09;
    if (keyId == LogicalKeyboardKey.enter.keyId) return 0xff0d;
    if (keyId == LogicalKeyboardKey.escape.keyId) return 0xff1b;
    if (keyId == LogicalKeyboardKey.delete.keyId) return 0xffff;
    if (keyId == LogicalKeyboardKey.home.keyId) return 0xff50;
    if (keyId == LogicalKeyboardKey.arrowLeft.keyId) return 0xff51;
    if (keyId == LogicalKeyboardKey.arrowUp.keyId) return 0xff52;
    if (keyId == LogicalKeyboardKey.arrowRight.keyId) return 0xff53;
    if (keyId == LogicalKeyboardKey.arrowDown.keyId) return 0xff54;
    if (keyId == LogicalKeyboardKey.pageUp.keyId) return 0xff55;
    if (keyId == LogicalKeyboardKey.pageDown.keyId) return 0xff56;
    if (keyId == LogicalKeyboardKey.end.keyId) return 0xff57;
    if (keyId == LogicalKeyboardKey.insert.keyId) return 0xff63;
    if (keyId == LogicalKeyboardKey.f1.keyId) return 0xffbe;
    if (keyId == LogicalKeyboardKey.f2.keyId) return 0xffbf;
    if (keyId == LogicalKeyboardKey.f3.keyId) return 0xffc0;
    if (keyId == LogicalKeyboardKey.f4.keyId) return 0xffc1;
    if (keyId == LogicalKeyboardKey.f5.keyId) return 0xffc2;
    if (keyId == LogicalKeyboardKey.f6.keyId) return 0xffc3;
    if (keyId == LogicalKeyboardKey.f7.keyId) return 0xffc4;
    if (keyId == LogicalKeyboardKey.f8.keyId) return 0xffc5;
    if (keyId == LogicalKeyboardKey.f9.keyId) return 0xffc6;
    if (keyId == LogicalKeyboardKey.f10.keyId) return 0xffc7;
    if (keyId == LogicalKeyboardKey.f11.keyId) return 0xffc8;
    if (keyId == LogicalKeyboardKey.f12.keyId) return 0xffc9;
    if (keyId == LogicalKeyboardKey.shiftLeft.keyId) return 0xffe1;
    if (keyId == LogicalKeyboardKey.shiftRight.keyId) return 0xffe2;
    if (keyId == LogicalKeyboardKey.controlLeft.keyId) return 0xffe3;
    if (keyId == LogicalKeyboardKey.controlRight.keyId) return 0xffe4;
    if (keyId == LogicalKeyboardKey.capsLock.keyId) return 0xffe5;
    if (keyId == LogicalKeyboardKey.altLeft.keyId) return 0xffe9;
    if (keyId == LogicalKeyboardKey.altRight.keyId) return 0xffea;
    if (keyId == LogicalKeyboardKey.metaLeft.keyId) return 0xffeb;
    if (keyId == LogicalKeyboardKey.metaRight.keyId) return 0xffec;
    if (keyId == LogicalKeyboardKey.space.keyId) return 0x0020;
    
    // For letter keys (a-z), return lowercase ASCII value
    // Flutter keyId for 'a' is 0x00000061 which matches ASCII
    if (keyId >= 0x61 && keyId <= 0x7a) return keyId;  // a-z
    if (keyId >= 0x41 && keyId <= 0x5a) return keyId + 0x20;  // A-Z -> a-z
    if (keyId >= 0x30 && keyId <= 0x39) return keyId;  // 0-9
    
    // Fallback: use lower 16 bits of keyId
    return keyId & 0xFFFF;
  }

  Widget _buildInner() {
    return NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          _reportSurfaceSize();
          return true;
        },
        child: SizeChangedLayoutNotifier(
            child: _controller.value.isInitialized
                ? Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerHover: (ev) {
                      if (_pointerKind == PointerDeviceKind.touch) {
                        return;
                      }
                      _controller._setCursorPos(ev.localPosition);
                    },
                    onPointerDown: (ev) {
                      _reportSurfaceSize();

                      if (!_focusNode.hasFocus) {
                        _focusNode.requestFocus();
                      }

                      _pointerKind = ev.kind;
                      if (ev.kind == PointerDeviceKind.touch) {
                        return;
                      }
                      
                      // Update cursor position first
                      _controller._setCursorPos(ev.localPosition);
                      
                      final button = _getButton(ev.buttons);
                      _downButtons[ev.pointer] = button;
                      
                      // Detect double/triple click
                      final now = DateTime.now();
                      final timeSinceLastClick = _lastClickTime != null 
                          ? now.difference(_lastClickTime!)
                          : const Duration(days: 1);
                      final distanceFromLastClick = _lastClickPosition != null
                          ? (ev.localPosition - _lastClickPosition!).distance
                          : double.infinity;
                      
                      if (timeSinceLastClick < _doubleClickTimeout &&
                          distanceFromLastClick < _doubleClickDistance) {
                        _clickCount++;
                        if (_clickCount > 3) _clickCount = 1;
                      } else {
                        _clickCount = 1;
                      }
                      
                      _lastClickTime = now;
                      _lastClickPosition = ev.localPosition;
                      
                      // Send click with count for double/triple click
                      _controller._setPointerButtonStateWithClickCount(
                          InAppWebViewPointerEventKind.down, button, _clickCount);
                    },
                    onPointerUp: (ev) {
                      _pointerKind = ev.kind;
                      if (ev.kind == PointerDeviceKind.touch) {
                        return;
                      }
                      final button = _downButtons.remove(ev.pointer);
                      if (button != null) {
                        _controller._setPointerButtonState(
                            InAppWebViewPointerEventKind.up, button);
                      }
                    },
                    onPointerCancel: (ev) {
                      _pointerKind = ev.kind;
                      final button = _downButtons.remove(ev.pointer);
                      if (button != null) {
                        _controller._setPointerButtonState(
                            InAppWebViewPointerEventKind.cancel, button);
                      }
                    },
                    onPointerMove: (ev) {
                      _pointerKind = ev.kind;
                      if (ev.kind != PointerDeviceKind.touch) {
                        _controller._setCursorPos(ev.localPosition);
                      }
                    },
                    onPointerSignal: (signal) {
                      if (signal is PointerScrollEvent) {
                        _controller._setScrollDelta(
                            -signal.scrollDelta.dx, -signal.scrollDelta.dy);
                      }
                    },
                    onPointerPanZoomUpdate: (ev) {
                      _controller._setScrollDelta(
                          ev.panDelta.dx, ev.panDelta.dy);
                    },
                    child: MouseRegion(
                        cursor: _cursor,
                        onEnter: (ev) {
                          final button = _getButton(ev.buttons);
                          _controller._setPointerButtonState(
                              InAppWebViewPointerEventKind.enter, button);
                        },
                        onExit: (ev) {
                          final button = _getButton(ev.buttons);
                          _controller._setPointerButtonState(
                              InAppWebViewPointerEventKind.leave, button);
                        },
                        child: Texture(
                          textureId: _controller._textureId,
                          filterQuality: widget.filterQuality,
                        )),
                  )
                : const SizedBox()));
  }

  void _reportSurfaceSize() async {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      await _controller.ready;
      unawaited(_controller._setSize(
          box.size, widget.scaleFactor ?? window.devicePixelRatio));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cursorSubscription?.cancel();
    _controller.dispose();
    _focusNode.dispose();
  }
}
