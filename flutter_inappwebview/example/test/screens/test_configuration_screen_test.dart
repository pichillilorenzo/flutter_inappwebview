import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview_example/models/test_configuration.dart';
import 'package:flutter_inappwebview_example/screens/test_automation/test_configuration_screen.dart';

void main() {
  group('TestConfigurationScreen', () {
    Widget createWidget() {
      return ChangeNotifierProvider(
        create: (_) => TestConfigurationManager(),
        child: const MaterialApp(home: TestConfigurationScreen()),
      );
    }

    testWidgets('renders app bar and tabs', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Test Configuration'), findsOneWidget);
      expect(find.text('Custom Steps'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Import/Export'), findsOneWidget);
    });
  });
}
