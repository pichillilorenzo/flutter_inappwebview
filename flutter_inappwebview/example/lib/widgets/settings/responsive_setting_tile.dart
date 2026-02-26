import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_example/utils/responsive_utils.dart';

class ResponsiveSettingTile extends StatelessWidget {
  const ResponsiveSettingTile({
    super.key,
    required this.title,
    required this.description,
    required this.control,
    this.badges,
    this.trailing,
    this.spacing = 8,
    this.inlineControl = false,
  });

  final Widget title;
  final Widget description;
  final Widget control;
  final Widget? badges;
  final Widget? trailing;
  final double spacing;
  final bool inlineControl;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 4),
        description,
        if (badges != null) ...[SizedBox(height: spacing), badges!],
      ],
    );

    final controlRow = Row(children: [Expanded(child: control)]);

    if (inlineControl) {
      return Row(
        key: const ValueKey('responsive_setting_tile_inline_control'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: titleSection),
          const SizedBox(width: 8),
          control,
        ],
      );
    }

    return Column(
      key: ValueKey(
        isMobile
            ? 'responsive_setting_tile_mobile_layout'
            : 'responsive_setting_tile_desktop_layout',
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleSection,
        SizedBox(height: spacing),
        controlRow,
      ],
    );
  }
}
