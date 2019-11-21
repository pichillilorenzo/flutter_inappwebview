import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';
import 'util_test.dart';

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
        appBar: myAppBar(state: this, title: appBarTitle),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialUrl: "chrome://safe-browsing/match?type=malware",
                    initialHeaders: {},
                    initialOptions: InAppWebViewWidgetOptions(
                        inAppWebViewOptions: InAppWebViewOptions(
                            // if I set javaScriptEnabled to true, it will crash!
                            javaScriptEnabled: false,
                            clearCache: true,
                            debuggingEnabled: true
                        ),
                        androidInAppWebViewOptions: AndroidInAppWebViewOptions(
                          databaseEnabled: true,
                          domStorageEnabled: true,
                          safeBrowsingEnabled: true,
                        ),
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                      if(Platform.isAndroid)
                        controller.startSafeBrowsing();
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {
                      setState(() {
                        appBarTitle = url;
                      });
                      nextTest(context: context, state: this);
                    },
                    onSafeBrowsingHit: (InAppWebViewController controller, String url, SafeBrowsingThreat threatType) async {
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
