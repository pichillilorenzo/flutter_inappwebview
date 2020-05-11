import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';
import '.env.dart';

class InAppWebViewHttpAuthCredentialDatabaseTest extends WidgetTest {
  final InAppWebViewHttpAuthCredentialDatabaseTestState state = InAppWebViewHttpAuthCredentialDatabaseTestState();

  @override
  InAppWebViewHttpAuthCredentialDatabaseTestState createState() => state;
}

class InAppWebViewHttpAuthCredentialDatabaseTestState extends WidgetTestState {

  String appBarTitle = "InAppWebViewHttpAuthCredentialDatabaseTest";
  HttpAuthCredentialDatabase httpAuthCredentialDatabase = HttpAuthCredentialDatabase.instance();

  @override
  Widget build(BuildContext context) {

    httpAuthCredentialDatabase.setHttpAuthCredential(
        protectionSpace: ProtectionSpace(host: environment["NODE_SERVER_IP"], protocol: "http", realm: "Node", port: 8081),
        credential: HttpAuthCredential(username: "USERNAME", password: "PASSWORD")
    );

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
                      var title = "";
                      String h1Content = await controller.evaluateJavascript(source: "document.body.querySelector('h1').textContent");
                      title = h1Content;
                      var credentials = await httpAuthCredentialDatabase.getHttpAuthCredentials(protectionSpace:
                        ProtectionSpace(host: environment["NODE_SERVER_IP"], protocol: "http", realm: "Node", port: 8081)
                      );
                      title += " " + ((credentials.length == 1) ? "true" : "false");
                      await httpAuthCredentialDatabase.clearAllAuthCredentials();
                      credentials = await httpAuthCredentialDatabase.getHttpAuthCredentials(protectionSpace:
                        ProtectionSpace(host: environment["NODE_SERVER_IP"], protocol: "http", realm: "Node", port: 8081)
                      );
                      title += " " + ((credentials.length == 0) ? "true" : "false");
                      setState(() {
                        appBarTitle = title;
                      });
                    },
                    onReceivedHttpAuthRequest: (InAppWebViewController controller, HttpAuthChallenge challenge) async {
                      return new HttpAuthResponse(action: HttpAuthResponseAction.USE_SAVED_HTTP_AUTH_CREDENTIALS);
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
