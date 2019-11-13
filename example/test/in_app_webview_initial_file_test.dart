import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'util_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewInitialFileTest extends WidgetTest {
  InAppWebViewInitialFileTest(): super(name: "InAppWebViewInitialFileTest");

  @override
  _InAppWebViewInitialFileTestState createState() => new _InAppWebViewInitialFileTestState();
}

class _InAppWebViewInitialFileTestState extends State<InAppWebViewInitialFileTest> {
  InAppWebViewController webView;
  String initialUrl = "https://flutter.dev/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('InAppWebViewInitialFileTest'),
        ),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialFile: "assets/index.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewWidgetOptions(),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {
                      customAssert(widget: widget, name: "initialFile", value: true);
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
