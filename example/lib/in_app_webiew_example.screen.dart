import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

class InAppWebViewExampleScreen extends StatefulWidget {
  @override
  _InAppWebViewExampleScreenState createState() =>
      new _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {
  InAppWebViewController webView;
  String url = "";
  double progress = 0;
  CookieManager cookieManager = CookieManager.instance();

  TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _textFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          "InAppWebView",
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
        body: Container(
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: Text(
                    "CURRENT URL\n${(url.length > 50) ? url.substring(0, 50) + "..." : url}"),
              ),
              Container(
                  padding: EdgeInsets.all(10.0),
                  child: progress < 1.0
                      ? LinearProgressIndicator(value: progress)
                      : Container()),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                  child: InAppWebView(
                    initialUrl: "https://flutter.dev/",
                    initialHeaders: {},
                    initialOptions: InAppWebViewWidgetOptions(
                      inAppWebViewOptions: InAppWebViewOptions(
                          debuggingEnabled: true,
                          clearCache: true
                      )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {
                      setState(() {
                        this.url = url;
                      });
                    },
                    onLoadStop: (InAppWebViewController controller, String url) async {
                      setState(() {
                        this.url = url;
                      });
                    },
                    onProgressChanged: (InAppWebViewController controller, int progress) {
                      setState(() {
                        this.progress = progress / 100;
                      });
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
        ])));
  }
}
