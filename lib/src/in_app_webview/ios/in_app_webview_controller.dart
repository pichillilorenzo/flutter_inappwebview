import 'dart:async';
import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../_static_channel.dart';

import '../../types.dart';

///Class represents the iOS controller that contains only iOS-specific methods for the WebView.
class IOSInAppWebViewController {
  late MethodChannel _channel;
  static MethodChannel _staticChannel = IN_APP_WEBVIEW_STATIC_CHANNEL;

  IOSInAppWebViewController({required MethodChannel channel}) {
    this._channel = channel;
  }

  ///Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkwebview/1414956-reloadfromorigin
  Future<void> reloadFromOrigin() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel.invokeMethod('reloadFromOrigin', args);
  }

  ///Generates PDF data from the web view’s contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///
  ///[iosWKPdfConfiguration] represents the object that specifies the portion of the web view to capture as PDF data.
  ///
  ///**NOTE**: available only on iOS 14.0+.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkwebview/3650490-createpdf
  Future<Uint8List?> createPdf(
      {IOSWKPDFConfiguration? iosWKPdfConfiguration}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent(
        'iosWKPdfConfiguration', () => iosWKPdfConfiguration?.toMap());
    return await _channel.invokeMethod('createPdf', args);
  }

  ///Creates a web archive of the web view’s current contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///
  ///**NOTE**: available only on iOS 14.0+.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkwebview/3650491-createwebarchivedata
  Future<Uint8List?> createWebArchiveData() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('createWebArchiveData', args);
  }

  ///A Boolean value indicating whether all resources on the page have been loaded over securely encrypted connections.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkwebview/1415002-hasonlysecurecontent
  Future<bool> hasOnlySecureContent() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel.invokeMethod('hasOnlySecureContent', args);
  }

  ///Returns a Boolean value that indicates whether WebKit natively supports resources with the specified URL scheme.
  ///
  ///[urlScheme] represents the URL scheme associated with the resource.
  ///
  ///**NOTE**: available only on iOS 11.0+.
  ///
  ///**Official iOS API**: https://developer.apple.com/documentation/webkit/wkwebview/2875370-handlesurlscheme
  static Future<bool> handlesURLScheme(String urlScheme) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('urlScheme', () => urlScheme);
    return await _staticChannel.invokeMethod('handlesURLScheme', args);
  }
}
