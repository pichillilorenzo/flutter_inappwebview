import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview_example/models/settings_profile.dart';
import 'package:flutter_inappwebview_example/models/webview_environment_profile.dart';
import 'package:flutter_inappwebview_example/models/setting_definition.dart';
import 'package:flutter_inappwebview_example/models/environment_setting_definition.dart';
import 'package:flutter_inappwebview_example/utils/settings_defaults.dart'
    as settings_defaults;
import 'package:flutter_inappwebview_example/utils/settings_definitions.dart'
    as settings_definitions;
import 'package:flutter_inappwebview_example/utils/environment_settings_definitions.dart'
    as environment_settings_definitions;

/// Settings manager for the testing interface
/// Manages InAppWebViewSettings profiles with save/load functionality
class SettingsManager extends ChangeNotifier {
  static const String _profilesKey = 'settings_profiles';
  static const String _currentProfileKey = 'current_profile_id';
  static const String _modifiedSettingsKey = 'modified_settings';
  static const String _environmentProfilesKey = 'environment_profiles';
  static const String _currentEnvironmentProfileKey =
      'current_environment_profile_id';

  SettingsManager({
    Future<WebViewEnvironment?> Function(WebViewEnvironmentSettings? settings)?
    environmentFactory,
    bool Function()? environmentSupportChecker,
  }) : _environmentFactory = environmentFactory ?? _defaultEnvironmentFactory,
       _environmentSupportChecker =
           environmentSupportChecker ?? _defaultEnvironmentSupportChecker;

  SharedPreferences? _prefs;
  List<SettingsProfile> _profiles = [];
  String? _currentProfileId;
  Map<String, dynamic> _currentSettings = {};
  Set<String> _modifiedSettings = {};
  List<WebViewEnvironmentProfile> _environmentProfiles = [];
  String? _currentEnvironmentProfileId;
  Map<String, dynamic> _currentEnvironmentSettings = {};
  WebViewEnvironment? _webViewEnvironment;
  bool _isEnvironmentLoading = false;
  int _settingsRevision = 0;
  int _environmentRevision = 0;
  final Future<WebViewEnvironment?> Function(WebViewEnvironmentSettings?)
  _environmentFactory;
  final bool Function() _environmentSupportChecker;
  bool _isLoading = true;

  /// Get all saved profiles
  List<SettingsProfile> get profiles => List.unmodifiable(_profiles);

  /// Get the current profile ID
  String? get currentProfileId => _currentProfileId;

  /// Get the current settings revision
  int get settingsRevision => _settingsRevision;

  /// Get the current profile
  SettingsProfile? get currentProfile {
    if (_currentProfileId == null) return null;
    try {
      return _profiles.firstWhere((p) => p.id == _currentProfileId);
    } catch (e) {
      return null;
    }
  }

  /// Get the current settings state
  Map<String, dynamic> get currentSettings =>
      Map.unmodifiable(_currentSettings);

  /// Get all saved environment profiles
  List<WebViewEnvironmentProfile> get environmentProfiles =>
      List.unmodifiable(_environmentProfiles);

  /// Get the current environment profile ID
  String? get currentEnvironmentProfileId => _currentEnvironmentProfileId;

