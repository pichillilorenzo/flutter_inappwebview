import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A file drag reported by Windows over the Flutter view.
class WindowsFileDropEvent {
  /// Creates a file-drop event received from the native Windows implementation.
  const WindowsFileDropEvent({
    required this.paths,
    required this.x,
    required this.y,
  });

  /// Absolute paths of the dragged files.
  ///
  /// This is empty for a drag-over update. It can also be empty for virtual
  /// files, such as Outlook attachments, which do not expose local paths.
  final List<String> paths;

  /// Horizontal position in Flutter-view client coordinates.
  final double x;

  /// Vertical position in Flutter-view client coordinates.
  final double y;
}

/// Decides whether a file drag at the event position may be dropped.
///
/// The callback must be fast and synchronous. Its result is used for the
/// cursor on the following native drag update.
typedef WindowsFileDragHandler = bool Function(WindowsFileDropEvent event);

/// Handles a file dropped on a region previously accepted by [onDrag].
///
/// Check the position and files again here: native drag feedback is
/// asynchronous, so a user can release the mouse before the latest [onDrag]
/// decision reaches Windows.
typedef WindowsFileDropHandler =
    FutureOr<void> Function(WindowsFileDropEvent event);

/// Receives external OS file drags on a Windows Flutter view.
///
/// Use [start] while a screen has a drop region, and call [stop] when it no
/// longer does. File drags are never passed to WebView2 while this manager is
/// active, so accepting a drag here cannot bypass browser navigation guards.
class WindowsFileDropManager {
  WindowsFileDropManager._() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static const MethodChannel _channel = MethodChannel(
    'com.pichillilorenzo/flutter_inappwebview_filedrop',
  );

  /// Shared manager for the Flutter view associated with this plugin engine.
  static final WindowsFileDropManager instance = WindowsFileDropManager._();

  WindowsFileDragHandler? _onDrag;
  WindowsFileDropHandler? _onDrop;
  VoidCallback? _onLeave;

  /// Starts receiving file drags.
  ///
  /// [onDrag] is called for `enter` and `over`. Return true only for the
  /// intended drop region and supported files. [onDrop] runs for the final
  /// drop and must repeat that validation before taking any action.
  Future<void> start({
    required WindowsFileDragHandler onDrag,
    required WindowsFileDropHandler onDrop,
    VoidCallback? onLeave,
  }) async {
    _onDrag = onDrag;
    _onDrop = onDrop;
    _onLeave = onLeave;
    await _channel.invokeMethod<void>('setEnabled', <String, bool>{
      'enabled': true,
    });
  }

  /// Stops receiving file drags and restores the default refusal behaviour.
  Future<void> stop() async {
    _onDrag = null;
    _onDrop = null;
    _onLeave = null;
    await _channel.invokeMethod<void>('setEnabled', <String, bool>{
      'enabled': false,
    });
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method != 'onFileDrop' || call.arguments is! Map) {
      return;
    }
    final arguments = call.arguments as Map<dynamic, dynamic>;
    final eventName = arguments['event'];
    if (eventName == 'leave') {
      _onLeave?.call();
      return;
    }
    if (eventName is! String ||
        arguments['x'] is! num ||
        arguments['y'] is! num) {
      return;
    }
    final rawPaths = arguments['paths'];
    final paths = rawPaths is List
        ? List<String>.unmodifiable(rawPaths.whereType<String>())
        : const <String>[];
    final event = WindowsFileDropEvent(
      paths: paths,
      x: (arguments['x'] as num).toDouble(),
      y: (arguments['y'] as num).toDouble(),
    );

    if (eventName == 'drop') {
      await _onDrop?.call(event);
      return;
    }
    if (eventName != 'enter' && eventName != 'over') {
      return;
    }

    var accepted = false;
    try {
      accepted = _onDrag?.call(event) ?? false;
    } catch (_) {
      // Fail closed: an application callback must never leave the prior
      // accepted state active after it throws.
    }
    await _channel.invokeMethod<void>('setAccepted', <String, bool>{
      'accepted': accepted,
    });
  }
}
