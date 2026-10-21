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
    this.viewId = 0,
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

  /// The [FlutterView] the drag is over; 0 is the implicit view.
  final int viewId;
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

  /// Shared manager for the Flutter views of this plugin engine.
  static final WindowsFileDropManager instance = WindowsFileDropManager._();

  final Map<int, _FileDropHandlers> _handlers = {};

  /// Starts receiving file drags over the [FlutterView] [viewId] (the
  /// implicit view when null). Each view has its own handlers.
  ///
  /// [onDrag] is called for `enter` and `over`. Return true only for the
  /// intended drop region and supported files. [onDrop] runs for the final
  /// drop and must repeat that validation before taking any action.
  Future<void> start({
    required WindowsFileDragHandler onDrag,
    required WindowsFileDropHandler onDrop,
    VoidCallback? onLeave,
    int? viewId,
  }) async {
    _handlers[viewId ?? 0] = _FileDropHandlers(onDrag, onDrop, onLeave);
    await _channel.invokeMethod<void>(
      'setEnabled',
      _withViewId(<String, Object>{'enabled': true}, viewId),
    );
  }

  /// Stops receiving file drags over [viewId] and restores the default
  /// refusal behaviour there.
  Future<void> stop({int? viewId}) async {
    _handlers.remove(viewId ?? 0);
    await _channel.invokeMethod<void>(
      'setEnabled',
      _withViewId(<String, Object>{'enabled': false}, viewId),
    );
  }

  // Calls without a view id keep the single-view wire format.
  static Map<String, Object> _withViewId(Map<String, Object> args, int? id) =>
      id == null ? args : (args..['viewId'] = id);

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method != 'onFileDrop' || call.arguments is! Map) {
      return;
    }
    final arguments = call.arguments as Map<dynamic, dynamic>;
    final eventName = arguments['event'];
    final rawViewId = arguments['viewId'];
    final viewId = rawViewId is int ? rawViewId : null;
    final handlers = _handlers[viewId ?? 0];
    if (eventName == 'leave') {
      handlers?.onLeave?.call();
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
      viewId: viewId ?? 0,
    );

    if (eventName == 'drop') {
      await handlers?.onDrop.call(event);
      return;
    }
    if (eventName != 'enter' && eventName != 'over') {
      return;
    }

    var accepted = false;
    try {
      accepted = handlers?.onDrag(event) ?? false;
    } catch (_) {
      // Fail closed: an application callback must never leave the prior
      // accepted state active after it throws.
    }
    await _channel.invokeMethod<void>(
      'setAccepted',
      _withViewId(<String, Object>{'accepted': accepted}, viewId),
    );
  }
}

class _FileDropHandlers {
  const _FileDropHandlers(this.onDrag, this.onDrop, this.onLeave);

  final WindowsFileDragHandler onDrag;
  final WindowsFileDropHandler onDrop;
  final VoidCallback? onLeave;
}
