import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '_static_channel.dart';
import 'key_mappings.dart';

const Map<String, SystemMouseCursor> _cursors = {
  // CSS cursor names (used by WebKit and GDK)
  'none': SystemMouseCursors.none,
  'default': SystemMouseCursors.basic,
  'pointer': SystemMouseCursors.click,
  'text': SystemMouseCursors.text,
  'vertical-text': SystemMouseCursors.verticalText,
  'wait': SystemMouseCursors.wait,
  'progress': SystemMouseCursors.progress,
  'help': SystemMouseCursors.help,
  'crosshair': SystemMouseCursors.precise,
  'move': SystemMouseCursors.move,
  'all-scroll': SystemMouseCursors.allScroll,
  'grab': SystemMouseCursors.grab,
  'grabbing': SystemMouseCursors.grabbing,
  'not-allowed': SystemMouseCursors.forbidden,
  'no-drop': SystemMouseCursors.noDrop,
  'context-menu': SystemMouseCursors.contextMenu,
  'cell': SystemMouseCursors.cell,
  'copy': SystemMouseCursors.copy,
  'alias': SystemMouseCursors.alias,
  'col-resize': SystemMouseCursors.resizeColumn,
  'row-resize': SystemMouseCursors.resizeRow,
  'n-resize': SystemMouseCursors.resizeUp,
  's-resize': SystemMouseCursors.resizeDown,
  'e-resize': SystemMouseCursors.resizeRight,
  'w-resize': SystemMouseCursors.resizeLeft,
  'ns-resize': SystemMouseCursors.resizeUpDown,
  'ew-resize': SystemMouseCursors.resizeLeftRight,
  'ne-resize': SystemMouseCursors.resizeUpRight,
  'nw-resize': SystemMouseCursors.resizeUpLeft,
  'se-resize': SystemMouseCursors.resizeDownRight,
  'sw-resize': SystemMouseCursors.resizeDownLeft,
  'nesw-resize': SystemMouseCursors.resizeUpRightDownLeft,
  'nwse-resize': SystemMouseCursors.resizeUpLeftDownRight,
  'zoom-in': SystemMouseCursors.zoomIn,
  'zoom-out': SystemMouseCursors.zoomOut,
  // Legacy internal names (for backward compatibility)
  'basic': SystemMouseCursors.basic,
  'click': SystemMouseCursors.click,
  'forbidden': SystemMouseCursors.forbidden,
  'contextMenu': SystemMouseCursors.contextMenu,
  'verticalText': SystemMouseCursors.verticalText,
  'precise': SystemMouseCursors.precise,
  'noDrop': SystemMouseCursors.noDrop,
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
  cancel,
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
  const CustomFlutterViewControllerValue({required this.isInitialized});

  final bool isInitialized;

  CustomFlutterViewControllerValue copyWith({bool? isInitialized}) {
    return CustomFlutterViewControllerValue(
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  CustomFlutterViewControllerValue.uninitialized() : this(isInitialized: false);
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
  Future<void> initialize({
    Function(int id)? onPlatformViewCreated,
    dynamic arguments,
  }) async {
    if (_isDisposed) {
      return;
    }
    _textureId = (await _pluginChannel.invokeMethod<int>(
      'createInAppWebView',
      arguments,
    ))!;

    _methodChannel = MethodChannel(
      'com.pichillilorenzo/custom_platform_view_$_textureId',
    );
    _eventChannel = EventChannel(
      'com.pichillilorenzo/custom_platform_view_${_textureId}_events',
    );
    _eventStreamSubscription = _eventChannel.receiveBroadcastStream().listen((
      event,
    ) {
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
    return _methodChannel.invokeMethod('setSize', [
      size.width,
      size.height,
      scaleFactor,
    ]);
  }

  /// Sets the texture offset (position within the Flutter window).
  Future<void> _setTextureOffset(Offset offset) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setTextureOffset', [
      offset.dx,
      offset.dy,
    ]);
  }

  /// Moves the virtual cursor to [position].
  Future<void> _setCursorPos(Offset position) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setCursorPos', [
      position.dx,
      position.dy,
    ]);
  }

  /// Indicates whether the specified [button] is currently down.
  Future<void> _setPointerButtonState(
    InAppWebViewPointerEventKind kind,
    PointerButton button,
  ) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setPointerButton', <String, dynamic>{
      'kind': kind.index,
      'button': button.index,
      'clickCount': 1,
    });
  }

  /// Indicates whether the specified [button] is currently down with click count.
  Future<void> _setPointerButtonStateWithClickCount(
    InAppWebViewPointerEventKind kind,
    PointerButton button,
    int clickCount,
  ) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setPointerButton', <String, dynamic>{
      'kind': kind.index,
      'button': button.index,
      'clickCount': clickCount,
    });
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
  Future<void> _sendKeyEvent(
    int type,
    int keyCode,
    int scanCode,
    int modifiers,
    String? characters,
  ) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('sendKeyEvent', <String, dynamic>{
      'type': type, // 0=press, 1=release
      'keyCode': keyCode,
      'scanCode': scanCode,
      'modifiers': modifiers,
      'characters': characters,
    });
  }

  /// Sends a touch event to the webview.
  /// [type]: 0=down, 1=up, 2=move, 3=cancel
  /// [touchPoints]: List of touch point maps with {id, x, y, type}
  Future<void> _sendTouchEvent(
    int type,
    int id,
    double x,
    double y,
    List<Map<String, dynamic>> touchPoints,
  ) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('sendTouchEvent', <String, dynamic>{
      'type': type,
      'id': id,
      'x': x,
      'y': y,
      'touchPoints': touchPoints,
    });
  }

  /// Sets the focus state of the webview.
  /// This is called when the Flutter widget gains or loses focus.
  Future<void> _setFocused(bool focused) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setFocused', focused);
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

  const CustomPlatformView({
    this.creationParams,
    this.onPlatformViewCreated,
    this.scaleFactor,
    this.filterQuality = FilterQuality.none,
    Key? key,
  }) : super(key: key);

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

  // Track active touch points for multi-touch support
  final _activeTouchPoints = <int, Offset>{};

  @override
  void initState() {
    super.initState();

    _controller.initialize(
      onPlatformViewCreated: (id) {
        widget.onPlatformViewCreated?.call(id);
        setState(() {});
      },
      arguments: widget.creationParams,
    );

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
      onFocusChange: (focused) {
        // Notify the native webview when focus changes.
        // This is important for proper text input handling - without this,
        // clicking inside text fields requires double-click because the
        // webview doesn't know it has focus.
        if (_controller.value.isInitialized) {
          _controller._setFocused(focused);
        }
      },
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
      type = 2; // Repeat event
    } else {
      return KeyEventResult.ignored;
    }

    // Build modifiers bitmask matching WPE's wpe_input_modifier enum:
    // Control = bit 0, Shift = bit 1, Alt = bit 2, Meta = bit 3
    int modifiers = 0;
    if (HardwareKeyboard.instance.isControlPressed)
      modifiers |= 1; // wpe_input_keyboard_modifier_control
    if (HardwareKeyboard.instance.isShiftPressed)
      modifiers |= 2; // wpe_input_keyboard_modifier_shift
    if (HardwareKeyboard.instance.isAltPressed)
      modifiers |= 4; // wpe_input_keyboard_modifier_alt
    if (HardwareKeyboard.instance.isMetaPressed)
      modifiers |= 8; // wpe_input_keyboard_modifier_meta

    // For Ctrl/Meta combinations, don't send the character
    final hasControlOrMeta = (modifiers & 0x9) != 0; // Ctrl=1 or Meta=8
    String? characters = hasControlOrMeta ? null : event.character;

    // Get X11 keysym for the key
    final keyCode = getX11Keysym(event.logicalKey, event.character);

    // Get X11 keycode from physical key (USB HID -> evdev -> X11)
    final usbHid = event.physicalKey.usbHidUsage & 0xFFFF;
    final scanCode = usbHidToX11Keycode(usbHid);

    _controller._sendKeyEvent(type, keyCode, scanCode, modifiers, characters);

    return KeyEventResult.handled;
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
                onPointerDown: (ev) async {
                  _reportSurfaceSize();

                  final needsFocus = !_focusNode.hasFocus;
                  if (needsFocus) {
                    // IMPORTANT: Set the native focus state BEFORE sending the click
                    // and AWAIT it to ensure WebKit has processed the focus change.
                    // Without awaiting, WebKit may receive the click before it has
                    // the focused activity state, causing the click to only activate
                    // the view rather than focusing the clicked element.
                    if (_controller.value.isInitialized) {
                      await _controller._setFocused(true);
                    }
                    _focusNode.requestFocus();
                  }

                  _pointerKind = ev.kind;
                  if (ev.kind == PointerDeviceKind.touch) {
                    // Handle touch event
                    _activeTouchPoints[ev.pointer] = ev.localPosition;
                    _sendTouchEvent(
                      0,
                      ev.pointer,
                      ev.localPosition,
                    ); // 0 = down
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
                    InAppWebViewPointerEventKind.down,
                    button,
                    _clickCount,
                  );
                },
                onPointerUp: (ev) {
                  _pointerKind = ev.kind;
                  if (ev.kind == PointerDeviceKind.touch) {
                    // Handle touch event
                    _activeTouchPoints[ev.pointer] = ev.localPosition;
                    _sendTouchEvent(1, ev.pointer, ev.localPosition); // 1 = up
                    _activeTouchPoints.remove(ev.pointer);
                    return;
                  }
                  final button = _downButtons.remove(ev.pointer);
                  if (button != null) {
                    _controller._setPointerButtonState(
                      InAppWebViewPointerEventKind.up,
                      button,
                    );
                  }
                },
                onPointerCancel: (ev) {
                  _pointerKind = ev.kind;
                  if (ev.kind == PointerDeviceKind.touch) {
                    // Handle touch cancel
                    _activeTouchPoints.remove(ev.pointer);
                    _sendTouchEvent(
                      3,
                      ev.pointer,
                      ev.localPosition,
                    ); // 3 = cancel
                    return;
                  }
                  final button = _downButtons.remove(ev.pointer);
                  if (button != null) {
                    _controller._setPointerButtonState(
                      InAppWebViewPointerEventKind.cancel,
                      button,
                    );
                  }
                },
                onPointerMove: (ev) {
                  _pointerKind = ev.kind;
                  if (ev.kind == PointerDeviceKind.touch) {
                    // Handle touch move
                    _activeTouchPoints[ev.pointer] = ev.localPosition;
                    _sendTouchEvent(
                      2,
                      ev.pointer,
                      ev.localPosition,
                    ); // 2 = move
                    return;
                  }
                  _controller._setCursorPos(ev.localPosition);
                },
                onPointerSignal: (signal) {
                  if (signal is PointerScrollEvent) {
                    _controller._setScrollDelta(
                      -signal.scrollDelta.dx,
                      -signal.scrollDelta.dy,
                    );
                  }
                },
                onPointerPanZoomUpdate: (ev) {
                  _controller._setScrollDelta(ev.panDelta.dx, ev.panDelta.dy);
                },
                child: MouseRegion(
                  cursor: _cursor,
                  onEnter: (ev) {
                    final button = _getButton(ev.buttons);
                    _controller._setPointerButtonState(
                      InAppWebViewPointerEventKind.enter,
                      button,
                    );
                  },
                  onExit: (ev) {
                    final button = _getButton(ev.buttons);
                    _controller._setPointerButtonState(
                      InAppWebViewPointerEventKind.leave,
                      button,
                    );
                  },
                  child: Texture(
                    textureId: _controller._textureId,
                    filterQuality: widget.filterQuality,
                  ),
                ),
              )
            : const SizedBox(),
      ),
    );
  }

  /// Sends a touch event to the webview with all active touch points
  void _sendTouchEvent(int type, int pointerId, Offset position) {
    // Build list of all active touch points for multi-touch support
    final touchPoints = _activeTouchPoints.entries.map((entry) {
      // Determine the type for each touch point in the event
      // The main touch point uses the event type, others are motion
      int pointType = entry.key == pointerId ? type : 2; // 2 = motion
      return <String, dynamic>{
        'id': entry.key,
        'x': entry.value.dx,
        'y': entry.value.dy,
        'type': pointType,
      };
    }).toList();

    _controller._sendTouchEvent(
      type,
      pointerId,
      position.dx,
      position.dy,
      touchPoints,
    );
  }

  void _reportSurfaceSize() async {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      await _controller.ready;
      unawaited(
        _controller._setSize(
          box.size,
          widget.scaleFactor ?? window.devicePixelRatio,
        ),
      );

      // Also report the texture offset (position within the window)
      final globalPosition = box.localToGlobal(Offset.zero);
      unawaited(_controller._setTextureOffset(globalPosition));
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
