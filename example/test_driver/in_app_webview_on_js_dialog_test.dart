import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewOnJsDialogTest extends WidgetTest {
  final InAppWebViewOnJsDialogTestState state = InAppWebViewOnJsDialogTestState();

  @override
  InAppWebViewOnJsDialogTestState createState() => state;
}

class InAppWebViewOnJsDialogTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewOnJsDialogTest";

  TextEditingController _textFieldController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _textFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: this.scaffoldKey,
        appBar: myAppBar(state: this, title: appBarTitle),
        drawer: myDrawer(context: context),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialFile: "test_assets/in_app_webview_on_js_dialog_test.html",
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                            clearCache: true,
                            debuggingEnabled: true
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;

                      controller.addJavaScriptHandler(handlerName: 'confirm', callback: (args) {
                        setState(() {
                          appBarTitle = "confirm " + ((args[0] is bool && args[0]) ? "true" : "false");
                        });
                      });

                      controller.addJavaScriptHandler(handlerName: 'prompt', callback: (args) {
                        setState(() {
                          appBarTitle = "prompt " + args[0];
                        });
                      });
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {
                      setState(() {
                        appBarTitle = "loaded";
                      });
                    },
                    onJsAlert:
                        (InAppWebViewController controller, JsAlertRequest jsAlertRequest) async {
                      JsAlertResponseAction action =
                      await createAlertDialog(context, jsAlertRequest.message);
                      return JsAlertResponse(
                          handledByClient: true, action: action);
                    },
                    onJsConfirm:
                        (InAppWebViewController controller, JsConfirmRequest jsConfirmRequest) async {
                      JsConfirmResponseAction action =
                      await createConfirmDialog(context, jsConfirmRequest.message);
                      return JsConfirmResponse(
                          handledByClient: true, action: action);
                    },
                    onJsPrompt: (InAppWebViewController controller, JsPromptRequest jsPromptRequest) async {
                      _textFieldController.text = jsPromptRequest.defaultValue;
                      JsPromptResponseAction action =
                      await createPromptDialog(context, jsPromptRequest.message);
                      return JsPromptResponse(
                          handledByClient: true,
                          action: action,
                          value: _textFieldController.text);
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }

  Future<JsAlertResponseAction> createAlertDialog(
      BuildContext context, String message) async {
    JsAlertResponseAction action;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              key: Key("AlertButtonOk"),
              onPressed: () {
                action = JsAlertResponseAction.CONFIRM;
                Navigator.of(context).pop();
                setState(() {
                  appBarTitle = "alert";
                });
              },
            ),
          ],
        );
      },
    );

    return action;
  }

  Future<JsConfirmResponseAction> createConfirmDialog(
      BuildContext context, String message) async {
    JsConfirmResponseAction action;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              key: Key("ConfirmButtonCancel"),
              onPressed: () {
                action = JsConfirmResponseAction.CANCEL;
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Ok"),
              key: Key("ConfirmButtonOk"),
              onPressed: () {
                action = JsConfirmResponseAction.CONFIRM;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return action;
  }

  Future<JsPromptResponseAction> createPromptDialog(
      BuildContext context, String message) async {
    JsPromptResponseAction action;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          content: TextField(
            key: Key("PromptTextField"),
            controller: _textFieldController,
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              key: Key("PromptButtonCancel"),
              onPressed: () {
                action = JsPromptResponseAction.CANCEL;
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("Ok"),
              key: Key("PromptButtonOk"),
              onPressed: () {
                action = JsPromptResponseAction.CONFIRM;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    return action;
  }
}
