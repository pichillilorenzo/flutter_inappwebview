import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:html';

import '../in_app_webview/in_app_webview_settings.dart';
import '../types.dart';

class InAppWebViewWebElement {
  late int _viewId;
  late BinaryMessenger _messenger;
  late IFrameElement iframe;
  late MethodChannel _channel;
  InAppWebViewSettings? initialSettings;
  URLRequest? initialUrlRequest;
  InAppWebViewInitialData? initialData;
  String? initialFile;

  late InAppWebViewSettings settings;

  InAppWebViewWebElement({required int viewId, required BinaryMessenger messenger}) {
    this._viewId = viewId;
    this._messenger = messenger;
    iframe = IFrameElement()
      ..id = 'flutter_inappwebview-$_viewId'
      ..style.border = 'none';

    _channel = MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_$_viewId',
      const StandardMethodCodec(),
      _messenger,
    );

    this._channel.setMethodCallHandler(handleMethodCall);

    iframe.addEventListener('load', (event) async {
      var obj = {
        "url": iframe.src
      };
      _channel.invokeMethod("onLoadStart", obj);
      await Future.delayed(Duration(milliseconds: 100));
      _channel.invokeMethod("onLoadStop", obj);
    });
  }

  /// Handles method calls over the MethodChannel of this plugin.
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case "loadUrl":
        URLRequest urlRequest = URLRequest.fromMap(call.arguments["urlRequest"].cast<String, dynamic>())!;
        await _loadUrl(urlRequest: urlRequest);
        break;
      case "loadData":
        String data = call.arguments["data"];
        String mimeType = call.arguments["mimeType"];
        await _loadData(data: data, mimeType: mimeType);
        break;
      case "loadFile":
        String assetFilePath = call.arguments["assetFilePath"];
        await _loadFile(assetFilePath: assetFilePath);
        break;
      case "reload":
        await _reload();
        break;
      case "getIFrameId":
        return iframe.id;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'flutter_inappwebview for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  void prepare() {
    settings = initialSettings ?? InAppWebViewSettings();
    iframe.allow = settings.iframeAllow ?? iframe.allow;
    iframe.allowFullscreen = settings.iframeAllowFullscreen ?? iframe.allowFullscreen;
    if (settings.iframeSandox != null) {
      iframe.setAttribute("sandbox", settings.iframeSandox ?? "");
    }
    var width = settings.iframeWidth ?? iframe.width;
    if (width == null || width.isEmpty) {
      width = '100%';
    }
    var height = settings.iframeHeight ?? iframe.height;
    if (height == null || height.isEmpty) {
      height = '100%';
    }
    iframe.width = iframe.style.width = width;
    iframe.height = iframe.style.height = height;
    iframe.referrerPolicy = settings.iframeReferrerPolicy ?? iframe.referrerPolicy;
    iframe.name = settings.iframeName ?? iframe.name;
    iframe.csp = settings.iframeCsp ?? iframe.csp;
  }

  void makeInitialLoad() async {
    if (initialUrlRequest != null) {
      _loadUrl(urlRequest: initialUrlRequest!);
    } else if (initialData != null) {
      _loadData(data: initialData!.data, mimeType: initialData!.mimeType);
    } else if (initialFile != null) {
      _loadFile(assetFilePath: initialFile!);
    }
  }

  Future<HttpRequest> _makeRequest(URLRequest urlRequest, {bool? withCredentials, String? responseType, String? mimeType, void onProgress(ProgressEvent e)?}) {
    return HttpRequest.request(
        urlRequest.url?.toString() ?? 'about:blank',
        method: urlRequest.method,
        requestHeaders: urlRequest.headers,
        sendData: urlRequest.body,
        withCredentials: withCredentials,
        responseType: responseType,
        mimeType: mimeType,
        onProgress: onProgress
    );
  }

  String _convertHttpResponseToData(HttpRequest httpRequest) {
    final String contentType =
        httpRequest.getResponseHeader('content-type') ?? 'text/html';
    return 'data:$contentType,' + Uri.encodeFull(httpRequest.responseText ?? '');
  }

  Future<void> _loadUrl({required URLRequest urlRequest}) async {
    if ((urlRequest.method == null || urlRequest.method == "GET") &&
        (urlRequest.headers == null || urlRequest.headers!.isEmpty)) {
      iframe.src = urlRequest.url.toString();
    } else {
      iframe.src = _convertHttpResponseToData(await _makeRequest(urlRequest));
    }
  }

  Future<void> _loadData({required String data, String mimeType = "text/html"}) async {
    iframe.src = 'data:$mimeType,' + Uri.encodeFull(data);
  }

  Future<void> _loadFile({required String assetFilePath}) async {
    iframe.src = assetFilePath;
  }

  Future<void> _reload() async {
    var src = iframe.src;
    if (src != null) {
      iframe.contentWindow?.location.href = src;
    }
  }
}
