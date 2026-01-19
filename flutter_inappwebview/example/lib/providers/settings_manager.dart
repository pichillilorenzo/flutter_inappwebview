import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview_example/models/settings_profile.dart';
import 'package:flutter_inappwebview_example/models/webview_environment_profile.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';

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
    return InAppWebViewSettings(
      // General Settings
      javaScriptEnabled: getSetting('javaScriptEnabled') ?? true,
      userAgent: getSetting('userAgent'),
      applicationNameForUserAgent: getSetting('applicationNameForUserAgent'),
      cacheEnabled: getSetting('cacheEnabled') ?? true,
      incognito: getSetting('incognito') ?? false,
      supportZoom: getSetting('supportZoom') ?? true,

      // Layout Settings
      useWideViewPort: getSetting('useWideViewPort') ?? true,
      loadWithOverviewMode: getSetting('loadWithOverviewMode') ?? true,
      minimumFontSize: getSetting('minimumFontSize'),
      defaultFontSize: getSetting('defaultFontSize'),
      defaultTextEncodingName: getSetting('defaultTextEncodingName'),

      // Content Settings
      allowContentAccess: getSetting('allowContentAccess') ?? true,
      allowFileAccess: getSetting('allowFileAccess') ?? true,
      allowFileAccessFromFileURLs:
          getSetting('allowFileAccessFromFileURLs') ?? false,
      allowUniversalAccessFromFileURLs:
          getSetting('allowUniversalAccessFromFileURLs') ?? false,
      blockNetworkImage: getSetting('blockNetworkImage') ?? false,
      blockNetworkLoads: getSetting('blockNetworkLoads') ?? false,

      // Media Settings
      mediaPlaybackRequiresUserGesture:
          getSetting('mediaPlaybackRequiresUserGesture') ?? true,
      allowsInlineMediaPlayback:
          getSetting('allowsInlineMediaPlayback') ?? false,
      allowsAirPlayForMediaPlayback:
          getSetting('allowsAirPlayForMediaPlayback') ?? true,
      allowsPictureInPictureMediaPlayback:
          getSetting('allowsPictureInPictureMediaPlayback') ?? true,
      automaticallyAdjustsScrollIndicatorInsets:
          getSetting('automaticallyAdjustsScrollIndicatorInsets') ?? false,

      // JavaScript Settings
      javaScriptCanOpenWindowsAutomatically:
          getSetting('javaScriptCanOpenWindowsAutomatically') ?? false,
      javaScriptBridgeEnabled: getSetting('javaScriptBridgeEnabled') ?? true,
      javaScriptBridgeForMainFrameOnly:
          getSetting('javaScriptBridgeForMainFrameOnly') ?? false,

      // Security Settings
      mixedContentMode: _getMixedContentMode(getSetting('mixedContentMode')),
      useShouldInterceptRequest:
          getSetting('useShouldInterceptRequest') ?? false,
      useShouldOverrideUrlLoading:
          getSetting('useShouldOverrideUrlLoading') ?? false,
      useOnLoadResource: getSetting('useOnLoadResource') ?? false,

      // Cache Settings
      cacheMode: _getCacheMode(getSetting('cacheMode')),

      // Appearance Settings
      transparentBackground: getSetting('transparentBackground') ?? false,
      verticalScrollBarEnabled: getSetting('verticalScrollBarEnabled') ?? true,
      horizontalScrollBarEnabled:
          getSetting('horizontalScrollBarEnabled') ?? true,
      scrollbarFadingEnabled: getSetting('scrollbarFadingEnabled') ?? true,
      disableVerticalScroll: getSetting('disableVerticalScroll') ?? false,
      disableHorizontalScroll: getSetting('disableHorizontalScroll') ?? false,
      disableContextMenu: getSetting('disableContextMenu') ?? false,

      // iOS/macOS Specific
      allowsBackForwardNavigationGestures:
          getSetting('allowsBackForwardNavigationGestures') ?? true,
      isFraudulentWebsiteWarningEnabled:
          getSetting('isFraudulentWebsiteWarningEnabled') ?? true,
      suppressesIncrementalRendering:
          getSetting('suppressesIncrementalRendering') ?? false,
      ignoresViewportScaleLimits:
          getSetting('ignoresViewportScaleLimits') ?? false,
      allowsLinkPreview: getSetting('allowsLinkPreview') ?? true,

      // Android Specific
      hardwareAcceleration: getSetting('hardwareAcceleration') ?? true,
      useHybridComposition: getSetting('useHybridComposition') ?? true,
      thirdPartyCookiesEnabled: getSetting('thirdPartyCookiesEnabled') ?? true,
      domStorageEnabled: getSetting('domStorageEnabled') ?? true,
      databaseEnabled: getSetting('databaseEnabled') ?? true,
      geolocationEnabled: getSetting('geolocationEnabled') ?? true,
      safeBrowsingEnabled: getSetting('safeBrowsingEnabled') ?? true,
      builtInZoomControls: getSetting('builtInZoomControls') ?? true,
      displayZoomControls: getSetting('displayZoomControls') ?? false,

      // Windows Specific
      generalAutofillEnabled: getSetting('generalAutofillEnabled') ?? true,
      passwordAutosaveEnabled: getSetting('passwordAutosaveEnabled') ?? false,
      pinchZoomEnabled: getSetting('pinchZoomEnabled') ?? true,
      statusBarEnabled: getSetting('statusBarEnabled') ?? true,
      browserAcceleratorKeysEnabled:
          getSetting('browserAcceleratorKeysEnabled') ?? true,
      isInspectable: getSetting('isInspectable') ?? false,
    );
  }

  /// Build WebViewEnvironmentSettings from current environment settings
  WebViewEnvironmentSettings buildEnvironmentSettings() {
    return WebViewEnvironmentSettings.fromMap(_currentEnvironmentSettings) ??
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
    return {};
  }

  MixedContentMode? _getMixedContentMode(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return MixedContentMode.fromNativeValue(value);
    }
    return null;
  }

  CacheMode? _getCacheMode(dynamic value) {
    if (value == null) return CacheMode.LOAD_DEFAULT;
    if (value is int) {
      return CacheMode.fromNativeValue(value);
    }
    return CacheMode.LOAD_DEFAULT;
  }

  /// Get default settings map
  Map<String, dynamic> _getDefaultSettings() {
    return {
      // General Settings
      'javaScriptEnabled': true,
      'userAgent': '',
      'applicationNameForUserAgent': '',
      'cacheEnabled': true,
      'incognito': false,
      'supportZoom': true,

      // Layout Settings
      'useWideViewPort': true,
      'loadWithOverviewMode': true,
      'minimumFontSize': defaultTargetPlatform == TargetPlatform.android
          ? 8
          : 0,
      'defaultFontSize': 16,
      'defaultTextEncodingName': 'UTF-8',

      // Content Settings
      'allowContentAccess': true,
      'allowFileAccess': true,
      'allowFileAccessFromFileURLs': false,
      'allowUniversalAccessFromFileURLs': false,
      'blockNetworkImage': false,
      'blockNetworkLoads': false,

      // Media Settings
      'mediaPlaybackRequiresUserGesture': true,
      'allowsInlineMediaPlayback': false,
      'allowsAirPlayForMediaPlayback': true,
      'allowsPictureInPictureMediaPlayback': true,
      'automaticallyAdjustsScrollIndicatorInsets': false,

      // JavaScript Settings
      'javaScriptCanOpenWindowsAutomatically': false,
      'javaScriptBridgeEnabled': true,
      'javaScriptBridgeForMainFrameOnly': false,

      // Security Settings
      'mixedContentMode': null,
      'useShouldInterceptRequest': false,
      'useShouldOverrideUrlLoading': false,
      'useOnLoadResource': false,

      // Cache Settings
      'cacheMode': CacheMode.LOAD_DEFAULT.toNativeValue(),

      // Appearance Settings
      'transparentBackground': false,
      'verticalScrollBarEnabled': true,
      'horizontalScrollBarEnabled': true,
      'scrollbarFadingEnabled': true,
      'disableVerticalScroll': false,
      'disableHorizontalScroll': false,
      'disableContextMenu': false,

      // iOS/macOS Specific
      'allowsBackForwardNavigationGestures': true,
      'isFraudulentWebsiteWarningEnabled': true,
      'suppressesIncrementalRendering': false,
      'ignoresViewportScaleLimits': false,
      'allowsLinkPreview': true,
      'selectionGranularity': SelectionGranularity.DYNAMIC.toNativeValue(),

      // Android Specific
      'hardwareAcceleration': true,
      'useHybridComposition': true,
      'thirdPartyCookiesEnabled': true,
      'domStorageEnabled': true,
      'databaseEnabled': true,
      'geolocationEnabled': true,
      'safeBrowsingEnabled': true,
      'builtInZoomControls': true,
      'displayZoomControls': false,

      // Windows Specific
      'generalAutofillEnabled': true,
      'passwordAutosaveEnabled': false,
      'pinchZoomEnabled': true,
      'statusBarEnabled': true,
      'browserAcceleratorKeysEnabled': true,
      'isInspectable': false,
    };
  }

  @override
  void dispose() {
    _webViewEnvironment?.dispose();
    super.dispose();
  }

  /// Get all setting definitions organized by category
  static Map<String, List<SettingDefinition>> getSettingDefinitions() {
    return {
      'General': [
        SettingDefinition(
          key: 'javaScriptEnabled',
          name: 'JavaScript Enabled',
          description: 'Enable JavaScript execution in the WebView',
          type: SettingType.boolean,
          defaultValue: true,
        ),
        SettingDefinition(
          key: 'userAgent',
          name: 'User Agent',
          description: 'Custom user-agent string for the WebView',
          type: SettingType.string,
          defaultValue: '',
        ),
        SettingDefinition(
          key: 'applicationNameForUserAgent',
          name: 'Application Name for User Agent',
          description: 'Append to the existing user-agent',
          type: SettingType.string,
          defaultValue: '',
        ),
        SettingDefinition(
          key: 'cacheEnabled',
          name: 'Cache Enabled',
          description: 'Enable browser caching',
          type: SettingType.boolean,
          defaultValue: true,
        ),
        SettingDefinition(
          key: 'incognito',
          name: 'Incognito Mode',
          description: 'Open browser in incognito/private mode',
          type: SettingType.boolean,
          defaultValue: false,
        ),
        SettingDefinition(
          key: 'supportZoom',
          name: 'Support Zoom',
          description: 'Enable zoom gestures and controls',
          type: SettingType.boolean,
          defaultValue: true,
        ),
      ],
      'Layout': [
        SettingDefinition(
          key: 'useWideViewPort',
          name: 'Use Wide ViewPort',
          description: 'Enable support for HTML viewport meta tag',
          type: SettingType.boolean,
          defaultValue: true,
        ),
        SettingDefinition(
          key: 'loadWithOverviewMode',
          name: 'Load With Overview Mode',
          description: 'Zoom out content to fit on screen',
          type: SettingType.boolean,
          defaultValue: true,
        ),
        SettingDefinition(
          key: 'minimumFontSize',
          name: 'Minimum Font Size',
          description: 'Minimum font size in pixels',
          type: SettingType.integer,
          defaultValue: 8,
        ),
        SettingDefinition(
          key: 'defaultFontSize',
          name: 'Default Font Size',
          description: 'Default font size in pixels',
          type: SettingType.integer,
          defaultValue: 16,
        ),
        SettingDefinition(
          key: 'defaultTextEncodingName',
          name: 'Default Text Encoding',
          description: 'Default text encoding for HTML pages',
          type: SettingType.string,
          defaultValue: 'UTF-8',
        ),
      ],
      'Content': [
        SettingDefinition(
          key: 'allowContentAccess',
          name: 'Allow Content Access',
          description: 'Enable content URL access',
          type: SettingType.boolean,
          defaultValue: true,
        ),
        SettingDefinition(
          key: 'allowFileAccess',
          name: 'Allow File Access',
          description: 'Enable file system access',
          type: SettingType.boolean,
          defaultValue: true,
        ),
        SettingDefinition(
          key: 'allowFileAccessFromFileURLs',
          name: 'Allow File Access From File URLs',
          description: 'Allow file:// URLs to access other file:// URLs',
          type: SettingType.boolean,
          defaultValue: false,
        ),
        SettingDefinition(
          key: 'allowUniversalAccessFromFileURLs',
          name: 'Allow Universal Access From File URLs',
          description: 'Allow file:// URLs to access any origin',
          type: SettingType.boolean,
          defaultValue: false,
        ),
        SettingDefinition(
          key: 'blockNetworkImage',
          name: 'Block Network Images',
          description: 'Block loading images from the network',
          type: SettingType.boolean,
          defaultValue: false,
        ),
        SettingDefinition(
          key: 'blockNetworkLoads',
          name: 'Block Network Loads',
          description: 'Block all network resource loading',
          type: SettingType.boolean,
          defaultValue: false,
        ),
      ],
      'Media': [
        SettingDefinition(
          key: 'mediaPlaybackRequiresUserGesture',
          name: 'Media Requires User Gesture',
          description: 'Require user interaction to play media',
          type: SettingType.boolean,
          defaultValue: true,
        ),
        SettingDefinition(
          key: 'allowsInlineMediaPlayback',
          name: 'Allows Inline Media Playback',
          description: 'Allow HTML5 media to play inline',
          type: SettingType.boolean,
          defaultValue: false,
        ),
        SettingDefinition(
          key: 'allowsAirPlayForMediaPlayback',
          name: 'Allows AirPlay',
          description: 'Allow AirPlay for media playback',
          type: SettingType.boolean,
          defaultValue: true,
        ),
        SettingDefinition(
          key: 'allowsPictureInPictureMediaPlayback',
          name: 'Allows Picture-in-Picture',
          description: 'Allow videos to play in picture-in-picture',
          type: SettingType.boolean,
          defaultValue: true,
        ),
        SettingDefinition(
          key: 'automaticallyAdjustsScrollIndicatorInsets',
          name: 'Auto Adjust Scroll Indicator Insets',
          description: 'Automatically adjust scroll indicator insets',
          type: SettingType.boolean,
          defaultValue: false,
        ),
      ],
      'JavaScript': [
        SettingDefinition(
          key: 'javaScriptCanOpenWindowsAutomatically',
          name: 'JS Can Open Windows',
          description: 'Allow JavaScript to open windows automatically',
          type: SettingType.boolean,
          defaultValue: false,
        ),
        SettingDefinition(
          key: 'javaScriptBridgeEnabled',
          name: 'JavaScript Bridge Enabled',
          description: 'Enable the JavaScript bridge',
          type: SettingType.boolean,
          defaultValue: true,
        ),
        SettingDefinition(
          key: 'javaScriptBridgeForMainFrameOnly',
          name: 'JS Bridge Main Frame Only',
          description: 'Restrict JavaScript bridge to main frame',
          type: SettingType.boolean,
          defaultValue: false,
        ),
      ],
      'Security': [
        SettingDefinition(
          key: 'mixedContentMode',
          name: 'Mixed Content Mode',
          description: 'How to handle mixed HTTP/HTTPS content',
          type: SettingType.enumeration,
          defaultValue: null,
          enumValues: {
            'Always Allow': MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW
                .toNativeValue(),
            'Never Allow': MixedContentMode.MIXED_CONTENT_NEVER_ALLOW
                .toNativeValue(),
            'Compatibility Mode': MixedContentMode
                .MIXED_CONTENT_COMPATIBILITY_MODE
                .toNativeValue(),
          },
        ),
        SettingDefinition(
          key: 'useShouldInterceptRequest',
          name: 'Use Should Intercept Request',
          description: 'Enable request interception events',
          type: SettingType.boolean,
          defaultValue: false,
        ),
        SettingDefinition(
          key: 'useShouldOverrideUrlLoading',
          name: 'Use Should Override URL Loading',
          description: 'Enable URL loading override events',
          type: SettingType.boolean,
          defaultValue: false,
        ),
        SettingDefinition(
          key: 'useOnLoadResource',
          name: 'Use On Load Resource',
          description: 'Enable resource loading events',
          type: SettingType.boolean,
          defaultValue: false,
        ),
        SettingDefinition(
          key: 'isFraudulentWebsiteWarningEnabled',
          name: 'Fraudulent Website Warning',
          description: 'Show warnings for suspected phishing/malware',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.ios, SupportedPlatform.macos},
        ),
        SettingDefinition(
          key: 'safeBrowsingEnabled',
          name: 'Safe Browsing',
          description: 'Enable Google Safe Browsing',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.android},
        ),
      ],
      'Cache': [
        SettingDefinition(
          key: 'cacheMode',
          name: 'Cache Mode',
          description: 'Override the way the cache is used',
          type: SettingType.enumeration,
          defaultValue: CacheMode.LOAD_DEFAULT.toNativeValue(),
          enumValues: {
            'Default': CacheMode.LOAD_DEFAULT.toNativeValue(),
            'Cache Else Network': CacheMode.LOAD_CACHE_ELSE_NETWORK
                .toNativeValue(),
            'No Cache': CacheMode.LOAD_NO_CACHE.toNativeValue(),
            'Cache Only': CacheMode.LOAD_CACHE_ONLY.toNativeValue(),
          },
        ),
      ],
      'Appearance': [
        SettingDefinition(
          key: 'transparentBackground',
          name: 'Transparent Background',
          description: 'Make the WebView background transparent',
          type: SettingType.boolean,
          defaultValue: false,
        ),
        SettingDefinition(
          key: 'verticalScrollBarEnabled',
          name: 'Vertical Scroll Bar',
          description: 'Show vertical scroll bar',
          type: SettingType.boolean,
          defaultValue: true,
        ),
        SettingDefinition(
          key: 'horizontalScrollBarEnabled',
          name: 'Horizontal Scroll Bar',
          description: 'Show horizontal scroll bar',
          type: SettingType.boolean,
          defaultValue: true,
        ),
        SettingDefinition(
          key: 'scrollbarFadingEnabled',
          name: 'Scrollbar Fading',
          description: 'Fade scrollbars when not scrolling',
          type: SettingType.boolean,
          defaultValue: true,
        ),
        SettingDefinition(
          key: 'disableVerticalScroll',
          name: 'Disable Vertical Scroll',
          description: 'Disable vertical scrolling',
          type: SettingType.boolean,
          defaultValue: false,
        ),
        SettingDefinition(
          key: 'disableHorizontalScroll',
          name: 'Disable Horizontal Scroll',
          description: 'Disable horizontal scrolling',
          type: SettingType.boolean,
          defaultValue: false,
        ),
        SettingDefinition(
          key: 'disableContextMenu',
          name: 'Disable Context Menu',
          description: 'Disable the long-press context menu',
          type: SettingType.boolean,
          defaultValue: false,
        ),
      ],
      'Navigation': [
        SettingDefinition(
          key: 'allowsBackForwardNavigationGestures',
          name: 'Back/Forward Gestures',
          description: 'Enable swipe gestures for navigation',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.ios, SupportedPlatform.macos},
        ),
      ],
      'Rendering': [
        SettingDefinition(
          key: 'suppressesIncrementalRendering',
          name: 'Suppress Incremental Rendering',
          description: 'Wait until content is fully loaded before rendering',
          type: SettingType.boolean,
          defaultValue: false,
          supportedPlatforms: {SupportedPlatform.ios, SupportedPlatform.macos},
        ),
        SettingDefinition(
          key: 'hardwareAcceleration',
          name: 'Hardware Acceleration',
          description: 'Enable hardware acceleration',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.android},
        ),
        SettingDefinition(
          key: 'useHybridComposition',
          name: 'Hybrid Composition',
          description: 'Use Flutter Hybrid Composition',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.android},
        ),
      ],
      'Zoom': [
        SettingDefinition(
          key: 'ignoresViewportScaleLimits',
          name: 'Ignore Viewport Scale Limits',
          description: 'Override user-scalable viewport setting',
          type: SettingType.boolean,
          defaultValue: false,
          supportedPlatforms: {SupportedPlatform.ios, SupportedPlatform.macos},
        ),
        SettingDefinition(
          key: 'builtInZoomControls',
          name: 'Built-In Zoom Controls',
          description: 'Use built-in zoom controls',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.android},
        ),
        SettingDefinition(
          key: 'displayZoomControls',
          name: 'Display Zoom Controls',
          description: 'Show on-screen zoom controls',
          type: SettingType.boolean,
          defaultValue: false,
          supportedPlatforms: {SupportedPlatform.android},
        ),
        SettingDefinition(
          key: 'pinchZoomEnabled',
          name: 'Pinch Zoom',
          description: 'Enable pinch-to-zoom gesture',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.windows},
        ),
      ],
      'Interaction': [
        SettingDefinition(
          key: 'allowsLinkPreview',
          name: 'Link Preview',
          description: 'Show link previews on long press',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.ios, SupportedPlatform.macos},
        ),
      ],
      'Storage': [
        SettingDefinition(
          key: 'thirdPartyCookiesEnabled',
          name: 'Third-Party Cookies',
          description: 'Allow third-party cookies',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.android},
        ),
        SettingDefinition(
          key: 'domStorageEnabled',
          name: 'DOM Storage',
          description: 'Enable DOM local storage',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.android},
        ),
        SettingDefinition(
          key: 'databaseEnabled',
          name: 'Database',
          description: 'Enable database storage API',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.android},
        ),
      ],
      'APIs': [
        SettingDefinition(
          key: 'geolocationEnabled',
          name: 'Geolocation',
          description: 'Enable Geolocation API',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.android},
        ),
      ],
      'Forms': [
        SettingDefinition(
          key: 'generalAutofillEnabled',
          name: 'General Autofill',
          description: 'Enable autofill for forms',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.windows},
        ),
        SettingDefinition(
          key: 'passwordAutosaveEnabled',
          name: 'Password Autosave',
          description: 'Enable password autosave',
          type: SettingType.boolean,
          defaultValue: false,
          supportedPlatforms: {SupportedPlatform.windows},
        ),
      ],
      'UI': [
        SettingDefinition(
          key: 'statusBarEnabled',
          name: 'Status Bar',
          description: 'Show status bar',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.windows},
        ),
        SettingDefinition(
          key: 'browserAcceleratorKeysEnabled',
          name: 'Browser Accelerator Keys',
          description: 'Enable browser keyboard shortcuts',
          type: SettingType.boolean,
          defaultValue: true,
          supportedPlatforms: {SupportedPlatform.windows},
        ),
      ],
      'Developer': [
        SettingDefinition(
          key: 'isInspectable',
          name: 'Inspectable',
          description: 'Allow Web Inspector/DevTools',
          type: SettingType.boolean,
          defaultValue: false,
          supportedPlatforms: {
            SupportedPlatform.ios,
            SupportedPlatform.macos,
            SupportedPlatform.windows,
          },
        ),
      ],
    };
  }
}

/// Enum representing the type of a setting
enum SettingType { boolean, string, integer, double, enumeration }

/// Definition of a single setting
class SettingDefinition {
  final String key;
  final String name;
  final String description;
  final SettingType type;
  final dynamic defaultValue;
  final Map<String, dynamic>? enumValues;

  /// Platforms where this setting is supported.
  /// If null, the setting is supported on all platforms.
  final Set<SupportedPlatform>? supportedPlatforms;

  const SettingDefinition({
    required this.key,
    required this.name,
    required this.description,
    required this.type,
    required this.defaultValue,
    this.enumValues,
    this.supportedPlatforms,
  });
}
