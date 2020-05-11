import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';

class InAppWebViewContentBlockerTest extends WidgetTest {
  final InAppWebViewContentBlockerTestState state = InAppWebViewContentBlockerTestState();

  @override
  InAppWebViewContentBlockerTestState createState() => state;
}

class InAppWebViewContentBlockerTestState extends WidgetTestState {

  String appBarTitle = "InAppWebViewContentBlockerTest";

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
                    initialUrl: "https://flutter.dev/",
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                            clearCache: true,
                            debuggingEnabled: true,
                            contentBlockers: [
                              ContentBlocker(
                                  trigger: ContentBlockerTrigger(
                                      urlFilter: ".*",
                                      resourceType: [
                                        ContentBlockerTriggerResourceType.IMAGE,
                                        ContentBlockerTriggerResourceType.STYLE_SHEET
                                      ],
                                      ifTopUrl: [
                                        "https://flutter.dev/"
                                      ]),
                                  action: ContentBlockerAction(
                                      type: ContentBlockerActionType.BLOCK))
                            ]
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) {
                      setState(() {
                        appBarTitle = "true";
                      });
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
