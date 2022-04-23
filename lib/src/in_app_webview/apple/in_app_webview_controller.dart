import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../../types.dart';
import '../in_app_webview_controller.dart';

///Class mixin that contains only iOS-specific methods for the WebView.
abstract class AppleInAppWebViewControllerMixin {
  late MethodChannel _channel;

  ///Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.reloadFromOrigin](https://developer.apple.com/documentation/webkit/wkwebview/1414956-reloadfromorigin))
  Future<void> reloadFromOrigin() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('reloadFromOrigin', args);
  }

  ///Generates PDF data from the web view’s contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///
  ///[pdfConfiguration] represents the object that specifies the portion of the web view to capture as PDF data.
  ///
  ///**NOTE**: available only on iOS 14.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.createPdf](https://developer.apple.com/documentation/webkit/wkwebview/3650490-createpdf))
  Future<Uint8List?> createPdf(
      {@Deprecated("Use pdfConfiguration instead")
          // ignore: deprecated_member_use_from_same_package
          IOSWKPDFConfiguration? iosWKPdfConfiguration,
      PDFConfiguration? pdfConfiguration}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('pdfConfiguration',
        () => pdfConfiguration?.toMap() ?? iosWKPdfConfiguration?.toMap());
    return await _channel.invokeMethod('createPdf', args);
  }

  ///Creates a web archive of the web view’s current contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///
  ///**NOTE**: available only on iOS 14.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.createWebArchiveData](https://developer.apple.com/documentation/webkit/wkwebview/3650491-createwebarchivedata))
  Future<Uint8List?> createWebArchiveData() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('createWebArchiveData', args);
  }

  ///A Boolean value indicating whether all resources on the page have been loaded over securely encrypted connections.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.hasOnlySecureContent](https://developer.apple.com/documentation/webkit/wkwebview/1415002-hasonlysecurecontent))
  Future<bool> hasOnlySecureContent() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('hasOnlySecureContent', args);
  }

  ///Pauses playback of all media in the web view.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.pauseAllMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebview/3752240-pauseallmediaplayback)).
  Future<void> pauseAllMediaPlayback() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('pauseAllMediaPlayback', args);
  }

  ///Changes whether the webpage is suspending playback of all media in the page.
  ///Pass `true` to pause all media the web view is playing. Neither the user nor the webpage can resume playback until you call this method again with `false`.
  ///
  ///[suspended] represents a [bool] value that indicates whether the webpage should suspend media playback.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.setAllMediaPlaybackSuspended](https://developer.apple.com/documentation/webkit/wkwebview/3752242-setallmediaplaybacksuspended)).
  Future<void> setAllMediaPlaybackSuspended({required bool suspended}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent("suspended", () => suspended);
    return await _channel.invokeMethod('setAllMediaPlaybackSuspended', args);
  }

  ///Closes all media the web view is presenting, including picture-in-picture video and fullscreen video.
  ///
  ///**NOTE for iOS**: available on iOS 14.5+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.closeAllMediaPresentations](https://developer.apple.com/documentation/webkit/wkwebview/3752235-closeallmediapresentations)).
  Future<void> closeAllMediaPresentations() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('closeAllMediaPresentations', args);
  }

  ///Requests the playback status of media in the web view.
  ///Returns a [MediaPlaybackState] that indicates whether the media in the web view is playing, paused, or suspended.
  ///If there’s no media in the web view to play, this method provides [MediaPlaybackState.NONE].
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.requestMediaPlaybackState](https://developer.apple.com/documentation/webkit/wkwebview/3752241-requestmediaplaybackstate)).
  Future<MediaPlaybackState?> requestMediaPlaybackState() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return MediaPlaybackState.fromValue(
        await _channel.invokeMethod('requestMediaPlaybackState', args));
  }
}

///Use [InAppWebViewController] instead.
@Deprecated("Use InAppWebViewController instead")
class IOSInAppWebViewController with AppleInAppWebViewControllerMixin {
  late MethodChannel _channel;
  IOSInAppWebViewController({required MethodChannel channel}) {
    this._channel = channel;
  }

  ///Use [InAppWebViewController.handlesURLScheme] instead.
  @Deprecated("Use InAppWebViewController.handlesURLScheme instead")
  static Future<bool> handlesURLScheme(String urlScheme) async {
    return await InAppWebViewController.handlesURLScheme(urlScheme);
  }
}
