import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main_test.dart';
import 'custom_widget_test.dart';
import '.env.dart';

class InAppWebViewFetchTest extends WidgetTest {
  final InAppWebViewFetchTestState state = InAppWebViewFetchTestState();

  @override
  InAppWebViewFetchTestState createState() => state;
}

class InAppWebViewFetchTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewFetchTest";
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
        <title>InAppWebViewFetchTest</title>
    </head>
    <body>
        <h1>InAppWebViewFetchTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            fetch(new Request("http://${environment["NODE_SERVER_IP"]}:8082/test-download-file")).then(function(response) {
                window.flutter_inappwebview.callHandler('fetchGet', response.status);
            }).catch(function(error) {
                window.flutter_inappwebview.callHandler('fetchGet', "ERROR: " + error);
            });

            fetch("http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post", {
                method: 'POST',
                body: JSON.stringify({
                    firstname: 'Foo',
                    lastname: 'Bar'
                }),
                headers: {
                  'Content-Type': 'application/json'
                }
            }).then(function(response) {
                response.json().then(function(value) {
					window.flutter_inappwebview.callHandler('fetchPost', value);
				}).catch(function(error) {
				    window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
				});
            }).catch(function(error) {
                window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
            });
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
                            useShouldInterceptFetchRequest: true,
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;

                      webView.addJavaScriptHandler(handlerName: "fetchGet", callback: (args) {
                        appBarTitle = (appBarTitle == "InAppWebViewFetchTest") ? args[0].toString() : appBarTitle + " " + args[0].toString();
                        updateCountTest(context: context);
                      });

                      webView.addJavaScriptHandler(handlerName: "fetchPost", callback: (args) {
                        appBarTitle = (appBarTitle == "InAppWebViewFetchTest") ? args[0]["fullname"] : appBarTitle + " " + args[0]["fullname"];
                        updateCountTest(context: context);
                      });
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {

                    },
                    shouldInterceptFetchRequest: (InAppWebViewController controller, FetchRequest fetchRequest) async {
                      if (fetchRequest.url.endsWith("/test-ajax-post")) {
                        fetchRequest.body = utf8.encode("""{
                          "firstname": "Lorenzo",
                          "lastname": "Pichilli"
                        }
                        """);
                      }
                      return fetchRequest;
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
