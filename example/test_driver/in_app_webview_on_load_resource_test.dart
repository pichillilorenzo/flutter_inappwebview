import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewOnLoadResourceTest extends WidgetTest {
  final InAppWebViewOnLoadResourceTestState state = InAppWebViewOnLoadResourceTestState();

  @override
  InAppWebViewOnLoadResourceTestState createState() => state;
}

class InAppWebViewOnLoadResourceTestState extends WidgetTestState {
  List<String> resourceList = [
    "https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css",
    "https://code.jquery.com/jquery-3.3.1.min.js",
    "https://via.placeholder.com/100x50"
  ];
  int countResources = 0;
  String appBarTitle = "InAppWebViewOnLoadResourceTest";

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
                    initialFile: "test_assets/in_app_webview_on_load_resource_test.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          clearCache: true,
                          debuggingEnabled: true,
                          useOnLoadResource: true
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {

                    },
                    onLoadResource: (InAppWebViewController controller, LoadedResource response) {
                      appBarTitle = (appBarTitle == "InAppWebViewOnLoadResourceTest") ? response.url : appBarTitle + " " + response.url;
                      countResources++;
                      if (countResources == resourceList.length) {
                        setState(() {  });
                      }
                    }
                  ),
                ),
              ),
            ])
        )
    );
  }
}
