import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewOnFindResultReceivedTest extends WidgetTest {
  final InAppWebViewOnFindResultReceivedTestState state = InAppWebViewOnFindResultReceivedTestState();

  @override
  InAppWebViewOnFindResultReceivedTestState createState() => state;
}

class InAppWebViewOnFindResultReceivedTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewOnFindResultReceivedTest";

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
                    initialFile: "test_assets/in_app_webview_initial_file_test.html",
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
                    onLoadStop: (InAppWebViewController controller, String url) {
                      controller.findAllAsync(find: "InAppWebViewInitialFileTest");
                    },
                    onFindResultReceived: (InAppWebViewController controller, int activeMatchOrdinal, int numberOfMatches, bool isDoneCounting) async {
                      if (isDoneCounting) {
                        setState(() {
                          appBarTitle = numberOfMatches.toString();
                        });
                      }
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
