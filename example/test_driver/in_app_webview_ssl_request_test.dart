import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';
import '.env.dart';

class InAppWebViewSslRequestTest extends WidgetTest {
  final InAppWebViewSslRequestTestState state = InAppWebViewSslRequestTestState();

  @override
  InAppWebViewSslRequestTestState createState() => state;
}

class InAppWebViewSslRequestTestState extends WidgetTestState {

  String appBarTitle = "InAppWebViewSslRequestTest";

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
                    initialUrl: "https://${environment["NODE_SERVER_IP"]}:4433/",
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
                    onReceivedServerTrustAuthRequest: (InAppWebViewController controller, ServerTrustChallenge challenge) async {
                      return new ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                    },
                    onReceivedClientCertRequest: (InAppWebViewController controller, ClientCertChallenge challenge) async {
                      return new ClientCertResponse(
                          certificatePath: "test_assets/certificate.pfx",
                          certificatePassword: "",
                          androidKeyStoreType: "PKCS12",
                          action: ClientCertResponseAction.PROCEED);
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
