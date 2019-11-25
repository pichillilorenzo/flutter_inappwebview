import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'main_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewOnConsoleMessageTest extends WidgetTest {
  final InAppWebViewOnConsoleMessageTestState state = InAppWebViewOnConsoleMessageTestState();

  @override
  InAppWebViewOnConsoleMessageTestState createState() => state;
}

class InAppWebViewOnConsoleMessageTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewOnConsoleMessageTest";

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
                    initialFile: "test_assets/in_app_webview_on_console_message_test.html",
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
                    onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
                      setState(() {
                        appBarTitle = consoleMessage.message + " " + consoleMessage.messageLevel.toString();
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
