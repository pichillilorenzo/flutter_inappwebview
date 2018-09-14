import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class MyInAppBrowser extends InAppBrowser {

  @override
  void onLoadStart(String url) {
    super.onLoadStart(url);
    print("\n\nStarted $url\n\n");
  }

  @override
  void onLoadStop(String url) {
    super.onLoadStop(url);
    print("\n\nStopped $url\n\n");
    this.injectScriptFile("https://code.jquery.com/jquery-3.3.1.min.js");
    /*this.injectScriptCode("""
      \$( "body" ).html( "Next Step..." )
    """);*/
    this.injectStyleCode("""
    body {
      background-color: #3c3c3c !important;
    }
    """);
    this.injectStyleFile("https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css");
  }

  @override
  void onLoadError(String url, String code, String message) {
    super.onLoadStop(url);
    print("\n\nCan't load $url.. Error: $message\n\n");
  }

  @override
  void onExit() {
    super.onExit();
    print("\n\nBrowser closed!\n\n");
  }

}

MyInAppBrowser inAppBrowser = new MyInAppBrowser();

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
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new RaisedButton(onPressed: () {
            inAppBrowser.open("https://flutter.io/");
          },
          child: Text("Open InAppBrowser")
          ),
        ),
      ),
    );
  }
}
