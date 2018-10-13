import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class MyInAppBrowser extends InAppBrowser {

  @override
  Future onLoadStart(String url) async {
    print("\n\nStarted $url\n\n");
    //print("\n\n ${await this.isHidden()} \n\n");
  }

  @override
  Future onLoadStop(String url) async {
    print("\n\nStopped $url\n\n");

//    // javascript error
//    await this.injectScriptCode("console.log({'testJavaScriptError': 5}));");
//
//    await this.injectScriptCode("console.log({'testObject': 5});");
//    await this.injectScriptCode("console.warn('testWarn',null);");
//    await this.injectScriptCode("console.log('testObjectStringify', JSON.stringify({'asd': 5}));");
//    await this.injectScriptCode("console.info('testInfo', 6);");
//    await this.injectScriptCode("console.error('testError', false);");
//    await this.injectScriptCode("console.debug('testDebug', true);");
//    print(await this.injectScriptCode("document.body.innerHTML"));
//    print(await this.injectScriptCode("null"));
//    print(await this.injectScriptCode("undefined"));
//    print(await this.injectScriptCode("3"));
//    print(await this.injectScriptCode("""
//      function asd (a,b) {
//        return a+b;
//       };
//       asd(3,5);
//    """));
//    print(await this.injectScriptCode("""
//      ["3",56,"sdf"];
//    """));
//    print(await this.injectScriptCode("""
//      var x = {"as":4, "dfdfg": 6};
//      x;
//    """));
    //print("\n\n ${await this.isHidden()} \n\n");

//    await this.injectScriptFile("https://code.jquery.com/jquery-3.3.1.min.js");
//    this.injectScriptCode("""
//      \$( "body" ).html( "Next Step..." )
//    """);
//
//    // add custom css
//    this.injectStyleCode("""
//    body {
//      background-color: #3c3c3c !important;
//    }
//    """);
//    this.injectStyleFile("https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css");
  }

  @override
  void onLoadError(String url, int code, String message) {
    print("\n\nCan't load $url.. Error: $message\n\n");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

  @override
  void shouldOverrideUrlLoading(String url) {
    print("\n\n override $url\n\n");
    this.loadUrl(url);
  }

  @override
  void onLoadResource(WebResourceResponse response, WebResourceRequest request) {
    print(response.loadingTime.toString() + "ms " + response.url);
    if (response.headers["content-length"] != null)
      print(response.headers["content-length"] + " length");
  }

  @override
  void onConsoleMessage(ConsoleMessage consoleMessage) {
    print("""
    console output: 
      sourceURL: ${consoleMessage.sourceURL}
      lineNumber: ${consoleMessage.lineNumber}
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel}
    """);
  }
}

MyInAppBrowser inAppBrowserFallback = new MyInAppBrowser();

class MyChromeSafariBrowser extends ChromeSafariBrowser {

  MyChromeSafariBrowser(browserFallback) : super(browserFallback);

  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onLoaded() {
    print("ChromeSafari browser loaded");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}

MyChromeSafariBrowser chromeSafariBrowser = new MyChromeSafariBrowser(inAppBrowserFallback);

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Flutter InAppBrowser Plugin example app'),
        ),
        body: new Center(
          child: new RaisedButton(onPressed: () {
            //chromeSafariBrowser.open("https://flutter.io/");
            inAppBrowserFallback.open(url: "https://flutter.io/", options: {
              //"hidden": true,
              //"toolbarTopFixedTitle": "Fixed title",
              //"useShouldOverrideUrlLoading": true
              //"hideUrlBar": true,
              //"toolbarTop": false,
              //"toolbarBottom": false
            });

          },
          child: Text("Open InAppBrowser")
          ),
        ),
      ),
    );
  }
}
