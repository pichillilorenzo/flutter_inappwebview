import 'package:drago_inappwebview/src/internal_annotations/internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'download_start_response_action.dart';
import 'enum_method.dart';

part 'download_start_response.g.dart';

///Class representing a download response of the WebView used by the event [PlatformWebViewCreationParams.onDownloadStartRequest].
@ExchangeableObject()
class DownloadStartResponse_ {
  ///Set this flag to `true` to hide the default download dialog for this download.
  ///
  ///The download will progress as normal if it is not canceled, there will just be no default UI shown.
  ///
  ///On Android, iOS and macOS, `handled: true` without an [action] means the app
  ///takes care of the download itself and the native side does nothing.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  bool handled;

  ///Action to take for the download request.
  ///
  ///If canceled, the download save dialog is not displayed regardless of the [handled] property.
  ///
  ///Use [DownloadStartResponseAction_.SAVE] on Android, iOS and macOS to download
  ///the file natively to [resultFilePath] (or to the default Downloads folder when it is `null`).
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  DownloadStartResponseAction_? action;

  ///The path to the file.
  ///
  ///If setting the path, the host should ensure that it is an absolute path,
  ///including the file name, and that the path does not point to an existing file.
  ///If the path points to an existing file, the file will be overwritten.
  ///If the directory does not exist, it is created.
  ///
  ///On Android, iOS and macOS it is used only with [DownloadStartResponseAction_.SAVE];
  ///when `null` the file is saved to the default Downloads folder using the suggested file name.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  String? resultFilePath;

  DownloadStartResponse_({
    required this.handled,
    this.action,
    this.resultFilePath,
  });
}
