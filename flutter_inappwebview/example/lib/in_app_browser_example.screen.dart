import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main.dart';

class MyInAppBrowser extends InAppBrowser {
  MyInAppBrowser(
      {int? windowId,
      UnmodifiableListView<UserScript>? initialUserScripts,
      PullToRefreshController? pullToRefreshController})
      : super(
          windowId: windowId,
          initialUserScripts: initialUserScripts,
          pullToRefreshController: pullToRefreshController,
          webViewEnvironment: webViewEnvironment,
        );

  @override
  void onBrowserCreated() {
    print("\n\nBrowser Created!\n\n");
  }

  @override
  void onLoadStart(url) {}

  @override
  void onLoadStop(url) {
    pullToRefreshController?.endRefreshing();
  }

  @override
  FutureOr<PermissionResponse> onPermissionRequest(request) {
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
  FutureOr<NavigationActionPolicy> shouldOverrideUrlLoading(
      navigationAction) {
    print("\n\nOverride ${navigationAction.request.url}\n\n");
    return NavigationActionPolicy.ALLOW;
  }

  void onMainWindowWillClose() {
    close();
  }
}

class InAppBrowserExampleScreen extends StatefulWidget {
  @override
  _InAppBrowserExampleScreenState createState() =>
      _InAppBrowserExampleScreenState();
}

class _InAppBrowserExampleScreenState extends State<InAppBrowserExampleScreen> {
  late final MyInAppBrowser browser;

  @override
  void initState() {
    super.initState();

    PullToRefreshController? pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.black,
            ),
            onRefresh: () async {
              if (Platform.isAndroid) {
                browser.webViewController?.reload();
              } else if (Platform.isIOS) {
                browser.webViewController?.loadUrl(
                    urlRequest: URLRequest(
                        url: await browser.webViewController?.getUrl()));
              }
            },
          );

    browser = MyInAppBrowser(pullToRefreshController: pullToRefreshController);
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
                    await browser.openUrlRequest(
                      urlRequest:
                          URLRequest(url: WebUri("https://flutter.dev")),
                      settings: InAppBrowserClassSettings(
                        browserSettings: InAppBrowserSettings(
                            toolbarTopBackgroundColor: Colors.blue,
                            presentationStyle: ModalPresentationStyle.POPOVER),
                        webViewSettings: InAppWebViewSettings(
                          isInspectable: kDebugMode,
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