  /// Get the current environment profile
  WebViewEnvironmentProfile? get currentEnvironmentProfile {
    if (_currentEnvironmentProfileId == null) return null;
    try {
      return _environmentProfiles.firstWhere(
        (p) => p.id == _currentEnvironmentProfileId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get the current environment settings map
  Map<String, dynamic> get currentEnvironmentSettings =>
      Map.unmodifiable(_currentEnvironmentSettings);

  /// Current WebViewEnvironment instance
  WebViewEnvironment? get webViewEnvironment => _webViewEnvironment;

  /// Check if environment is supported on the current platform
  bool get isEnvironmentSupported => _environmentSupportChecker();

  /// Check if environment is being created or disposed
  bool get isEnvironmentLoading => _isEnvironmentLoading;

  /// Environment revision for rebuild triggers
  int get environmentRevision => _environmentRevision;

  /// Get the set of modified setting keys
  Set<String> get modifiedSettings => Set.unmodifiable(_modifiedSettings);

  /// Check if loading is in progress
  bool get isLoading => _isLoading;

  /// Initialize the settings manager
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadProfiles();
    await _loadModifiedSettings();
    await _loadEnvironmentProfiles();
    await _recreateEnvironment();
    _isLoading = false;
    notifyListeners();
  }

  /// Load profiles from shared preferences
  Future<void> _loadProfiles() async {
    final profilesJson = _prefs?.getStringList(_profilesKey);
    if (profilesJson != null) {
      _profiles = profilesJson
          .map((json) => SettingsProfile.fromJsonString(json))
          .toList();
    }
    _currentProfileId = _prefs?.getString(_currentProfileKey);

    // Load current profile settings or use defaults
    final profile = currentProfile;
    if (profile != null) {
      _currentSettings = Map<String, dynamic>.from(profile.settings);
    } else {
      _currentSettings = _getDefaultSettings();
    }
  }

  /// Load modified settings tracking from shared preferences
  Future<void> _loadModifiedSettings() async {
    final modifiedJson = _prefs?.getStringList(_modifiedSettingsKey);
    if (modifiedJson != null) {
      _modifiedSettings = modifiedJson.toSet();
    }
  }

  /// Load environment profiles from shared preferences
  Future<void> _loadEnvironmentProfiles() async {
    final profilesJson = _prefs?.getStringList(_environmentProfilesKey);
    if (profilesJson != null) {
      _environmentProfiles = profilesJson
          .map((json) => WebViewEnvironmentProfile.fromJsonString(json))
          .toList();
    }
    _currentEnvironmentProfileId = _prefs?.getString(
      _currentEnvironmentProfileKey,
    );

    final profile = currentEnvironmentProfile;
    if (profile != null) {
      _currentEnvironmentSettings = Map<String, dynamic>.from(profile.settings);
    } else {
      _currentEnvironmentSettings = _getDefaultEnvironmentSettings();
    }
  }

  /// Save profiles to shared preferences
  Future<void> _saveProfiles() async {
    final profilesJson = _profiles.map((p) => p.toJsonString()).toList();
    await _prefs?.setStringList(_profilesKey, profilesJson);
    if (_currentProfileId != null) {
      await _prefs?.setString(_currentProfileKey, _currentProfileId!);
    } else {
      await _prefs?.remove(_currentProfileKey);
    }
  }

  /// Save environment profiles to shared preferences
  Future<void> _saveEnvironmentProfiles() async {
    final profilesJson = _environmentProfiles
        .map((p) => p.toJsonString())
        .toList();
    await _prefs?.setStringList(_environmentProfilesKey, profilesJson);
    if (_currentEnvironmentProfileId != null) {
      await _prefs?.setString(
        _currentEnvironmentProfileKey,
        _currentEnvironmentProfileId!,
      );
    } else {
      await _prefs?.remove(_currentEnvironmentProfileKey);
    }
  }

  /// Save modified settings tracking to shared preferences
  Future<void> _saveModifiedSettings() async {
    await _prefs?.setStringList(
      _modifiedSettingsKey,
      _modifiedSettings.toList(),
    );
  }

  /// Create a new settings profile
  Future<SettingsProfile> createProfile(
    String name, {
    Map<String, dynamic>? settings,
  }) async {
    final profile = SettingsProfile.create(
      name: name,
      settings: settings ?? Map<String, dynamic>.from(_currentSettings),
    );
    _profiles.add(profile);
    await _saveProfiles();
    notifyListeners();
    return profile;
  }

  /// Create a new environment profile
  Future<WebViewEnvironmentProfile> createEnvironmentProfile(
    String name, {
    Map<String, dynamic>? settings,
  }) async {
    final profile = WebViewEnvironmentProfile.create(
      name: name,
      settings:
          settings ?? Map<String, dynamic>.from(_currentEnvironmentSettings),
    );
    _environmentProfiles.add(profile);
    await _saveEnvironmentProfiles();
    notifyListeners();
    return profile;
  }

  /// Update an existing profile
  Future<void> updateProfile(
    String profileId, {
    String? name,
    Map<String, dynamic>? settings,
  }) async {
    final index = _profiles.indexWhere((p) => p.id == profileId);
    if (index != -1) {
      _profiles[index] = _profiles[index].copyWith(
        name: name,
        settings: settings,
      );
      await _saveProfiles();
      notifyListeners();
    }
  }

  /// Update an existing environment profile
  Future<void> updateEnvironmentProfile(
    String profileId, {
    String? name,
    Map<String, dynamic>? settings,
  }) async {
    final index = _environmentProfiles.indexWhere((p) => p.id == profileId);
    if (index != -1) {
      _environmentProfiles[index] = _environmentProfiles[index].copyWith(
        name: name,
        settings: settings,
      );
      if (_currentEnvironmentProfileId == profileId && settings != null) {
        _currentEnvironmentSettings = Map<String, dynamic>.from(settings);
        await _recreateEnvironment();
      } else {
        notifyListeners();
      }
      await _saveEnvironmentProfiles();
    }
  }

  /// Delete a profile
  Future<void> deleteProfile(String profileId) async {
    _profiles.removeWhere((p) => p.id == profileId);
    if (_currentProfileId == profileId) {
      _currentProfileId = null;
    }
    await _saveProfiles();
    notifyListeners();
  }

  /// Delete an environment profile
  Future<void> deleteEnvironmentProfile(String profileId) async {
    _environmentProfiles.removeWhere((p) => p.id == profileId);
    if (_currentEnvironmentProfileId == profileId) {
      _currentEnvironmentProfileId = null;
      _currentEnvironmentSettings = _getDefaultEnvironmentSettings();
      await _recreateEnvironment();
    }
    await _saveEnvironmentProfiles();
    notifyListeners();
  }

  /// Load a profile as the current settings
  Future<void> loadProfile(String profileId) async {
    final profile = _profiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => throw Exception('Profile not found'),
    );
    _currentProfileId = profileId;
    _currentSettings = Map<String, dynamic>.from(profile.settings);
    _modifiedSettings.clear();
    _settingsRevision++;
    await _saveProfiles();
    await _saveModifiedSettings();
    notifyListeners();
  }

  /// Load an environment profile as the current environment settings
  Future<void> loadEnvironmentProfile(String profileId) async {
    final profile = _environmentProfiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => throw Exception('Environment profile not found'),
    );
    _currentEnvironmentProfileId = profileId;
    _currentEnvironmentSettings = Map<String, dynamic>.from(profile.settings);
    await _saveEnvironmentProfiles();
    await _recreateEnvironment();
  }

