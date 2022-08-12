import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';

class InAppWebViewShouldOverrideUrlLoadingTest extends WidgetTest {
  final InAppWebViewShouldOverrideUrlLoadingTestState state = InAppWebViewShouldOverrideUrlLoadingTestState();

  @override
  InAppWebViewShouldOverrideUrlLoadingTestState createState() => state;
}

class InAppWebViewShouldOverrideUrlLoadingTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewShouldOverrideUrlLoadingTest";

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
                    initialFile: "test_assets/in_app_webview_initial_file_test.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
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
                      if (url == "https://flutter.dev/") {
                        setState(() {
                          appBarTitle = url;
                        });
                      } else {
                        controller.evaluateJavascript(source: "document.querySelector('#link').click();");
                      }
                    },
                    shouldOverrideUrlLoading: (InAppWebViewController controller, ShouldOverrideUrlLoadingRequest shouldOverrideUrlLoadingRequest) async {
                      if (Platform.isAndroid || shouldOverrideUrlLoadingRequest.iosWKNavigationType == IOSWKNavigationType.LINK_ACTIVATED) {
                        await controller.loadUrl(url: "https://flutter.dev/");
                        return ShouldOverrideUrlLoadingAction.CANCEL;
                      }
                      return ShouldOverrideUrlLoadingAction.ALLOW;
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
