import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';
import 'util_test.dart';

class InAppWebViewOnReceivedHttpAuthRequestTest extends WidgetTest {
  final InAppWebViewOnReceivedHttpAuthRequestTestState state = InAppWebViewOnReceivedHttpAuthRequestTestState();

  @override
  InAppWebViewOnReceivedHttpAuthRequestTestState createState() => state;
}

class InAppWebViewOnReceivedHttpAuthRequestTestState extends WidgetTestState {

  String appBarTitle = "InAppWebViewOnReceivedHttpAuthRequestTest";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar(state: this, title: appBarTitle),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialUrl: "http://192.168.1.20:8081/",
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
                    onLoadStop: (InAppWebViewController controller, String url) async {
                      String h1Content = await controller.evaluateJavascript(source: "document.body.querySelector('h1').textContent");
                      setState(() {
                        appBarTitle = h1Content;
                      });
                      nextTest(context: context, state: this);
                    },
                    onReceivedHttpAuthRequest: (InAppWebViewController controller, HttpAuthChallenge challenge) async {
                      return new HttpAuthResponse(
                          username: "USERNAME",
                          password: "PASSWORD",
                          action: HttpAuthResponseAction.PROCEED,
                          permanentPersistence: true);
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