  /// Clear current environment selection
  Future<void> clearEnvironmentSelection() async {
    _currentEnvironmentProfileId = null;
    _currentEnvironmentSettings = _getDefaultEnvironmentSettings();
    await _saveEnvironmentProfiles();
    await _recreateEnvironment();
  }

  /// Save current settings to the current profile or create a new one
  Future<SettingsProfile> saveCurrentSettings(String name) async {
    if (_currentProfileId != null) {
      await updateProfile(_currentProfileId!, settings: _currentSettings);
      _modifiedSettings.clear();
      await _saveModifiedSettings();
      return currentProfile!;
    } else {
      final profile = await createProfile(name, settings: _currentSettings);
      _currentProfileId = profile.id;
      _modifiedSettings.clear();
      await _saveProfiles();
      await _saveModifiedSettings();
      notifyListeners();
      return profile;
    }
  }

  /// Save current environment settings to the current profile or create a new one
  Future<WebViewEnvironmentProfile> saveCurrentEnvironmentSettings(
    String name,
  ) async {
    if (_currentEnvironmentProfileId != null) {
      await updateEnvironmentProfile(
        _currentEnvironmentProfileId!,
        name: name,
        settings: _currentEnvironmentSettings,
      );
      return currentEnvironmentProfile!;
    } else {
      final profile = await createEnvironmentProfile(
        name,
        settings: _currentEnvironmentSettings,
      );
      _currentEnvironmentProfileId = profile.id;
      await _saveEnvironmentProfiles();
      notifyListeners();
      return profile;
    }
  }

  /// Update a single setting value
  void updateSetting(String key, dynamic value) {
    final defaultSettings = _getDefaultSettings();
    final defaultValue = defaultSettings[key];

    if (value == defaultValue) {
      _currentSettings.remove(key);
      _modifiedSettings.remove(key);
    } else {
      _currentSettings[key] = value;
      _modifiedSettings.add(key);
    }
    _settingsRevision++;
    notifyListeners();
  }

  /// Get a setting value with fallback to default
  dynamic getSetting(String key) {
    if (_currentSettings.containsKey(key)) {
      return _currentSettings[key];
    }
    return _getDefaultSettings()[key];
  }

  /// Check if a setting has been modified from default
  bool isSettingModified(String key) {
    return _modifiedSettings.contains(key);
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _currentSettings = _getDefaultSettings();
    _modifiedSettings.clear();
    _currentProfileId = null;
    _settingsRevision++;
    await _saveProfiles();
    await _saveModifiedSettings();
    notifyListeners();
  }

