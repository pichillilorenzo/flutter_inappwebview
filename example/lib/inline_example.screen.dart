import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class InlineExampleScreen extends StatefulWidget {
  @override
  _InlineExampleScreenState createState() => new _InlineExampleScreenState();
}

class _InlineExampleScreenState extends State<InlineExampleScreen> {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[
      Container(
        padding: EdgeInsets.all(20.0),
        child: Text(
            "CURRENT URL\n${(url.length > 50) ? url.substring(0, 50) + "..." : url}"),
      ),
      Container( 
        padding: EdgeInsets.all(10.0),
        child: progress < 1.0 ? LinearProgressIndicator(value: progress) : null
      ),
      Expanded(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          child: InAppWebView(
            initialUrl: "https://flutter.dev/",
            initialHeaders: {},
            initialOptions: {
              "useShouldOverrideUrlLoading": true,
              "useOnLoadResource": true
            },
            onWebViewCreated: (InAppWebViewController controller) {
              webView = controller;
            },
            onLoadStart: (InAppWebViewController controller, String url) {
              print("started $url");
              setState(() {
                this.url = url;
              });
            },
            onLoadStop: (InAppWebViewController controller, String url) {
              print("stopped $url");
            },
            onProgressChanged:
                (InAppWebViewController controller, int progress) {
              setState(() {
                this.progress = progress / 100;
              });
            },
            shouldOverrideUrlLoading: (InAppWebViewController controller, String url) {
              print("override $url");
              controller.loadUrl(url);
            },
            onLoadResource: (InAppWebViewController controller, WebResourceResponse response, WebResourceRequest request) {
              print("resource " + request.url);
            }
          ),
        ),
      ),
      ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: Icon(Icons.arrow_back),
            onPressed: () {
              if (webView != null) {
                webView.goBack();
              }
            },
          ),
          RaisedButton(
            child: Icon(Icons.arrow_forward),
            onPressed: () {
              if (webView != null) {
                webView.goForward();
              }
            },
          ),
          RaisedButton(
            child: Icon(Icons.refresh),
            onPressed: () {
              if (webView != null) {
                webView.reload();
              }
            },
          ),
        ],
      ),
    ]));
  }
}
