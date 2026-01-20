import 'package:flutter/material.dart';

/// A draggable handle for resizing vertically-split sections.
///
/// Used in screens like WebViewTesterScreen, ControllersScreen, and WebStorageScreen
/// to allow users to resize the WebView preview area.
class ResizeHandle extends StatelessWidget {
  /// Called when the user drags the handle. [delta] is the vertical displacement.
  final ValueChanged<double> onDrag;

  /// Height of the resize handle area.
  final double height;

  /// Color of the handle background.
  final Color? backgroundColor;

  /// Color of the grip indicator.
  final Color? gripColor;

  const ResizeHandle({
    super.key,
    required this.onDrag,
    this.height = 6.0,
    this.backgroundColor,
    this.gripColor,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) => onDrag(details.delta.dy),
        child: Container(
          height: height,
          color: backgroundColor ?? Colors.grey.shade300,
          child: Center(
            child: Container(
              width: 40,
              height: 2,
              decoration: BoxDecoration(
                color: gripColor ?? Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
