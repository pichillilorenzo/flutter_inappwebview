import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';

class InAppWebViewOnSafeBrowsingHitTest extends WidgetTest {
  final InAppWebViewOnSafeBrowsingHitTestState state = InAppWebViewOnSafeBrowsingHitTestState();

  @override
  InAppWebViewOnSafeBrowsingHitTestState createState() => state;
}

class InAppWebViewOnSafeBrowsingHitTestState extends WidgetTestState {

  String appBarTitle = "InAppWebViewOnSafeBrowsingHitTest";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: this.scaffoldKey,
        appBar: myAppBar(state: this, title: appBarTitle),
        drawer: myDrawer(context: context),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialUrl: (Platform.isAndroid) ? "chrome://safe-browsing/match?type=malware" : "https://flutter.dev/",
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                            // if I set javaScriptEnabled to true, it will crash!
                            javaScriptEnabled: false,
                            clearCache: true,
                            debuggingEnabled: true
                        ),
                        android: AndroidInAppWebViewOptions(
                          safeBrowsingEnabled: true,
                        ),
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                      if(Platform.isAndroid)
                        controller.android.startSafeBrowsing();
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {
                      setState(() {
                        appBarTitle = url;
                      });
                    },
                    androidOnSafeBrowsingHit: (InAppWebViewController controller, String url, SafeBrowsingThreat threatType) async {
                      return SafeBrowsingResponse(report: true, action: SafeBrowsingResponseAction.PROCEED);
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
