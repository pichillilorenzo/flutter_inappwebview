import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'main_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewOnTargetBlankTest extends WidgetTest {
  final InAppWebViewOnTargetBlankTestState state = InAppWebViewOnTargetBlankTestState();

  @override
  InAppWebViewOnTargetBlankTestState createState() => state;
}

class InAppWebViewOnTargetBlankTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewOnTargetBlankTest";

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
                    initialFile: "test_assets/in_app_webview_on_target_blank_test.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewWidgetOptions(
                        inAppWebViewOptions: InAppWebViewOptions(
                            clearCache: true,
                            debuggingEnabled: true,
                            useOnTargetBlank: true,
                            javaScriptCanOpenWindowsAutomatically: true,
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {
                      if (url == "https://flutter.dev/") {
                        setState(() {
                          appBarTitle = url;
                        });
                      }
                    },
                    onTargetBlank: (InAppWebViewController controller, String url) {
                      controller.loadUrl(url: url);
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
