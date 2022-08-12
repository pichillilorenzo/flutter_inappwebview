import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewOnLoadResourceCustomSchemeTest extends WidgetTest {
  final InAppWebViewOnLoadResourceCustomSchemeTestState state = InAppWebViewOnLoadResourceCustomSchemeTestState();

  @override
  InAppWebViewOnLoadResourceCustomSchemeTestState createState() => state;
}

class InAppWebViewOnLoadResourceCustomSchemeTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewOnLoadResourceCustomSchemeTest";

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
                    initialFile: "test_assets/in_app_webview_on_load_resource_custom_scheme_test.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          clearCache: true,
                          debuggingEnabled: true,
                          resourceCustomSchemes: ["my-special-custom-scheme"]
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;

                      webView.addJavaScriptHandler(handlerName: "imageLoaded", callback: (args) {
                        setState(() {
                          appBarTitle = "true";
                        });
                      });
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {

                    },
                    onLoadResourceCustomScheme: (InAppWebViewController controller, String scheme, String url) async {
                      if (scheme == "my-special-custom-scheme") {
                        var bytes = await rootBundle.load("test_assets/" + url.replaceFirst("my-special-custom-scheme://", "", 0));
                        var response = CustomSchemeResponse(data: bytes.buffer.asUint8List(), contentType: "image/svg+xml", contentEnconding: "utf-8");
                        return response;
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
