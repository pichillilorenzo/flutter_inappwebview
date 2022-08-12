import 'dart:async';

import 'package:flutter/material.dart';

import 'custom_widget_test.dart';
import 'in_app_webview_ajax_test.dart';
import 'in_app_webview_content_blocker_test.dart';
import 'in_app_webview_cookie_manager_test.dart';
import 'in_app_webview_fetch_test.dart';
import 'in_app_webview_http_auth_credential_database_test.dart';
import 'in_app_webview_initial_data_test.dart';
import 'in_app_webview_initial_file_test.dart';
import 'in_app_webview_initial_url_test.dart';
import 'in_app_webview_javascript_handler_test.dart';
import 'in_app_webview_on_console_message_test.dart';
import 'in_app_webview_on_download_start_test.dart';
import 'in_app_webview_on_find_result_received_test.dart';
import 'in_app_webview_on_js_dialog_test.dart';
import 'in_app_webview_on_load_error_test.dart';
import 'in_app_webview_on_load_http_error_test.dart';
import 'in_app_webview_on_load_resource_custom_scheme_test.dart';
import 'in_app_webview_on_load_resource_test.dart';
import 'in_app_webview_on_navigation_state_change_test.dart';
import 'in_app_webview_on_progress_changed_test.dart';
import 'in_app_webview_on_received_http_auth_request_test.dart';
import 'in_app_webview_on_safe_browsing_hit_test.dart';
import 'in_app_webview_on_scroll_changed_test.dart';
import 'in_app_webview_on_create_window_test.dart';
import 'in_app_webview_should_override_url_loading_test.dart';
import 'in_app_webview_ssl_request_test.dart';

Map<String, WidgetBuilder> getTestRoutes({@required BuildContext context}) {
  var routes = {
    '/': (context) => InAppWebViewInitialUrlTest(),
    '/InAppWebViewInitialFileTest': (context) => InAppWebViewInitialFileTest(),
    '/InAppWebViewInitialDataTest': (context) => InAppWebViewInitialDataTest(),
    '/InAppWebViewOnProgressChangedTest': (context) => InAppWebViewOnProgressChangedTest(),
    '/InAppWebViewOnScrollChangedTest': (context) => InAppWebViewOnScrollChangedTest(),
    '/InAppWebViewOnLoadResourceTest': (context) => InAppWebViewOnLoadResourceTest(),
    '/InAppWebViewJavaScriptHandlerTest': (context) => InAppWebViewJavaScriptHandlerTest(),
    '/InAppWebViewAjaxTest': (context) => InAppWebViewAjaxTest(),
    '/InAppWebViewFetchTest': (context) => InAppWebViewFetchTest(),
    '/InAppWebViewOnLoadResourceCustomSchemeTest': (context) => InAppWebViewOnLoadResourceCustomSchemeTest(),
    '/InAppWebViewShouldOverrideUrlLoadingTest': (context) => InAppWebViewShouldOverrideUrlLoadingTest(),
    '/InAppWebViewOnConsoleMessageTest': (context) => InAppWebViewOnConsoleMessageTest(),
    '/InAppWebViewOnDownloadStartTest': (context) => InAppWebViewOnDownloadStartTest(),
    '/InAppWebViewOnCreateWindowTest': (context) => InAppWebViewOnCreateWindowTest(),
    '/InAppWebViewOnJsDialogTest': (context) => InAppWebViewOnJsDialogTest(),
    '/InAppWebViewOnSafeBrowsingHitTest': (context) => InAppWebViewOnSafeBrowsingHitTest(),
    '/InAppWebViewOnReceivedHttpAuthRequestTest': (context) => InAppWebViewOnReceivedHttpAuthRequestTest(),
    '/InAppWebViewSslRequestTest': (context) => InAppWebViewSslRequestTest(),
    '/InAppWebViewOnFindResultReceivedTest': (context) => InAppWebViewOnFindResultReceivedTest(),
    '/InAppWebViewOnNavigationStateChangeTest': (context) => InAppWebViewOnNavigationStateChangeTest(),
    '/InAppWebViewOnLoadErrorTest': (context) => InAppWebViewOnLoadErrorTest(),
    '/InAppWebViewOnLoadHttpErrorTest': (context) => InAppWebViewOnLoadHttpErrorTest(),
    '/InAppWebViewCookieManagerTest': (context) => InAppWebViewCookieManagerTest(),
    '/InAppWebViewHttpAuthCredentialDatabaseTest': (context) => InAppWebViewHttpAuthCredentialDatabaseTest(),
    '/InAppWebViewContentBlockerTest': (context) => InAppWebViewContentBlockerTest(),
  };
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
        icon: Icon(Icons.menu),
        key: Key("SideMenu"),
        onPressed: () {
          state.scaffoldKey.currentState.openDrawer();
        },
      ),
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

Drawer myDrawer({@required context}) {
  var routes = getTestRoutes(context: context);
  List<Widget> listTiles = [
    DrawerHeader(
      child: Text('Tests'),
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
    )
  ];
  for (String k in routes.keys) {
    var title = "";
    if (k == "/") {
      title = "InAppWebViewInitialUrlTest";
    } else {
      title = k.substring(1);
    }
    listTiles.add(ListTile(
      title: Text(title),
      key: Key(title),
      onTap: () {
        Navigator.pushReplacementNamed(context, k);
      },
    ));
  }
  return Drawer(
    child: ListView(
      key: Key("ListTiles"),
      padding: EdgeInsets.zero,
      children: listTiles,
    ),
  );
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      routes: getTestRoutes(context: context)
    );
  }
}