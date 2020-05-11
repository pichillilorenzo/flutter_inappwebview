import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main_test.dart';
import 'custom_widget_test.dart';
import '.env.dart';

class InAppWebViewOnDownloadStartTest extends WidgetTest {
  final InAppWebViewOnDownloadStartTestState state = InAppWebViewOnDownloadStartTestState();

  @override
  InAppWebViewOnDownloadStartTestState createState() => state;
}

class InAppWebViewOnDownloadStartTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewOnDownloadStartTest";

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
        <title>InAppWebViewOnDownloadStartTest</title>
    </head>
    <body>
        <h1>InAppWebViewOnDownloadStartTest</h1>
        <a id="download-file" href="http://${environment["NODE_SERVER_IP"]}:8082/test-download-file">download file</a>
        <script>
            window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
                document.querySelector("#download-file").click();
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
                            useOnDownloadStart: true
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {

                    },
                    onDownloadStart: (InAppWebViewController controller, String url) {
                      setState(() {
                        appBarTitle = url;
                      });
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
