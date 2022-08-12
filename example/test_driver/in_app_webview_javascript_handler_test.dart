import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main_test.dart';
import 'custom_widget_test.dart';

class Foo {
  String bar;
  String baz;

  Foo({this.bar, this.baz});

  Map<String, dynamic> toJson() {
    return {
      'bar': this.bar,
      'baz': this.baz
    };
  }
}

class InAppWebViewJavaScriptHandlerTest extends WidgetTest {
  final InAppWebViewJavaScriptHandlerTestState state = InAppWebViewJavaScriptHandlerTestState();

  @override
  InAppWebViewJavaScriptHandlerTestState createState() => state;
}

class InAppWebViewJavaScriptHandlerTestState extends WidgetTestState {

  String appBarTitle = "InAppWebViewJavaScriptHandlerTest";

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
                    initialFile: "test_assets/in_app_webview_javascript_handler_test.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                            clearCache: true,
                            debuggingEnabled: true
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;

                      controller.addJavaScriptHandler(handlerName:'handlerFoo', callback: (args) {
                        appBarTitle = (args.length == 0).toString();
                        return Foo(bar: 'bar_value', baz: 'baz_value');
                      });

                      controller.addJavaScriptHandler(handlerName: 'handlerFooWithArgs', callback: (args) {
                        appBarTitle += " " + (args[0] is int).toString();
                        appBarTitle += " " + (args[1] is bool).toString();
                        appBarTitle += " " + (args[2] is List).toString();
                        appBarTitle += " " + (args[2] is List).toString();
                        appBarTitle += " " + (args[3] is Map).toString();
                        appBarTitle += " " + (args[4] is Map).toString();
                        setState(() { });
                      });

                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {

                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
