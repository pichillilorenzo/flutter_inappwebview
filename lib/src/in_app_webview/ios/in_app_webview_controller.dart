import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../../types.dart';
import '../in_app_webview_controller.dart';

///Class mixin that contains only iOS-specific methods for the WebView.
abstract class IOSInAppWebViewControllerMixin {
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
      // ignore: deprecated_member_use_from_same_package
      {@Deprecated("Use pdfConfiguration instead") IOSWKPDFConfiguration? iosWKPdfConfiguration,
        PDFConfiguration? pdfConfiguration}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent(
        'pdfConfiguration', () => pdfConfiguration?.toMap() ?? iosWKPdfConfiguration?.toMap());
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
}

///Use [InAppWebViewController] instead.
@Deprecated("Use InAppWebViewController instead")
class IOSInAppWebViewController with IOSInAppWebViewControllerMixin {
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
