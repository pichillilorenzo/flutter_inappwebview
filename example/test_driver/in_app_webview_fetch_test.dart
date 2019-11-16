import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'main_test.dart';
import 'util_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewFetchTest extends WidgetTest {
  final InAppWebViewFetchTestState state = InAppWebViewFetchTestState();

  @override
  InAppWebViewFetchTestState createState() => state;
}

class InAppWebViewFetchTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewFetchTest";
  int totTests = 2;
  int testsDone = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar(state: this, title: appBarTitle),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialFile: "test_assets/in_app_webview_fetch_test.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewWidgetOptions(
                        inAppWebViewOptions: InAppWebViewOptions(
                            clearCache: true,
                            debuggingEnabled: true,
                            useShouldInterceptFetchRequest: true,
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;

                      webView.addJavaScriptHandler(handlerName: "fetchGet", callback: (args) {
                        appBarTitle = (appBarTitle == "InAppWebViewFetchTest") ? args[0].toString() : appBarTitle + " " + args[0].toString();
                        updateCountTest(context: context);
                      });

                      webView.addJavaScriptHandler(handlerName: "fetchPost", callback: (args) {
                        appBarTitle = (appBarTitle == "InAppWebViewFetchTest") ? args[0]["fullname"] : appBarTitle + " " + args[0]["fullname"];
                        updateCountTest(context: context);
                      });
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {

                    },
                    shouldInterceptFetchRequest: (InAppWebViewController controller, FetchRequest fetchRequest) async {
                      if (fetchRequest.url.endsWith("/test-ajax-post")) {
                        fetchRequest.body = utf8.encode("""{
                          "firstname": "Lorenzo",
                          "lastname": "Pichilli"
                        }
                        """);
                      }
                      return fetchRequest;
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }

  void updateCountTest({@required BuildContext context}) {
    testsDone++;
    if (testsDone == totTests) {
      setState(() {  });
      nextTest(context: context, state: this);
    }
  }
}
