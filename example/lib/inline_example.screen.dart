import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;

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

  TextEditingController _textFieldController = TextEditingController();

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
        child: progress < 1.0 ? LinearProgressIndicator(value: progress) : Container()
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
            initialOptions: [
              InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
                useOnTargetBlank: true,
                //useOnLoadResource: true,
                useOnDownloadStart: true,
                resourceCustomSchemes: ["my-special-custom-scheme"],
                contentBlockers: [
                  ContentBlocker(
                      ContentBlockerTrigger(".*",
                          resourceType: [ContentBlockerTriggerResourceType.IMAGE, ContentBlockerTriggerResourceType.STYLE_SHEET],
                          ifTopUrl: ["https://getbootstrap.com/"]),
                      ContentBlockerAction(ContentBlockerActionType.BLOCK)
                  )
                ]
              ),
              AndroidInAppWebViewOptions(
                databaseEnabled: true,
                appCacheEnabled: true,
                domStorageEnabled: true,
                geolocationEnabled: true,
                //blockNetworkImage: true,
              ),
              iOSInAppWebViewOptions(
                  preferredContentMode: iOSInAppWebViewUserPreferredContentMode.DESKTOP
              )
            ],
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
            onLoadError: (InAppWebViewController controller, String url, int code, String message) async {
              print("error $url: $code, $message");
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
            onLoadResource: (InAppWebViewController controller, WebResourceResponse response) {
              print("Resource type: '"+response.initiatorType + "' started at: " +
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
            onDownloadStart: (InAppWebViewController controller, String url) async {
              /*final taskId = await FlutterDownloader.enqueue(
                url: url,
                savedDir: await _findLocalPath(),
                showNotification: true, // show download progress in status bar (for Android)
                openFileFromNotification: true, // click on notification to open downloaded file (for Android)
              );*/
            },
            onLoadResourceCustomScheme: (InAppWebViewController controller, String scheme, String url) async {
              if (scheme == "my-special-custom-scheme") {
                var bytes = await rootBundle.load("assets/" + url.replaceFirst("my-special-custom-scheme://", "", 0));
                var asBase64 = base64.encode(bytes.buffer.asUint8List());
                var response = new CustomSchemeResponse(asBase64, "image/svg+xml", contentEnconding: "utf-8");
                return response;
              }
              return null;
            },
            onTargetBlank: (InAppWebViewController controller, String url) {
              print("target _blank: " + url);
              controller.loadUrl(url);
            },
            onGeolocationPermissionsShowPrompt: (InAppWebViewController controller, String origin) async {
              GeolocationPermissionShowPromptResponse response;

              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Permission Geolocation API"),
                    content: Text("Can we use Geolocation API?"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Close"),
                        onPressed: () {
                          response = new GeolocationPermissionShowPromptResponse(origin, false, false);
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text("Accept"),
                        onPressed: () {
                          response = new GeolocationPermissionShowPromptResponse(origin, true, true);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );

              return response;
            },
            onJsAlert: (InAppWebViewController controller, String message) async {
              JsAlertResponseAction action;

              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Text(message),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Ok"),
                        onPressed: () {
                          action = JsAlertResponseAction.CONFIRM;
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );

              return new JsAlertResponse(handledByClient: true, action: action);
            },
            onJsConfirm: (InAppWebViewController controller, String message) async {
              JsConfirmResponseAction action;

              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Text(message),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          action = JsConfirmResponseAction.CANCEL;
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text("Ok"),
                        onPressed: () {
                          action = JsConfirmResponseAction.CONFIRM;
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );

              return new JsConfirmResponse(handledByClient: true, action: action);
            },
            onJsPrompt: (InAppWebViewController controller, String message, String defaultValue) async {
              JsPromptResponseAction action;
              _textFieldController.text = defaultValue;

              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(message),
                    content: TextField(
                      controller: _textFieldController,
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          action = JsPromptResponseAction.CANCEL;
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text("Ok"),
                        onPressed: () {
                          action = JsPromptResponseAction.CONFIRM;
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );

              return new JsPromptResponse(handledByClient: true, action: action, value: _textFieldController.text);
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

  Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
