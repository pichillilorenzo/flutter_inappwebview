import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';
import '.env.dart';

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
        key: this.scaffoldKey,
        appBar: myAppBar(state: this, title: appBarTitle),
        drawer: myDrawer(context: context),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialUrl: "http://${environment["NODE_SERVER_IP"]}:8081/",
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
                    onLoadStop: (InAppWebViewController controller, String url) async {
                      String h1Content = await controller.evaluateJavascript(source: "document.body.querySelector('h1').textContent");
                      setState(() {
                        appBarTitle = h1Content;
                      });
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
