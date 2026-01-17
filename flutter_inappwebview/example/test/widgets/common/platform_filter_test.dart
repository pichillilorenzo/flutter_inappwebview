import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_example/widgets/common/platform_filter.dart';
import 'package:flutter_inappwebview_example/utils/constants.dart';

void main() {
  group('PlatformFilter', () {
    testWidgets('should render 6 checkboxes for all platforms', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformFilter(
              selectedPlatforms: const [],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find 6 checkboxes (one for each platform)
      expect(find.byType(CheckboxListTile), findsNWidgets(6));

      // Verify platform names are displayed
      for (final platform in allPlatforms) {
        expect(find.text(platformNames[platform]!), findsOneWidget);
      }
    });

    testWidgets('should show selected platforms as checked', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformFilter(
              selectedPlatforms: const ['android', 'ios'],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find checkboxes
      final checkboxes = tester.widgetList<CheckboxListTile>(
        find.byType(CheckboxListTile),
      );

      int checkedCount = 0;
      for (final checkbox in checkboxes) {
        if (checkbox.value == true) {
          checkedCount++;
        }
      }

      expect(checkedCount, 2);
    });

    testWidgets('should call onChanged when checkbox is tapped', (
      tester,
    ) async {
      List<String>? changedSelection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformFilter(
              selectedPlatforms: const ['android'],
              onChanged: (selection) {
                changedSelection = selection;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the iOS checkbox
      await tester.tap(find.text('iOS'));
      await tester.pumpAndSettle();

      expect(changedSelection, isNotNull);
      expect(changedSelection, contains('android'));
      expect(changedSelection, contains('ios'));
    });

    testWidgets('should remove platform when unchecking', (tester) async {
      List<String>? changedSelection;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformFilter(
              selectedPlatforms: const ['android', 'ios'],
              onChanged: (selection) {
                changedSelection = selection;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the Android checkbox to uncheck it
      await tester.tap(find.text('Android'));
      await tester.pumpAndSettle();

      expect(changedSelection, isNotNull);
      expect(changedSelection, isNot(contains('android')));
      expect(changedSelection, contains('ios'));
    });

    testWidgets('should support selecting all platforms', (tester) async {
      List<String> selection = [];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: PlatformFilter(
                  selectedPlatforms: selection,
                  onChanged: (newSelection) {
                    setState(() {
                      selection = newSelection;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Tap all checkboxes
      for (final platform in allPlatforms) {
        await tester.tap(find.text(platformNames[platform]!));
        await tester.pumpAndSettle();
      }

      expect(selection, containsAll(allPlatforms));
      expect(selection.length, allPlatforms.length);
    });
  });
}
