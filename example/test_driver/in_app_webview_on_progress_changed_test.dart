import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';

class InAppWebViewOnProgressChangedTest extends WidgetTest {
  final InAppWebViewOnProgressChangedTestState state = InAppWebViewOnProgressChangedTestState();

  @override
  InAppWebViewOnProgressChangedTestState createState() => state;
}

class InAppWebViewOnProgressChangedTestState extends WidgetTestState {

  String appBarTitle = "InAppWebViewOnProgressChangedTest";

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
                    initialUrl: "https://flutter.dev/",
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

                    },
                    onProgressChanged: (InAppWebViewController controller, int progress) {
                      if (progress == 100) {
                        setState(() {
                          appBarTitle = "true";
                        });
                      }
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
