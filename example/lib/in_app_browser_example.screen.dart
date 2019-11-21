import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class MyInAppBrowser extends InAppBrowser {
  @override
  Future onBrowserCreated() async {
    print("\n\nBrowser Ready!\n\n");
  }

  @override
  Future onLoadStart(String url) async {
    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(String url) async {
    print("\n\nStopped $url\n\n");
  }

  @override
  Future onScrollChanged(int x, int y) async {
    print("Scrolled: x:$x y:$y");
  }

  @override
  void onLoadError(String url, int code, String message) {
    print("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(int progress) {
    print("Progress: $progress");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

  @override
  void shouldOverrideUrlLoading(String url) {
    print("\n\n override $url\n\n");
    this.webViewController.loadUrl(url: url);
  }

  @override
  void onLoadResource(LoadedResource response) {
    print("Started at: " +
        response.startTime.toString() +
        "ms ---> duration: " +
        response.duration.toString() +
        "ms " +
        response.url);
  }

  @override
  void onConsoleMessage(ConsoleMessage consoleMessage) {
    print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
  }

  @override
  void onDownloadStart(String url) {
    print("Download of " + url);
  }

  @override
  Future<CustomSchemeResponse> onLoadResourceCustomScheme(
      String scheme, String url) async {
    print("custom scheme: " + scheme);
    return null;
  }

  @override
  Future<GeolocationPermissionShowPromptResponse>
      onGeolocationPermissionsShowPrompt(String origin) async {
    print("request Geolocation permission API");
    return null;
  }

  @override
  Future<JsAlertResponse> onJsAlert(String message) async {
    return new JsAlertResponse(handledByClient: false, message: "coma iam");
  }

  @override
  Future<JsConfirmResponse> onJsConfirm(String message) {
    return null;
  }

  @override
  Future<JsPromptResponse> onJsPrompt(String message, String defaultValue) {
    return null;
  }
}

class InAppBrowserExampleScreen extends StatefulWidget {
  final MyInAppBrowser browser = new MyInAppBrowser();

  @override
  _InAppBrowserExampleScreenState createState() =>
      new _InAppBrowserExampleScreenState();
}

class _InAppBrowserExampleScreenState extends State<InAppBrowserExampleScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          "InAppBrowser",
        )),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('flutter_inappbrowser example'),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                title: Text('InAppBrowser'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/InAppBrowser');
                },
              ),
              ListTile(
                title: Text('ChromeSafariBrowser'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/ChromeSafariBrowser');
                },
              ),
              ListTile(
                title: Text('InAppWebView'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        ),
        body: Center(
          child: RaisedButton(
              onPressed: () {
                widget.browser.openFile(
                    assetFilePath: "assets/index.html",
                    //url: "https://www.google.com/",
                    options: InAppBrowserClassOptions(
                        inAppWebViewWidgetOptions: InAppWebViewWidgetOptions(
                            inAppWebViewOptions: InAppWebViewOptions(
                      useShouldOverrideUrlLoading: true,
                      useOnLoadResource: true,
                    ))));
              },
              child: Text("Open Webview Browser")),
        ));
  }
}
