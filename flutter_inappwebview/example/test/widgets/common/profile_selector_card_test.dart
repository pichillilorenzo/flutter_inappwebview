import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';
import 'package:flutter_inappwebview_example/widgets/common/profile_selector_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('test_profile_card_mobile_padding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settingsManager = SettingsManager(
      environmentFactory: (_) async => null,
      environmentSupportChecker: () => false,
    );
    await settingsManager.init();

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(320, 800)),
          child: ChangeNotifierProvider<SettingsManager>.value(
            value: settingsManager,
            child: Scaffold(
              body: ProfileSelectorCard(
                onEditSettingsProfile: () {},
                onEditEnvironmentProfile: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final paddingFinder = find.byKey(
      const Key('profile-selector-card-padding'),
    );
    expect(paddingFinder, findsOneWidget);

    final paddingWidget = tester.widget<Padding>(paddingFinder);
    expect(paddingWidget.padding, const EdgeInsets.all(12));
  });
}
