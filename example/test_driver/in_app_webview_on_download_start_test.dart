import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'main_test.dart';
import 'util_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewOnDownloadStartTest extends WidgetTest {
  final InAppWebViewOnDownloadStartTestState state = InAppWebViewOnDownloadStartTestState();

  @override
  InAppWebViewOnDownloadStartTestState createState() => state;
}

class InAppWebViewOnDownloadStartTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewOnDownloadStartTest";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar(state: this, title: appBarTitle),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialFile: "test_assets/in_app_webview_on_downlaod_start_test.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewWidgetOptions(
                        inAppWebViewOptions: InAppWebViewOptions(
                            clearCache: true,
                            debuggingEnabled: true,
                            useOnDownloadStart: true
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {

                    },
                    onDownloadStart: (InAppWebViewController controller, String url) {
                      setState(() {
                        appBarTitle = url;
                      });
                      nextTest(context: context, state: this);
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
