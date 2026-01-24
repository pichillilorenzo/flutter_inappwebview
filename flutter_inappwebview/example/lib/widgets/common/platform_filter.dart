import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';

/// Widget for filtering tests by platform with checkboxes
class PlatformFilter extends StatelessWidget {
  final List<SupportedPlatform> selectedPlatforms;
  final Function(List<SupportedPlatform>) onChanged;

  const PlatformFilter({
    super.key,
    required this.selectedPlatforms,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: SupportedPlatform.values.map((platform) {
        final isSelected = selectedPlatforms.contains(platform);

        return CheckboxListTile(
          title: Text(platform.displayName),
          value: isSelected,
          onChanged: (bool? checked) {
            final newSelection = List<SupportedPlatform>.from(
              selectedPlatforms,
            );

            if (checked == true) {
              if (!newSelection.contains(platform)) {
                newSelection.add(platform);
              }
            } else {
              newSelection.remove(platform);
            }

            onChanged(newSelection);
          },
        );
      }).toList(),
    );
  }
}
