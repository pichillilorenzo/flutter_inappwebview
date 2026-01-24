import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview_example/providers/settings_manager.dart';

void main() {
  group('SettingsManager', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('selecting a settings profile updates current settings', () async {
      final manager = SettingsManager();
      await manager.init();

      final profile = await manager.createProfile(
        'Profile A',
        settings: {'javaScriptEnabled': false},
      );

      final startRevision = manager.settingsRevision;
      await manager.loadProfile(profile.id);

      expect(manager.currentProfileId, profile.id);
      expect(manager.getSetting('javaScriptEnabled'), false);
      expect(manager.settingsRevision, startRevision + 1);
    });

    test('editing and removing a settings profile updates state', () async {
      final manager = SettingsManager();
      await manager.init();

      final profile = await manager.createProfile('Old', settings: {});
      await manager.updateProfile(profile.id, name: 'New');

      expect(manager.profiles.single.name, 'New');

      await manager.loadProfile(profile.id);
      await manager.deleteProfile(profile.id);

      expect(manager.currentProfileId, isNull);
      expect(manager.profiles, isEmpty);
    });

    test('environment profile selection recreates environment state', () async {
      var createCalls = 0;
      final manager = SettingsManager(
        environmentSupportChecker: () => true,
        environmentFactory: (settings) async {
          createCalls++;
          return null;
        },
      );
      await manager.init();

      final profile = await manager.createEnvironmentProfile(
        'Env',
        settings: {'userDataFolder': 'test'},
      );

      final startRevision = manager.environmentRevision;
      await manager.loadEnvironmentProfile(profile.id);

      expect(manager.currentEnvironmentProfileId, profile.id);
      expect(createCalls, 1);
      expect(manager.environmentRevision, startRevision + 1);

      await manager.updateEnvironmentProfile(
        profile.id,
        settings: {'userDataFolder': 'new'},
      );

      expect(createCalls, 2);

      await manager.deleteEnvironmentProfile(profile.id);
      expect(manager.currentEnvironmentProfileId, isNull);
    });
  });
}
