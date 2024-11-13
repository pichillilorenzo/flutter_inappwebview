import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'download_start_response_action.dart';
import 'enum_method.dart';

part 'download_start_response.g.dart';

///Class representing a download response of the WebView used by the event [PlatformWebViewCreationParams.onDownloadStartRequest].
@ExchangeableObject()
class DownloadStartResponse_ {
  ///Set this flag to `true` to hide the default download dialog for this download.
  @SupportedPlatforms(platforms: [
    WindowsPlatform()
  ])
  bool handled;

  ///the user agent to be used for the download.
  @SupportedPlatforms(platforms: [
    WindowsPlatform()
  ])
  DownloadStartResponseAction_? action;

  DownloadStartResponse_(
      {required this.handled,
      this.action});
}
