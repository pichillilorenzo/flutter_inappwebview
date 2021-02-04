import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

class InAppWebViewExampleScreen extends StatefulWidget {
  @override
  _InAppWebViewExampleScreenState createState() =>
      new _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {
  InAppWebViewController? webView;
  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  CookieManager _cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
      menuItems: [
        ContextMenuItem(androidId: 1, iosId: "1", title: "Special", action: () async {
          print("Menu item Special clicked!");
          print(await webView?.getSelectedText());
          await webView?.clearFocus();
        })
      ],
      options: ContextMenuOptions(
        hideDefaultSystemContextMenuItems: false
      ),
      onCreateContextMenu: (hitTestResult) async {
        print("onCreateContextMenu");
        print(hitTestResult.extra);
        print(await webView?.getSelectedText());
      },
      onHideContextMenu: () {
        print("onHideContextMenu");
      },
      onContextMenuActionItemClicked: (contextMenuItemClicked) async {
        var id = (Platform.isAndroid) ? contextMenuItemClicked.androidId : contextMenuItemClicked.iosId;
        print("onContextMenuActionItemClicked: " + id.toString() + " " + contextMenuItemClicked.title);
      }
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("InAppWebView")
        ),
        drawer: myDrawer(context: context),
        body: SafeArea(
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
                    // contextMenu: contextMenu,
                    initialUrl: "https://flutter.dev/",
                    // initialFile: "assets/index.html",
                    initialHeaders: {},
                    initialUserScripts: UnmodifiableListView<UserScript>([

                    ]),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        useShouldOverrideUrlLoading: false,
                        mediaPlaybackRequiresUserGesture: false,
                      ),
                      android: AndroidInAppWebViewOptions(
                        useHybridComposition: true,
                      ),
                      ios: IOSInAppWebViewOptions(
                        allowsInlineMediaPlayback: true,
                      )
                    ),
                    onWebViewCreated: (controller) {
                      webView = controller;
                      print("onWebViewCreated");
                    },
                    onLoadStart: (controller, url) {
                      print("onLoadStart $url");
                      setState(() {
                        this.url = url ?? '';
                      });
                    },
                    shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
                      var url = shouldOverrideUrlLoadingRequest.url;
                      var uri = Uri.parse(url);

                      if (!["http", "https", "file",
                        "chrome", "data", "javascript",
                        "about"].contains(uri.scheme)) {
                        if (await canLaunch(url)) {
                          // Launch the App
                          await launch(
                            url,
                          );
                          // and cancel the request
                          return ShouldOverrideUrlLoadingAction.CANCEL;
                        }
                      }

                      return ShouldOverrideUrlLoadingAction.ALLOW;
                    },
                    onLoadStop: (controller, url) async {
                      print("onLoadStop $url");
                      setState(() {
                        this.url = url ?? '';
                      });
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        this.progress = progress / 100;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      print("onUpdateVisitedHistory $url");
                      setState(() {
                        this.url = url ?? '';
                      });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      print(consoleMessage);
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
                      webView?.goBack();
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.arrow_forward),
                    onPressed: () {
                      webView?.goForward();
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.refresh),
                    onPressed: () {
                      webView?.reload();
                    },
                  ),
                ],
              ),
            ]))
    );
  }
}