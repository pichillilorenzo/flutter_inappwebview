import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main.dart';

class HeadlessInAppWebViewExampleScreen extends StatefulWidget {
  @override
  _HeadlessInAppWebViewExampleScreenState createState() =>
      new _HeadlessInAppWebViewExampleScreenState();
}

class _HeadlessInAppWebViewExampleScreenState
    extends State<HeadlessInAppWebViewExampleScreen> {
  HeadlessInAppWebView? headlessWebView;
  String url = "";

  @override
  void initState() {
    super.initState();

    headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse("https://flutter.dev")),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(),
      ),
      onWebViewCreated: (controller) {
        print('HeadlessInAppWebView created!');
      },
      onConsoleMessage: (controller, consoleMessage) {
        print("CONSOLE MESSAGE: " + consoleMessage.message);
      },
      onLoadStart: (controller, url) async {
        print("onLoadStart $url");
        setState(() {
          this.url = url.toString();
        });
      },
      onLoadStop: (controller, url) async {
        print("onLoadStop $url");
        setState(() {
          this.url = url.toString();
        });
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
        print("onUpdateVisitedHistory $url");
        setState(() {
          this.url = url.toString();
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    headlessWebView?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          "HeadlessInAppWebView",
        )),
        drawer: myDrawer(context: context),
        body: SafeArea(
            child: Column(children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            child: Text(
                "CURRENT URL\n${(url.length > 50) ? url.substring(0, 50) + "..." : url}"),
          ),
          Center(
            child: ElevatedButton(
                onPressed: () async {
                  await headlessWebView?.dispose();
                  await headlessWebView?.run();
                },
                child: Text("Run HeadlessInAppWebView")),
          ),
          Center(
            child: ElevatedButton(
                onPressed: () async {
                  try {
                    await headlessWebView?.webViewController.evaluateJavascript(
                        source: """console.log('Here is the message!');""");
                  } on MissingPluginException {
                    print(
                        "HeadlessInAppWebView is not running. Click on \"Run HeadlessInAppWebView\"!");
                  }
                },
                child: Text("Send console.log message")),
          ),
          Center(
            child: ElevatedButton(
                onPressed: () {
                  headlessWebView?.dispose();
                },
                child: Text("Dispose HeadlessInAppWebView")),
          )
        ])));
  }
}
