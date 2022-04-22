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
  bool isLoading = false;

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
        await loadUrl(urlRequest: urlRequest);
        break;
      case "loadData":
        String data = call.arguments["data"];
        String mimeType = call.arguments["mimeType"];
        await loadData(data: data, mimeType: mimeType);
        break;
      case "loadFile":
        String assetFilePath = call.arguments["assetFilePath"];
        await loadFile(assetFilePath: assetFilePath);
        break;
      case "reload":
        await reload();
        break;
      case "goBack":
        await goBack();
        break;
      case "goForward":
        await goForward();
        break;
      case "goBackOrForward":
        int steps = call.arguments["steps"];
        await goBackOrForward(steps: steps);
        break;
      case "isLoading":
        return isLoading;
      case "evaluateJavascript":
        String source = call.arguments["source"];
        return await evaluateJavascript(source: source);
      case "stopLoading":
        await stopLoading();
        break;
      case "getSettings":
        return await settings.toMap();
      case "setSettings":
        InAppWebViewSettings newSettings = InAppWebViewSettings.fromMap(call.arguments["settings"].cast<String, dynamic>());
        setSettings(newSettings);
        break;
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
      loadUrl(urlRequest: initialUrlRequest!);
    } else if (initialData != null) {
      loadData(data: initialData!.data, mimeType: initialData!.mimeType);
    } else if (initialFile != null) {
      loadFile(assetFilePath: initialFile!);
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

  Future<void> loadUrl({required URLRequest urlRequest}) async {
    if ((urlRequest.method == null || urlRequest.method == "GET") &&
        (urlRequest.headers == null || urlRequest.headers!.isEmpty)) {
      iframe.src = urlRequest.url.toString();
    } else {
      iframe.src = _convertHttpResponseToData(await _makeRequest(urlRequest));
    }
  }

  Future<void> loadData({required String data, String mimeType = "text/html"}) async {
    iframe.src = 'data:$mimeType,' + Uri.encodeFull(data);
  }

  Future<void> loadFile({required String assetFilePath}) async {
    iframe.src = assetFilePath;
  }

  Future<void> reload() async {
    bridgeJsObject.callMethod("reload");
  }

  Future<void> goBack() async {
    bridgeJsObject.callMethod("goBack");
  }

  Future<void> goForward() async {
    bridgeJsObject.callMethod("goForward");
  }

  Future<void> goBackOrForward({required int steps}) async {
    bridgeJsObject.callMethod("goBackOrForward", [steps]);
  }

  Future<dynamic> evaluateJavascript({required String source}) async {
    return bridgeJsObject.callMethod("evaluateJavascript", [source]);
  }

  Future<void> stopLoading() async {
    bridgeJsObject.callMethod("stopLoading");
  }

  Future<void> setSettings(InAppWebViewSettings newSettings) async {
    if (settings.iframeAllow != newSettings.iframeAllow) {
      iframe.allow = newSettings.iframeAllow;
    }
    if (settings.iframeAllowFullscreen != newSettings.iframeAllowFullscreen) {
      iframe.allowFullscreen = newSettings.iframeAllowFullscreen;
    }
    if (settings.iframeSandox != newSettings.iframeSandox) {
      iframe.setAttribute("sandbox", newSettings.iframeSandox ?? "");
    }
    if (settings.iframeWidth != newSettings.iframeWidth) {
      iframe.style.width = newSettings.iframeWidth;
    }
    if (settings.iframeHeight != newSettings.iframeHeight) {
      iframe.style.height = newSettings.iframeHeight;
    }
    if (settings.iframeReferrerPolicy != newSettings.iframeReferrerPolicy) {
      iframe.referrerPolicy = newSettings.iframeReferrerPolicy;
    }
    if (settings.iframeName != newSettings.iframeName) {
      iframe.name = newSettings.iframeName;
    }
    if (settings.iframeCsp != newSettings.iframeCsp) {
      iframe.csp = newSettings.iframeCsp;
    }
    settings = newSettings;
  }

  onLoadStart(String url) async {
    isLoading = true;

    var obj = {
      "url": url
    };
    _channel.invokeMethod("onLoadStart", obj);
  }

  onLoadStop(String url) async {
    isLoading = false;

    var obj = {
      "url": url
    };
    _channel.invokeMethod("onLoadStop", obj);
  }

  onUpdateVisitedHistory(String url) async {
    var obj = {
      "url": url
    };
    _channel.invokeMethod("onUpdateVisitedHistory", obj);
  }
}
