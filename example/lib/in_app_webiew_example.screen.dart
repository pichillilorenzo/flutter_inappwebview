import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main.dart';

class InAppWebViewExampleScreen extends StatefulWidget {
  @override
  _InAppWebViewExampleScreenState createState() =>
      new _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {
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
                    initialUrl: "s",
                    // initialFile: "assets/index.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          debuggingEnabled: true,
                        ),
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                      print("onWebViewCreated");
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {
                      print("onLoadStart $url");
                      setState(() {
                        this.url = url;
                      });
                    },
                    onLoadStop: (InAppWebViewController controller, String url) async {
                      print("onLoadStop $url");
                      setState(() {
                        this.url = url;
                      });
                      /*var origins = await WebStorageManager.instance().android.getOrigins();
                      for (var origin in origins) {
                        print(origin);
                        print(await WebStorageManager.instance().android.getQuotaForOrigin(origin: origin.origin));
                        print(await WebStorageManager.instance().android.getUsageForOrigin(origin: origin.origin));
                      }
                      await WebStorageManager.instance().android.deleteAllData();
                      print("\n\nDELETED\n\n");
                      origins = await WebStorageManager.instance().android.getOrigins();
                      for (var origin in origins) {
                        print(origin);
                        await WebStorageManager.instance().android.deleteOrigin(origin: origin.origin);
                      }*/
                      /*var records = await WebStorageManager.instance().ios.fetchDataRecords(dataTypes: IOSWKWebsiteDataType.ALL);
                      for(var record in records) {
                        print(record);
                      }
                      await WebStorageManager.instance().ios.removeDataModifiedSince(dataTypes: IOSWKWebsiteDataType.ALL, date: DateTime(0));
                      print("\n\nDELETED\n\n");
                      records = await WebStorageManager.instance().ios.fetchDataRecords(dataTypes: IOSWKWebsiteDataType.ALL);
                      for(var record in records) {
                        print(record);
                      }*/
                    },
                    onProgressChanged: (InAppWebViewController controller, int progress) {
                      setState(() {
                        this.progress = progress / 100;
                      });
                    },
                    onUpdateVisitedHistory: (InAppWebViewController controller, String url, bool androidIsReload) {
                      print("onUpdateVisitedHistory $url");
                      setState(() {
                        this.url = url;
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
            ]))
    );
  }
}