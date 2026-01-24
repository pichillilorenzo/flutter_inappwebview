import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_example/utils/responsive_utils.dart';

/// A layout widget that switches between [Row] and [Column] by breakpoint.
class ResponsiveRow extends StatelessWidget {
  const ResponsiveRow({
    super.key,
    required this.children,
    this.spacing = 0,
    this.runSpacing = 0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.showDivider = false,
    this.divider,
    this.rowKey,
    this.columnKey,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final bool showDivider;
  final Widget? divider;
  final Key? rowKey;
  final Key? columnKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = ResponsiveBreakpoints.isMobileWidth(
          constraints.maxWidth,
        );
        return isMobile ? _buildColumn() : _buildRow();
      },
    );
  }

  Widget _buildRow() {
    return Row(
      key: rowKey,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: _withSpacing(axis: Axis.horizontal, spacing: spacing),
    );
  }

  Widget _buildColumn() {
    return Column(
      key: columnKey,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: _withSpacing(
        axis: Axis.vertical,
        spacing: runSpacing > 0 ? runSpacing : spacing,
      ),
    );
  }

  List<Widget> _withSpacing({required Axis axis, required double spacing}) {
    if (children.isEmpty) {
      return const <Widget>[];
    }

    final items = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      items.add(children[index]);
      if (index == children.length - 1) {
        continue;
      }
      if (showDivider) {
        items.add(_resolveDivider(axis));
      }
      if (spacing > 0) {
        items.add(
          axis == Axis.horizontal
              ? SizedBox(width: spacing)
              : SizedBox(height: spacing),
        );
      }
    }
    return items;
  }

  Widget _resolveDivider(Axis axis) {
    if (divider != null) {
      return divider!;
    }
    if (axis == Axis.horizontal) {
      return const VerticalDivider(width: 1);
    }
    return const Divider(height: 1);
  }
}
