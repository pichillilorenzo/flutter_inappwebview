import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:html';
import 'dart:js' as js;

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
  late js.JsObject bridgeJsObject;
  WebHistory webHistory = WebHistory(list: [], currentIndex: -1);

  InAppWebViewWebElement({required int viewId, required BinaryMessenger messenger}) {
    this._viewId = viewId;
    this._messenger = messenger;
    iframe = IFrameElement()
      ..id = 'flutter_inappwebview-$_viewId'
      ..style.height = '100%'
      ..style.width = '100%'
      ..style.border = 'none';

    _channel = MethodChannel(
      'com.pichillilorenzo/flutter_inappwebview_$_viewId',
      const StandardMethodCodec(),
      _messenger,
    );

    this._channel.setMethodCallHandler(handleMethodCall);

    bridgeJsObject = js.JsObject.fromBrowserObject(js.context['flutter_inappwebview']);
    bridgeJsObject['viewId'] = _viewId;
    bridgeJsObject['iframeId'] = iframe.id;
  }

  /// Handles method calls over the MethodChannel of this plugin.
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case "getIFrameId":
        return iframe.id;
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
      case "goBack":
        await _goBack();
        break;
      case "goForward":
        await _goForward();
        break;
      case "evaluateJavascript":
        String source = call.arguments["source"];
        return await _evaluateJavascript(source: source);
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
    iframe.style.width = settings.iframeWidth ?? iframe.style.width;
    iframe.style.height = settings.iframeHeight ?? iframe.style.height;
    iframe.referrerPolicy = settings.iframeReferrerPolicy ?? iframe.referrerPolicy;
    iframe.name = settings.iframeName ?? iframe.name;
    iframe.csp = settings.iframeCsp ?? iframe.csp;

    bridgeJsObject.callMethod("prepare");
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
    var obj = {
      "url": iframe.src
    };
    _channel.invokeMethod("onLoadStart", obj);
  }

  Future<void> _loadData({required String data, String mimeType = "text/html"}) async {
    iframe.src = 'data:$mimeType,' + Uri.encodeFull(data);
    var obj = {
      "url": iframe.src
    };
    _channel.invokeMethod("onLoadStart", obj);
  }

  Future<void> _loadFile({required String assetFilePath}) async {
    iframe.src = assetFilePath;
    var obj = {
      "url": iframe.src
    };
    _channel.invokeMethod("onLoadStart", obj);
  }

  Future<void> _reload() async {
    bridgeJsObject.callMethod("reload");
  }

  Future<void> _goBack() async {
    bridgeJsObject.callMethod("goBack");
  }

  Future<void> _goForward() async {
    bridgeJsObject.callMethod("goForward");
  }

  Future<dynamic> _evaluateJavascript({required String source}) async {
    return bridgeJsObject.callMethod("evaluateJavascript", [source]);
  }

  onIFrameLoaded(String url) async {
    var obj = {
      "url": url
    };
    _channel.invokeMethod("onLoadStop", obj);
  }
}
