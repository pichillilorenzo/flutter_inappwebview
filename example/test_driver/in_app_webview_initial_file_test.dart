import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'main_test.dart';
import 'util_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewInitialFileTest extends WidgetTest {
  final InAppWebViewInitialFileTestState state = InAppWebViewInitialFileTestState();

  @override
  InAppWebViewInitialFileTestState createState() => state;
}

class InAppWebViewInitialFileTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewInitialFileTest";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar(state: this, title: appBarTitle),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialFile: "test_assets/in_app_webview_initial_file_test.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewWidgetOptions(
                        inAppWebViewOptions: InAppWebViewOptions(
                            clearCache: true,
                            debuggingEnabled: true
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {
                      setState(() {
                        appBarTitle = "true";
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
