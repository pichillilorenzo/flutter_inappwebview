import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../web_uri.dart';
import '../in_app_webview/platform_webview.dart';
import 'enum_method.dart';

part 'download_start_request.g.dart';

///Class representing a download request of the WebView used by the event [PlatformWebViewCreationParams.onDownloadStartRequest].
@ExchangeableObject()
class DownloadStartRequest_ {
  ///The full url to the content that should be downloaded.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  WebUri url;

  ///the user agent to be used for the download.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  String? userAgent;

  ///Content-disposition http header, if present.
  @SupportedPlatforms(platforms: [AndroidPlatform(), WindowsPlatform()])
  String? contentDisposition;

  ///The mimetype of the content reported by the server.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  String? mimeType;

  ///The file size reported by the server.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  int contentLength;

  ///A suggested filename to use if saving the resource to disk.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  String? suggestedFilename;

  ///The name of the text encoding of the receiver, or `null` if no text encoding was specified.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform()],
  )
  String? textEncodingName;

  DownloadStartRequest_({
    required this.url,
    this.userAgent,
    this.contentDisposition,
    this.mimeType,
    required this.contentLength,
    this.suggestedFilename,
    this.textEncodingName,
  });
}
