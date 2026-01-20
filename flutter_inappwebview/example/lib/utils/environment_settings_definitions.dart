import 'package:flutter_inappwebview_example/models/environment_setting_definition.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';

/// Get all environment setting definitions organized by category.
Map<String, List<EnvironmentSettingDefinition>>
getEnvironmentSettingDefinitions() {
  return {
    'General': [
      EnvironmentSettingDefinition(
        key: 'browserExecutableFolder',
        name: 'Browser Executable Folder',
        description:
            'Path to the folder containing the WebView2 browser executable',
        type: EnvironmentSettingType.string,
        hint: 'C:\\Program Files (x86)\\Microsoft\\Edge WebView2\\...',
        supportedPlatforms: [SupportedPlatform.windows],
      ),
      EnvironmentSettingDefinition(
        key: 'userDataFolder',
        name: 'User Data Folder',
        description: 'Path to the user data folder for WebView2 profile',
        type: EnvironmentSettingType.string,
        hint: 'C:\\Users\\...\\AppData\\Local\\...',
        supportedPlatforms: [SupportedPlatform.windows],
      ),
      EnvironmentSettingDefinition(
        key: 'additionalBrowserArguments',
        name: 'Additional Browser Arguments',
        description: 'Additional command line arguments for the browser',
        type: EnvironmentSettingType.string,
        hint: '--disable-gpu --enable-logging',
        supportedPlatforms: [SupportedPlatform.windows],
      ),
      EnvironmentSettingDefinition(
        key: 'targetCompatibleBrowserVersion',
        name: 'Target Compatible Browser Version',
        description: 'Minimum WebView2 version required',
        type: EnvironmentSettingType.string,
        hint: '100.0.0.0',
        supportedPlatforms: [SupportedPlatform.windows],
      ),
    ],
    'Release Channel': [
      EnvironmentSettingDefinition(
        key: 'channelSearchKind',
        name: 'Channel Search Kind',
        description: 'How to search for WebView2 runtime',
        type: EnvironmentSettingType.enumeration,
        // EnvironmentChannelSearchKind: MOST_STABLE = 0, LEAST_STABLE = 1
        enumValues: const {'Most Stable': 0, 'Least Stable': 1},
        supportedPlatforms: [SupportedPlatform.windows],
      ),
      EnvironmentSettingDefinition(
        key: 'releaseChannels',
        name: 'Release Channels',
        description: 'Which release channels to consider',
        type: EnvironmentSettingType.enumeration,
        // EnvironmentReleaseChannels: STABLE = 1, BETA = 2, DEV = 4, CANARY = 8
        enumValues: const {'Stable': 1, 'Beta': 2, 'Dev': 4, 'Canary': 8},
        supportedPlatforms: [SupportedPlatform.windows],
      ),
    ],
    'Localization': [
      EnvironmentSettingDefinition(
        key: 'language',
        name: 'Language',
        description: 'Default language for the WebView',
        type: EnvironmentSettingType.string,
        hint: 'en-US',
        supportedPlatforms: [SupportedPlatform.windows],
      ),
      EnvironmentSettingDefinition(
        key: 'preferredLanguages',
        name: 'Preferred Languages',
        description: 'List of preferred languages',
        type: EnvironmentSettingType.stringList,
        hint: 'en-US, fr-FR, de-DE',
        supportedPlatforms: [SupportedPlatform.linux],
      ),
      EnvironmentSettingDefinition(
        key: 'timeZoneOverride',
        name: 'Time Zone Override',
        description: 'Override the default time zone',
        type: EnvironmentSettingType.string,
        hint: 'America/New_York',
        supportedPlatforms: [SupportedPlatform.windows],
      ),
    ],
    'Spellcheck': [
      EnvironmentSettingDefinition(
        key: 'spellCheckingEnabled',
        name: 'Spell Checking Enabled',
        description: 'Enable spell checking',
        type: EnvironmentSettingType.boolean,
        defaultValue: false,
        supportedPlatforms: [SupportedPlatform.linux],
      ),
      EnvironmentSettingDefinition(
        key: 'spellCheckingLanguages',
        name: 'Spell Checking Languages',
        description: 'Languages for spell checking',
        type: EnvironmentSettingType.stringList,
        hint: 'en_US, fr_FR',
        supportedPlatforms: [SupportedPlatform.linux],
      ),
    ],
    'Extensions': [
      EnvironmentSettingDefinition(
        key: 'areBrowserExtensionsEnabled',
        name: 'Browser Extensions Enabled',
        description: 'Enable browser extensions support',
        type: EnvironmentSettingType.boolean,
        defaultValue: false,
        supportedPlatforms: [SupportedPlatform.windows],
      ),
      EnvironmentSettingDefinition(
        key: 'webProcessExtensionsDirectory',
        name: 'Web Process Extensions Directory',
        description: 'Path to web process extensions',
        type: EnvironmentSettingType.string,
        hint: '/path/to/extensions',
        supportedPlatforms: [SupportedPlatform.linux],
      ),
    ],
    'Security & Privacy': [
      EnvironmentSettingDefinition(
        key: 'allowSingleSignOnUsingOSPrimaryAccount',
        name: 'Allow SSO with OS Account',
        description: 'Allow single sign-on using the OS primary account (AAD)',
        type: EnvironmentSettingType.boolean,
        defaultValue: false,
        supportedPlatforms: [SupportedPlatform.windows],
      ),
      EnvironmentSettingDefinition(
        key: 'enableTrackingPrevention',
        name: 'Enable Tracking Prevention',
        description: 'Enable tracking prevention features',
        type: EnvironmentSettingType.boolean,
        defaultValue: true,
        supportedPlatforms: [SupportedPlatform.windows],
      ),
      EnvironmentSettingDefinition(
        key: 'exclusiveUserDataFolderAccess',
        name: 'Exclusive User Data Folder Access',
        description: 'Ensure exclusive access to the user data folder',
        type: EnvironmentSettingType.boolean,
        defaultValue: false,
        supportedPlatforms: [SupportedPlatform.windows],
      ),
      EnvironmentSettingDefinition(
        key: 'sandboxPaths',
        name: 'Sandbox Paths',
        description: 'Paths for sandbox isolation',
        type: EnvironmentSettingType.stringList,
        hint: '/path/to/sandbox',
        supportedPlatforms: [SupportedPlatform.linux],
      ),
    ],
    'Automation & Debugging': [
      EnvironmentSettingDefinition(
        key: 'automationAllowed',
        name: 'Automation Allowed',
        description: 'Allow WebDriver automation',
        type: EnvironmentSettingType.boolean,
        defaultValue: false,
        supportedPlatforms: [SupportedPlatform.linux],
      ),
      EnvironmentSettingDefinition(
        key: 'isCustomCrashReportingEnabled',
        name: 'Custom Crash Reporting',
        description: 'Enable custom crash reporting',
        type: EnvironmentSettingType.boolean,
        defaultValue: false,
        supportedPlatforms: [SupportedPlatform.windows],
      ),
    ],
    'Appearance': [
      EnvironmentSettingDefinition(
        key: 'scrollbarStyle',
        name: 'Scrollbar Style',
        description: 'Style of scrollbars in the WebView',
        type: EnvironmentSettingType.enumeration,
        // EnvironmentScrollbarStyle: DEFAULT = 0, FLUENT_OVERLAY = 1
        enumValues: const {'Default': 0, 'Fluent Overlay': 1},
        supportedPlatforms: [SupportedPlatform.windows],
      ),
    ],
    'Cache': [
      EnvironmentSettingDefinition(
        key: 'cacheModel',
        name: 'Cache Model',
        description: 'Caching strategy for the WebView',
        type: EnvironmentSettingType.enumeration,
        // CacheModel: DOCUMENT_VIEWER = 0, DOCUMENT_BROWSER = 1, WEB_BROWSER = 2
        enumValues: const {
          'Document Viewer': 0,
          'Document Browser': 1,
          'Web Browser': 2,
        },
        supportedPlatforms: [SupportedPlatform.linux],
      ),
    ],
    'Custom Schemes': [
      EnvironmentSettingDefinition(
        key: 'customSchemeRegistrations',
        name: 'Custom Scheme Registrations',
        description: 'Register custom URL schemes',
        type: EnvironmentSettingType.customSchemeRegistrations,
        supportedPlatforms: [SupportedPlatform.windows],
      ),
    ],
  };
}