  /// Reset a single setting to default
  void resetSetting(String key) {
    final defaultValue = _getDefaultSettings()[key];
    _currentSettings[key] = defaultValue;
    _modifiedSettings.remove(key);
    _settingsRevision++;
    notifyListeners();
  }

  /// Export settings as JSON string
  String exportSettingsAsJson() {
    final exportData = {
      'exportedAt': DateTime.now().toIso8601String(),
      'settings': _currentSettings,
    };
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Import settings from JSON string
  Future<bool> importSettingsFromJson(String json) async {
    try {
      final importData = jsonDecode(json) as Map<String, dynamic>;
      if (importData.containsKey('settings')) {
        final settings = importData['settings'] as Map<String, dynamic>;
        _currentSettings = Map<String, dynamic>.from(settings);
        _modifiedSettings = settings.keys.toSet();
        _currentProfileId = null;
        _settingsRevision++;
        await _saveModifiedSettings();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error importing settings: $e');
      return false;
    }
  }

  /// Build InAppWebViewSettings from current settings
  InAppWebViewSettings buildSettings() {
    final defaults = _getDefaultSettings();
    final merged = Map<String, dynamic>.from(defaults)
      ..addAll(_currentSettings);

    return InAppWebViewSettings.fromMap(
          merged,
          enumMethod: EnumMethod.nativeValue,
        ) ??
        InAppWebViewSettings();
  }

  /// Build WebViewEnvironmentSettings from current environment settings
  WebViewEnvironmentSettings buildEnvironmentSettings() {
    final defaults = _getDefaultEnvironmentSettings();
    final merged = Map<String, dynamic>.from(defaults)
      ..addAll(_currentEnvironmentSettings);

    return WebViewEnvironmentSettings.fromMap(
          merged,
          enumMethod: EnumMethod.nativeValue,
        ) ??
        WebViewEnvironmentSettings();
  }

  /// Recreate the WebViewEnvironment using current selection
  Future<void> recreateEnvironment() async {
    await _recreateEnvironment();
  }

  /// Dispose the current WebViewEnvironment instance
  Future<void> disposeEnvironment() async {
    _isEnvironmentLoading = true;
    notifyListeners();
    await _webViewEnvironment?.dispose();
    _webViewEnvironment = null;
    _environmentRevision++;
    _isEnvironmentLoading = false;
    notifyListeners();
  }

  Future<void> _recreateEnvironment() async {
    _isEnvironmentLoading = true;
    notifyListeners();
    await _webViewEnvironment?.dispose();
    _webViewEnvironment = null;

    if (_currentEnvironmentProfileId != null && isEnvironmentSupported) {
      final settings = buildEnvironmentSettings();
      _webViewEnvironment = await _environmentFactory(settings);
    }

    _environmentRevision++;
    _isEnvironmentLoading = false;
    notifyListeners();
  }

  static Future<WebViewEnvironment?> _defaultEnvironmentFactory(
    WebViewEnvironmentSettings? settings,
  ) async {
    if (!_defaultEnvironmentSupportChecker()) {
      return null;
    }
    return WebViewEnvironment.create(settings: settings);
  }

  static bool _defaultEnvironmentSupportChecker() {
    return !kIsWeb && WebViewEnvironment.isClassSupported();
  }

  Map<String, dynamic> _getDefaultEnvironmentSettings() {
    return settings_defaults.defaultWebViewEnvironmentSettings().toMap(
      enumMethod: EnumMethod.nativeValue,
    );
  }

  /// Get default settings map
  Map<String, dynamic> _getDefaultSettings() {
    return settings_defaults.defaultInAppWebViewSettings().toMap(
      enumMethod: EnumMethod.nativeValue,
    );
  }

  @override
  void dispose() {
    _webViewEnvironment?.dispose();
    super.dispose();
  }

  /// Get all setting definitions organized by category
  static Map<String, List<SettingDefinition>> getSettingDefinitions() {
    return settings_definitions.getSettingDefinitions();
  }

  /// Get all environment setting definitions organized by category
  static Map<String, List<EnvironmentSettingDefinition>>
  getEnvironmentSettingDefinitions() {
    return environment_settings_definitions.getEnvironmentSettingDefinitions();
  }
}
