import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class InlineExampleScreen extends StatefulWidget {
  @override
  _InlineExampleScreenState createState() => new _InlineExampleScreenState();
}

class Foo {
  String bar;
  String baz;

  Foo({this.bar, this.baz});

  Map<String, dynamic> toJson() {
    return {
      'bar': this.bar,
      'baz': this.baz
    };
  }
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
            //initialUrl: "https://www.youtube.com/embed/M7lc1UVf-VE?playsinline=1",
            //initialUrl: "https://flutter.dev/",
            initialFile: "assets/index.html",
            initialHeaders: {},
            initialOptions: {
              //"mediaPlaybackRequiresUserGesture": false,
              //"allowsInlineMediaPlayback": true,
              //"useShouldOverrideUrlLoading": true,
              //"useOnLoadResource": true
            },
            onWebViewCreated: (InAppWebViewController controller) {
              webView = controller;

              webView.addJavaScriptHandler('handlerFoo', (args) {
                return new Foo(bar: 'bar_value', baz: 'baz_value');
              });

              webView.addJavaScriptHandler('handlerFooWithArgs', (args) {
                print(args);
                return [args[0] + 5, !args[1], args[2][0], args[3]['foo']];
              });
            },
            onLoadStart: (InAppWebViewController controller, String url) {
              print("started $url");
              setState(() {
                this.url = url;
              });
            },
            onLoadStop: (InAppWebViewController controller, String url) async {
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
              print("Started at: " +
                  response.startTime.toString() +
                  "ms ---> duration: " +
                  response.duration.toString() +
                  "ms " +
                  response.url);
            },
            onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
              print("""
              console output:
                sourceURL: ${consoleMessage.sourceURL}
                lineNumber: ${consoleMessage.lineNumber}
                message: ${consoleMessage.message}
                messageLevel: ${consoleMessage.messageLevel}
              """);
            },
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
