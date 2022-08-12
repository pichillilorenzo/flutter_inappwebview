import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_inappwebview_example/chrome_safari_browser_example.screen.dart';
import 'package:flutter_inappwebview_example/headless_in_app_webview.screen.dart';
import 'package:flutter_inappwebview_example/in_app_webiew_example.screen.dart';
import 'package:flutter_inappwebview_example/in_app_browser_example.screen.dart';
// import 'package:permission_handler/permission_handler.dart';

// InAppLocalhostServer localhostServer = new InAppLocalhostServer();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  await Permission.camera.request();
//  await Permission.storage.request();
  // await localhostServer.start();
  runApp(MyApp());
}

Drawer myDrawer({@required BuildContext context}) {
  return Drawer(
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
        ListTile(
          title: Text('HeadlessInAppWebView'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/HeadlessInAppWebView');
          },
        ),
      ],
    ),
  );
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
        initialRoute: '/',
        routes: {
          '/': (context) => InAppWebViewExampleScreen(),
          '/InAppBrowser': (context) => InAppBrowserExampleScreen(),
          '/ChromeSafariBrowser': (context) => ChromeSafariBrowserExampleScreen(),
          '/HeadlessInAppWebView': (context) => HeadlessInAppWebViewExampleScreen(),
        }
    );
  }
}