import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class MyInAppBrowser extends InAppBrowser {

  @override
  Future onLoadStart(String url) async {
    print("\n\nStarted aaa $url\n\n");
    inAppBrowserFallback2.open("https://www.google.com", options: {
      "hidden": true
    });
    //print("\n\n ${await this.isHidden()} \n\n");
  }

  @override
  Future onLoadStop(String url) async {
    print("\n\nStopped aaa $url\n\n");
    inAppBrowserFallback2.show();
//    print(await this.injectScriptCode("document.body.innerHTML"));
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
}

class MyInAppBrowser2 extends InAppBrowser {

  @override
  Future onLoadStart(String url) async {
    print("\n\nStarted $url\n\n");
    //print("\n\n ${await this.isHidden()} \n\n");
  }

  @override
  Future onLoadStop(String url) async {
    print("\n\nStopped $url\n\n");
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
}

MyInAppBrowser inAppBrowserFallback = new MyInAppBrowser();
MyInAppBrowser2 inAppBrowserFallback2 = new MyInAppBrowser2();

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
    inAppBrowserFallback.open("https://flutter.io/");
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
            chromeSafariBrowser.open("https://flutter.io/", options: {
                  "addShareButton": false,
                  "toolbarBackgroundColor": "#000000",
                  "dismissButtonStyle": 1,
                  "preferredBarTintColor": "#000000",
                },
              optionsFallback: {
                "hidden": true,
                //"toolbarTopFixedTitle": "Fixed title",
                //"useShouldOverrideUrlLoading": true
                //"hideUrlBar": true,
                //"toolbarTop": false,
                //"toolbarBottom": false
              });
//              inAppBrowserFallback.open("https://flutter.io/", options: {
//                //"hidden": true,
//                //"toolbarTopFixedTitle": "Fixed title",
//                //"useShouldOverrideUrlLoading": true
//                //"hideUrlBar": true,
//                //"toolbarTop": false,
//                //"toolbarBottom": false
//              });

          },
          child: Text("Open InAppBrowser")
          ),
        ),
      ),
    );
  }
}
