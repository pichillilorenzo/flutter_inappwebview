import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';
import 'util_test.dart';

class InAppWebViewShouldOverrideUrlLoadingTest extends WidgetTest {
  final InAppWebViewShouldOverrideUrlLoadingTestState state = InAppWebViewShouldOverrideUrlLoadingTestState();

  @override
  InAppWebViewShouldOverrideUrlLoadingTestState createState() => state;
}

class InAppWebViewShouldOverrideUrlLoadingTestState extends WidgetTestState {
  String url = "https://flutter.dev/";
  String appBarTitle = "InAppWebViewShouldOverrideUrlLoadingTest";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar(state: this, title: appBarTitle),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialUrl: "https://www.google.com/",
                    initialHeaders: {},
                    initialOptions: InAppWebViewWidgetOptions(
                        inAppWebViewOptions: InAppWebViewOptions(
                            clearCache: true,
                            debuggingEnabled: true,
                            useShouldOverrideUrlLoading: true
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {
                      setState(() {
                        appBarTitle = url;
                      });
                      nextTest(context: context, state: this);
                    },
                    shouldOverrideUrlLoading: (InAppWebViewController controller, String url) {
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
