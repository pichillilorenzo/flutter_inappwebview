import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';
import 'util_test.dart';

class InAppWebViewInitialUrlTest extends WidgetTest {
  final InAppWebViewInitialUrlTestState state = InAppWebViewInitialUrlTestState();

  @override
  InAppWebViewInitialUrlTestState createState() => state;
}

class InAppWebViewInitialUrlTestState extends WidgetTestState {
  String initialUrl = "https://flutter.dev/";
  String appBarTitle = "InAppWebViewInitialUrlTest";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar(state: this, title: appBarTitle),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialUrl: initialUrl,
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
                        appBarTitle = url;
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
