import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewOnNavigationStateChangeTest extends WidgetTest {
  final InAppWebViewOnNavigationStateChangeTestState state = InAppWebViewOnNavigationStateChangeTestState();

  @override
  InAppWebViewOnNavigationStateChangeTestState createState() => state;
}

class InAppWebViewOnNavigationStateChangeTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewOnNavigationStateChangeTest";

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
                      controller.evaluateJavascript(source: """
var state = {}
var title = ''
var url = 'first-push';
history.pushState(state, title, url);

setTimeout(function() {
    var url = 'second-push';
    history.pushState(state, title, url);
}, 100);
""");
                    },
                    onUpdateVisitedHistory: (InAppWebViewController controller, String url, bool androidIsReload) async {
                      if (url.endsWith("second-push")) {
                        setState(() {
                          appBarTitle += " " + url;
                        });
                      } else {
                        appBarTitle = url;
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
