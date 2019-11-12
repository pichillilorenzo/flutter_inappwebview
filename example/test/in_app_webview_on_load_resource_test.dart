import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'util_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewOnLoadResourceTest extends WidgetTest {
  InAppWebViewOnLoadResourceTest(): super(name: "InAppWebViewOnLoadResourceTest");

  @override
  _InAppWebViewOnLoadResourceTestState createState() => new _InAppWebViewOnLoadResourceTestState();
}

class _InAppWebViewOnLoadResourceTestState extends State<InAppWebViewOnLoadResourceTest> {
  InAppWebViewController webView;
  List<String> resourceList = [
    "http://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css",
    "https://code.jquery.com/jquery-3.3.1.min.js",
    "https://via.placeholder.com/100x50"
  ];
  int countResources = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('InAppWebViewOnLoadResourceTest'),
        ),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialFile: "assets/index.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewWidgetOptions(
                        inAppWebViewOptions: InAppWebViewOptions(
                          clearCache: true,
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
                      customAssert(widget: widget, name: "onLoadResource", value: resourceList.contains(response.url));
                      countResources++;
                      if (countResources == resourceList.length) {
                        nextTest(context: context);
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
