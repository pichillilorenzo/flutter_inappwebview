import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../../types/main.dart';
import '../in_app_webview_controller.dart';

///Use [InAppWebViewController] instead.
@Deprecated("Use InAppWebViewController instead")
class IOSInAppWebViewController {
  MethodChannel? _channel;

  IOSInAppWebViewController({required MethodChannel channel}) {
    this._channel = channel;
  }

  ///Use [InAppWebViewController.reloadFromOrigin] instead.
  @Deprecated("Use InAppWebViewController.reloadFromOrigin instead")
  Future<void> reloadFromOrigin() async {
    Map<String, dynamic> args = <String, dynamic>{};
    await _channel?.invokeMethod('reloadFromOrigin', args);
  }

  ///Use [InAppWebViewController.createPdf] instead.
  @Deprecated("Use InAppWebViewController.createPdf instead")
  Future<Uint8List?> createPdf(
      {@Deprecated("Use pdfConfiguration instead")
      // ignore: deprecated_member_use_from_same_package
      IOSWKPDFConfiguration? iosWKPdfConfiguration,
      PDFConfiguration? pdfConfiguration}) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('pdfConfiguration',
        () => pdfConfiguration?.toMap() ?? iosWKPdfConfiguration?.toMap());
    return await _channel?.invokeMethod('createPdf', args);
  }

  ///Use [InAppWebViewController.createWebArchiveData] instead.
  @Deprecated("Use InAppWebViewController.createWebArchiveData instead")
  Future<Uint8List?> createWebArchiveData() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel?.invokeMethod('createWebArchiveData', args);
  }

  ///Use [InAppWebViewController.hasOnlySecureContent] instead.
  @Deprecated("Use InAppWebViewController.hasOnlySecureContent instead")
  Future<bool> hasOnlySecureContent() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await _channel?.invokeMethod('hasOnlySecureContent', args);
  }

  ///Use [InAppWebViewController.handlesURLScheme] instead.
  @Deprecated("Use InAppWebViewController.handlesURLScheme instead")
  static Future<bool> handlesURLScheme(String urlScheme) async {
    return await InAppWebViewController.handlesURLScheme(urlScheme);
  }

  void dispose() {
    _channel = null;
  }
}
