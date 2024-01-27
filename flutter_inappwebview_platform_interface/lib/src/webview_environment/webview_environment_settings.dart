import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'platform_webview_environment.dart';

part 'webview_environment_settings.g.dart';

///This class represents all the [PlatformWebViewEnvironment] settings available.
@ExchangeableObject(copyMethod: true)
class WebViewEnvironmentSettings_ {
  final String? browserExecutableFolder;
  final String? userDataFolder;
  final String? additionalBrowserArguments;
  final bool? allowSingleSignOnUsingOSPrimaryAccount;
  final String? language;
  final String? targetCompatibleBrowserVersion;

  WebViewEnvironmentSettings_({
    this.browserExecutableFolder,
    this.userDataFolder,
    this.additionalBrowserArguments,
    this.allowSingleSignOnUsingOSPrimaryAccount,
    this.language,
    this.targetCompatibleBrowserVersion
  });
}