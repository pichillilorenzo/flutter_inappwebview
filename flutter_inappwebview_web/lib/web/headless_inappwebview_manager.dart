import 'package:web/web.dart';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'in_app_webview_manager.dart';
import 'in_app_web_view_web_element.dart';
import 'headless_in_app_web_view_web_element.dart';

class HeadlessInAppWebViewManager extends ChannelController {
  static final Map<String, HeadlessInAppWebViewWebElement?> webViews = {};

  late BinaryMessenger _messenger;

  HeadlessInAppWebViewManager({required BinaryMessenger messenger}) {
    this._messenger = messenger;
    channel = MethodChannel(
      'com.pichillilorenzo/flutter_headless_inappwebview',
      const StandardMethodCodec(),
      _messenger,
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "run":
        String id = call.arguments["id"];
        Map<String, dynamic> params = call.arguments["params"]
            .cast<String, dynamic>();
        run(id, params);
        break;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  void run(String id, Map<String, dynamic> params) {
    var webView = InAppWebViewWebElement(viewId: id, messenger: _messenger);
    var headlessWebView = HeadlessInAppWebViewWebElement(
      id: id,
      messenger: _messenger,
      webView: webView,
    );
    InAppWebViewManager.webViews.putIfAbsent(id, () => webView);
    HeadlessInAppWebViewManager.webViews.putIfAbsent(id, () => headlessWebView);
    prepare(webView, params);
    headlessWebView.onWebViewCreated();
    webView.makeInitialLoad();
  }

  void prepare(InAppWebViewWebElement webView, Map<String, dynamic> params) {
    webView.iframeContainer.style.display = 'none';
    Map<String, num>? initialSize = params["initialSize"]?.cast<String, num>();
    if (initialSize != null) {
      webView.iframeContainer.style.width =
          initialSize["width"].toString() + 'px';
      webView.iframeContainer.style.height =
          initialSize["height"].toString() + 'px';
    }
    Map<String, dynamic> initialSettings = params["initialSettings"]
        .cast<String, dynamic>();
    if (initialSettings.isEmpty) {
      webView.initialSettings = InAppWebViewSettings();
    } else {
      webView.initialSettings = InAppWebViewSettings.fromMap(initialSettings);
    }
    webView.initialUrlRequest = URLRequest.fromMap(
      params["initialUrlRequest"]?.cast<String, dynamic>(),
    );
    webView.initialFile = params["initialFile"];
    webView.initialData = InAppWebViewInitialData.fromMap(
      params["initialData"]?.cast<String, dynamic>(),
    );
    webView.initialUserScripts = params["initialUserScripts"];
    document.body?.append(webView.iframeContainer);
    webView.prepare();
  }

  @override
  void dispose() {
    disposeChannel();
  }
}
