import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'main_test.dart';
import 'util_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewAjaxTest extends WidgetTest {
  final InAppWebViewAjaxTestState state = InAppWebViewAjaxTestState();

  @override
  InAppWebViewAjaxTestState createState() => state;
}

class InAppWebViewAjaxTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewAjaxTest";
  int totTests = 2;
  int testsDone = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: myAppBar(state: this, title: appBarTitle),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialFile: "test_assets/in_app_webview_ajax_test.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewWidgetOptions(
                        inAppWebViewOptions: InAppWebViewOptions(
                            clearCache: true,
                            debuggingEnabled: true,
                            useShouldInterceptAjaxRequest: true,
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {

                    },
                    shouldInterceptAjaxRequest: (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
                      if (ajaxRequest.url.endsWith("/test-ajax-post")) {
                        ajaxRequest.responseType = 'json';
                        ajaxRequest.data = "firstname=Lorenzo&lastname=Pichilli";
                      }
                      return ajaxRequest;
                    },
                    onAjaxReadyStateChange: (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
                      if (ajaxRequest.readyState == AjaxRequestReadyState.DONE && ajaxRequest.status == 200 && ajaxRequest.url.endsWith("/test-ajax-post")) {
                        Map<String, Object> res = ajaxRequest.response;
                        appBarTitle = (appBarTitle == "InAppWebViewAjaxTest") ? res['fullname'] : appBarTitle + " " + res['fullname'];
                        updateCountTest(context: context);
                      }
                      return AjaxRequestAction.PROCEED;
                    },
                    onAjaxProgress: (InAppWebViewController controller, AjaxRequest ajaxRequest) async {
                      if (ajaxRequest.event.type == AjaxRequestEventType.LOAD && ajaxRequest.url.endsWith("/test-ajax-post")) {
                        Map<String, Object> res = ajaxRequest.response;
                        appBarTitle = (appBarTitle == "InAppWebViewAjaxTest") ? res['fullname'] : appBarTitle + " " + res['fullname'];
                        updateCountTest(context: context);
                      }
                      return AjaxRequestAction.PROCEED;
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }

  void updateCountTest({@required BuildContext context}) {
    testsDone++;
    if (testsDone == totTests) {
      setState(() {  });
      nextTest(context: context, state: this);
    }
  }
}
