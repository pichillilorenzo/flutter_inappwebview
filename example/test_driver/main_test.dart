import 'dart:async';

import 'package:flutter/material.dart';

import 'custom_widget_test.dart';
import 'in_app_webview_ajax_test.dart';
import 'in_app_webview_fetch_test.dart';
import 'in_app_webview_initial_file_test.dart';
import 'in_app_webview_initial_url_test.dart';
import 'in_app_webview_javascript_handler_test.dart';
import 'in_app_webview_on_console_message_test.dart';
import 'in_app_webview_on_download_start_test.dart';
import 'in_app_webview_on_load_resource_custom_scheme_test.dart';
import 'in_app_webview_on_load_resource_test.dart';
import 'in_app_webview_on_target_blank_test.dart';
import 'in_app_webview_should_override_url_loading_test.dart';

List<String> testRoutes = [];
Map<String, WidgetBuilder> buildRoutes({@required BuildContext context}) {
  var routes = {
    '/': (context) => InAppWebViewInitialUrlTest(),
    '/InAppWebViewInitialFileTest': (context) => InAppWebViewInitialFileTest(),
    '/InAppWebViewOnLoadResourceTest': (context) => InAppWebViewOnLoadResourceTest(),
    '/InAppWebViewJavaScriptHandlerTest': (context) => InAppWebViewJavaScriptHandlerTest(),
    '/InAppWebViewAjaxTest': (context) => InAppWebViewAjaxTest(),
    '/InAppWebViewOnLoadResourceCustomSchemeTest': (context) => InAppWebViewOnLoadResourceCustomSchemeTest(),
    '/InAppWebViewFetchTest': (context) => InAppWebViewFetchTest(),
    '/InAppWebViewFetchTest': (context) => InAppWebViewFetchTest(),
    '/InAppWebViewShouldOverrideUrlLoadingTest': (context) => InAppWebViewShouldOverrideUrlLoadingTest(),
    '/InAppWebViewOnConsoleMessageTest': (context) => InAppWebViewOnConsoleMessageTest(),
    '/InAppWebViewOnDownloadStartTest': (context) => InAppWebViewOnDownloadStartTest(),
    '/InAppWebViewOnTargetBlankTest': (context) => InAppWebViewOnTargetBlankTest(),
  };
  routes.forEach((k, v) => testRoutes.add(k));
  return routes;
}

AppBar myAppBar({@required WidgetTestState state, @required String title}) {
  return AppBar(
    title: Text(
      title,
      key: Key("AppBarTitle")
    ),
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.refresh),
        onPressed: () {
          if (state.webView != null)
            state.webView.reload();
        },
      ),
    ],
  );
}

Future main() async {
  runApp(new MyApp());
}

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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_inappbrowser tests',
      initialRoute: '/',
      routes: buildRoutes(context: context)
    );
  }
}