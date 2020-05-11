import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';

class InAppWebViewOnLoadErrorTest extends WidgetTest {
  final InAppWebViewOnLoadErrorTestState state = InAppWebViewOnLoadErrorTestState();

  @override
  InAppWebViewOnLoadErrorTestState createState() => state;
}

class InAppWebViewOnLoadErrorTestState extends WidgetTestState {

  String appBarTitle = "InAppWebViewOnLoadErrorTest";

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
                    initialUrl: "https://not-existing-domain.org/",
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
                    onLoadError: (InAppWebViewController controller, String url, int code, String message) async {
                      setState(() {
                        appBarTitle = code.toString();
                      });
                    }
                  ),
                ),
              ),
            ])
        )
    );
  }
}
