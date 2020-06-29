import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewOnCreateWindowTest extends WidgetTest {
  final InAppWebViewOnCreateWindowTestState state = InAppWebViewOnCreateWindowTestState();

  @override
  InAppWebViewOnCreateWindowTestState createState() => state;
}

class InAppWebViewOnCreateWindowTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewOnCreateWindowTest";

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
                    initialFile: "test_assets/in_app_webview_on_create_window_test.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                            clearCache: true,
                            debuggingEnabled: true,
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
                    onCreateWindow: (InAppWebViewController controller, CreateWindowRequest createWindowRequest) async {
                      controller.loadUrl(url: createWindowRequest.url);
                      return null;
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
