import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';

class InAppWebViewOnLoadHttpErrorTest extends WidgetTest {
  final InAppWebViewOnLoadHttpErrorTestState state = InAppWebViewOnLoadHttpErrorTestState();

  @override
  InAppWebViewOnLoadHttpErrorTestState createState() => state;
}

class InAppWebViewOnLoadHttpErrorTestState extends WidgetTestState {

  String appBarTitle = "InAppWebViewOnLoadHttpErrorTest";

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
                    initialUrl: "https://google.com/404",
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
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
                    onLoadHttpError: (InAppWebViewController controller, String url, int statusCode, String description) async {
                      setState(() {
                        appBarTitle = statusCode.toString();
                      });
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
