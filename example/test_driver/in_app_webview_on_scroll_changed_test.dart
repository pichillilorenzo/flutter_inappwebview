import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';

class InAppWebViewOnScrollChangedTest extends WidgetTest {
  final InAppWebViewOnScrollChangedTestState state = InAppWebViewOnScrollChangedTestState();

  @override
  InAppWebViewOnScrollChangedTestState createState() => state;
}

class InAppWebViewOnScrollChangedTestState extends WidgetTestState {

  String appBarTitle = "InAppWebViewOnScrollChangedTest";
  bool scrolled = false;

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
                      controller.scrollTo(x: 0, y: 500);
                    },
                    onScrollChanged: (InAppWebViewController controller, int x, int y) {
                      if (!scrolled) {
                        scrolled = true;
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
