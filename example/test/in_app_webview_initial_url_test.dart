import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'util_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewInitialUrlTest extends WidgetTest {
  InAppWebViewInitialUrlTest(): super(name: "InAppWebViewInitialUrlTest");

  @override
  _InAppWebViewInitialUrlTestState createState() => new _InAppWebViewInitialUrlTestState();
}

class _InAppWebViewInitialUrlTestState extends State<InAppWebViewInitialUrlTest> {
  InAppWebViewController webView;
  String initialUrl = "https://flutter.dev/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('InAppWebViewInitialUrlTest'),
        ),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialUrl: initialUrl,
                    initialHeaders: {},
                    initialOptions: InAppWebViewWidgetOptions(),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {
                      customAssert(widget: widget, name: "initialUrl", value: url == initialUrl);
                      nextTest(context: context);
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
