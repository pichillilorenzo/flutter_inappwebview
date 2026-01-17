import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';

/// Widget for filtering tests by platform with checkboxes
class PlatformFilter extends StatelessWidget {
  final List<String> selectedPlatforms;
  final Function(List<String>) onChanged;

  const PlatformFilter({
    super.key,
    required this.selectedPlatforms,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: allPlatforms.map((platform) {
        final isSelected = selectedPlatforms.contains(platform);

        return CheckboxListTile(
          title: Text(platformNames[platform]!),
          value: isSelected,
          onChanged: (bool? checked) {
            final newSelection = List<String>.from(selectedPlatforms);

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
