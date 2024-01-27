// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_environment_settings.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///This class represents all the [PlatformWebViewEnvironment] settings available.
class WebViewEnvironmentSettings {
  final String? additionalBrowserArguments;
  final bool? allowSingleSignOnUsingOSPrimaryAccount;
  final String? browserExecutableFolder;
  final String? language;
  final String? targetCompatibleBrowserVersion;
  final String? userDataFolder;
  WebViewEnvironmentSettings(
      {this.additionalBrowserArguments,
      this.allowSingleSignOnUsingOSPrimaryAccount,
      this.browserExecutableFolder,
      this.language,
      this.targetCompatibleBrowserVersion,
      this.userDataFolder});

  ///Gets a possible [WebViewEnvironmentSettings] instance from a [Map] value.
  static WebViewEnvironmentSettings? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = WebViewEnvironmentSettings(
      additionalBrowserArguments: map['additionalBrowserArguments'],
      allowSingleSignOnUsingOSPrimaryAccount:
          map['allowSingleSignOnUsingOSPrimaryAccount'],
      browserExecutableFolder: map['browserExecutableFolder'],
      language: map['language'],
      targetCompatibleBrowserVersion: map['targetCompatibleBrowserVersion'],
      userDataFolder: map['userDataFolder'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "additionalBrowserArguments": additionalBrowserArguments,
      "allowSingleSignOnUsingOSPrimaryAccount":
          allowSingleSignOnUsingOSPrimaryAccount,
      "browserExecutableFolder": browserExecutableFolder,
      "language": language,
      "targetCompatibleBrowserVersion": targetCompatibleBrowserVersion,
      "userDataFolder": userDataFolder,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  ///Returns a copy of WebViewEnvironmentSettings.
  WebViewEnvironmentSettings copy() {
    return WebViewEnvironmentSettings.fromMap(toMap()) ??
        WebViewEnvironmentSettings();
  }

  @override
  String toString() {
    return 'WebViewEnvironmentSettings{additionalBrowserArguments: $additionalBrowserArguments, allowSingleSignOnUsingOSPrimaryAccount: $allowSingleSignOnUsingOSPrimaryAccount, browserExecutableFolder: $browserExecutableFolder, language: $language, targetCompatibleBrowserVersion: $targetCompatibleBrowserVersion, userDataFolder: $userDataFolder}';
  }
}
