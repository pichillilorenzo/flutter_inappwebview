import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:talkjs_flutter_inappwebview/talkjs_flutter_inappwebview.dart';

import 'main.dart';

class MyInAppBrowser extends InAppBrowser {
  MyInAppBrowser(
      {int? windowId, UnmodifiableListView<UserScript>? initialUserScripts})
      : super(windowId: windowId, initialUserScripts: initialUserScripts);

  @override
  Future onBrowserCreated() async {
    print("\n\nBrowser Created!\n\n");
  }

  @override
  Future onLoadStart(url) async {}

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
  }

  @override
  Future<PermissionResponse> onPermissionRequest(request) async {
    return PermissionResponse(
        resources: request.resources, action: PermissionResponseAction.GRANT);
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      navigationAction) async {
    print("\n\nOverride ${navigationAction.request.url}\n\n");
    return NavigationActionPolicy.ALLOW;
  }
}

class InAppBrowserExampleScreen extends StatefulWidget {
  final MyInAppBrowser browser = new MyInAppBrowser();

  @override
  _InAppBrowserExampleScreenState createState() =>
      new _InAppBrowserExampleScreenState();
}

class _InAppBrowserExampleScreenState extends State<InAppBrowserExampleScreen> {
  PullToRefreshController? pullToRefreshController;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.black,
            ),
            onRefresh: () async {
              if (Platform.isAndroid) {
                widget.browser.webViewController?.reload();
              } else if (Platform.isIOS) {
                widget.browser.webViewController?.loadUrl(
                    urlRequest: URLRequest(
                        url: await widget.browser.webViewController?.getUrl()));
              }
            },
          );
    widget.browser.pullToRefreshController = pullToRefreshController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          "InAppBrowser",
        )),
        drawer: myDrawer(context: context),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              ElevatedButton(
                  onPressed: () async {
                    await widget.browser.openUrlRequest(
                      urlRequest:
                          URLRequest(url: WebUri("https://flutter.dev")),
                      settings: InAppBrowserClassSettings(
                        browserSettings: InAppBrowserSettings(
                            toolbarTopBackgroundColor: Colors.blue,
                            presentationStyle: ModalPresentationStyle.POPOVER),
                        webViewSettings: InAppWebViewSettings(
                          useShouldOverrideUrlLoading: true,
                          useOnLoadResource: true,
                        ),
                      ),
                    );
                  },
                  child: Text("Open In-App Browser")),
              Container(height: 40),
              ElevatedButton(
                  onPressed: () async {
                    await InAppBrowser.openWithSystemBrowser(
                        url: WebUri("https://flutter.dev/"));
                  },
                  child: Text("Open System Browser")),
            ])));
  }
}
