import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/models/environment_setting_definition.dart';

List<T> _safeEnumValues<T>(Iterable<T> Function() getter) {
  try {
    return getter().toList();
  } catch (_) {
    return <T>[];
  }
}

/// Get all environment setting definitions organized by category.
Map<String, List<EnvironmentSettingDefinition>>
getEnvironmentSettingDefinitions() {
  return {
    'General': [
      EnvironmentSettingDefinition(
        name: 'Browser Executable Folder',
        description:
            'Path to the folder containing the WebView2 browser executable',
        type: EnvironmentSettingType.string,
        hint: 'C:\\Program Files (x86)\\Microsoft\\Edge WebView2\\...',
        property: WebViewEnvironmentSettingsProperty.browserExecutableFolder,
      ),
      EnvironmentSettingDefinition(
        name: 'User Data Folder',
        description: 'Path to the user data folder for WebView2 profile',
        type: EnvironmentSettingType.string,
        hint: 'C:\\Users\\...\\AppData\\Local\\...',
        property: WebViewEnvironmentSettingsProperty.userDataFolder,
      ),
      EnvironmentSettingDefinition(
        name: 'Additional Browser Arguments',
        description: 'Additional command line arguments for the browser',
        type: EnvironmentSettingType.string,
        hint: '--disable-gpu --enable-logging',
        property: WebViewEnvironmentSettingsProperty.additionalBrowserArguments,
      ),
      EnvironmentSettingDefinition(
        name: 'Target Compatible Browser Version',
        description: 'Minimum WebView2 version required',
        type: EnvironmentSettingType.string,
        hint: '100.0.0.0',
        property:
            WebViewEnvironmentSettingsProperty.targetCompatibleBrowserVersion,
      ),
    ],
    'Release Channel': [
      EnvironmentSettingDefinition(
        name: 'Channel Search Kind',
        description: 'How to search for WebView2 runtime',
        type: EnvironmentSettingType.enumeration,
        enumValues: _safeEnumValues(() => EnvironmentChannelSearchKind.values),
        property: WebViewEnvironmentSettingsProperty.channelSearchKind,
      ),
      EnvironmentSettingDefinition(
        name: 'Release Channels',
        description: 'Which release channels to consider',
        type: EnvironmentSettingType.enumeration,
        enumValues: _safeEnumValues(() => EnvironmentReleaseChannels.values),
        property: WebViewEnvironmentSettingsProperty.releaseChannels,
      ),
    ],
    'Localization': [
      EnvironmentSettingDefinition(
        name: 'Language',
        description: 'Default language for the WebView',
        type: EnvironmentSettingType.string,
        hint: 'en-US',
        property: WebViewEnvironmentSettingsProperty.language,
      ),
      EnvironmentSettingDefinition(
        name: 'Preferred Languages',
        description: 'List of preferred languages',
        type: EnvironmentSettingType.stringList,
        hint: 'en-US, fr-FR, de-DE',
        property: WebViewEnvironmentSettingsProperty.preferredLanguages,
      ),
      EnvironmentSettingDefinition(
        name: 'Time Zone Override',
        description: 'Override the default time zone',
        type: EnvironmentSettingType.string,
        hint: 'America/New_York',
        property: WebViewEnvironmentSettingsProperty.timeZoneOverride,
      ),
    ],
    'Spellcheck': [
      EnvironmentSettingDefinition(
        name: 'Spell Checking Enabled',
        description: 'Enable spell checking',
        type: EnvironmentSettingType.boolean,
        defaultValue: false,
        property: WebViewEnvironmentSettingsProperty.spellCheckingEnabled,
      ),
      EnvironmentSettingDefinition(
        name: 'Spell Checking Languages',
        description: 'Languages for spell checking',
        type: EnvironmentSettingType.stringList,
        hint: 'en_US, fr_FR',
        property: WebViewEnvironmentSettingsProperty.spellCheckingLanguages,
      ),
    ],
    'Extensions': [
      EnvironmentSettingDefinition(
        name: 'Browser Extensions Enabled',
        description: 'Enable browser extensions support',
        type: EnvironmentSettingType.boolean,
        defaultValue: false,
        property:
            WebViewEnvironmentSettingsProperty.areBrowserExtensionsEnabled,
      ),
      EnvironmentSettingDefinition(
        name: 'Web Process Extensions Directory',
        description: 'Path to web process extensions',
        type: EnvironmentSettingType.string,
        hint: '/path/to/extensions',
        property:
            WebViewEnvironmentSettingsProperty.webProcessExtensionsDirectory,
      ),
    ],
    'Security & Privacy': [
      EnvironmentSettingDefinition(
        name: 'Allow SSO with OS Account',
        description: 'Allow single sign-on using the OS primary account (AAD)',
        type: EnvironmentSettingType.boolean,
        defaultValue: false,
        property: WebViewEnvironmentSettingsProperty
            .allowSingleSignOnUsingOSPrimaryAccount,
      ),
      EnvironmentSettingDefinition(
        name: 'Enable Tracking Prevention',
        description: 'Enable tracking prevention features',
        type: EnvironmentSettingType.boolean,
        defaultValue: true,
        property: WebViewEnvironmentSettingsProperty.enableTrackingPrevention,
      ),
      EnvironmentSettingDefinition(
        name: 'Exclusive User Data Folder Access',
        description: 'Ensure exclusive access to the user data folder',
        type: EnvironmentSettingType.boolean,
        defaultValue: false,
        property:
            WebViewEnvironmentSettingsProperty.exclusiveUserDataFolderAccess,
      ),
      EnvironmentSettingDefinition(
        name: 'Sandbox Paths',
        description: 'Paths for sandbox isolation',
        type: EnvironmentSettingType.stringList,
        hint: '/path/to/sandbox',
        property: WebViewEnvironmentSettingsProperty.sandboxPaths,
      ),
    ],
    'Automation & Debugging': [
      EnvironmentSettingDefinition(
        name: 'Automation Allowed',
        description: 'Allow WebDriver automation',
        type: EnvironmentSettingType.boolean,
        defaultValue: false,
        property: WebViewEnvironmentSettingsProperty.automationAllowed,
      ),
      EnvironmentSettingDefinition(
        name: 'Custom Crash Reporting',
        description: 'Enable custom crash reporting',
        type: EnvironmentSettingType.boolean,
        defaultValue: false,
        property:
            WebViewEnvironmentSettingsProperty.isCustomCrashReportingEnabled,
      ),
    ],
    'Appearance': [
      EnvironmentSettingDefinition(
        name: 'Scrollbar Style',
        description: 'Style of scrollbars in the WebView',
        type: EnvironmentSettingType.enumeration,
        enumValues: _safeEnumValues(() => EnvironmentScrollbarStyle.values),
        property: WebViewEnvironmentSettingsProperty.scrollbarStyle,
      ),
    ],
    'Cache': [
      EnvironmentSettingDefinition(
        name: 'Cache Model',
        description: 'Caching strategy for the WebView',
        type: EnvironmentSettingType.enumeration,
        enumValues: _safeEnumValues(() => CacheModel.values),
        property: WebViewEnvironmentSettingsProperty.cacheModel,
      ),
    ],
    'Custom Schemes': [
      EnvironmentSettingDefinition(
        name: 'Custom Scheme Registrations',
        description: 'Register custom URL schemes',
        type: EnvironmentSettingType.customSchemeRegistrations,
        property: WebViewEnvironmentSettingsProperty.customSchemeRegistrations,
      ),
    ],
  };
}
