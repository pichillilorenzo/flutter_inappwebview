import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main_test.dart';
import 'custom_widget_test.dart';
import '.env.dart';

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
        key: this.scaffoldKey,
        appBar: myAppBar(state: this, title: appBarTitle),
        drawer: myDrawer(context: context),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialData: InAppWebViewInitialData(data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewAjaxTest</title>
    </head>
    <body>
        <h1>InAppWebViewAjaxTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var xhttp = new XMLHttpRequest();
            xhttp.open("POST", "http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post");
            xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xhttp.send("firstname=Foo&lastname=Bar");

            var xhttp2 = new XMLHttpRequest();
            xhttp2.open("GET", "http://${environment["NODE_SERVER_IP"]}:8082/test-download-file");
            xhttp2.send();
          });
        </script>
    </body>
</html>
                    """),
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
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
    }
  }
}
