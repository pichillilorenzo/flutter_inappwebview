import 'dart:async';

import 'package:flutter/material.dart';

import 'in_app_webview_initial_file_test.dart';
import 'in_app_webview_initial_url_test.dart';
import 'in_app_webview_on_load_resource_test.dart';


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
      routes: {
        '/': (context) => InAppWebViewInitialUrlTest(),
        '/InAppWebViewInitialFileTest': (context) => InAppWebViewInitialFileTest(),
        '/InAppWebViewOnLoadResourceTest': (context) => InAppWebViewOnLoadResourceTest()
      }
    );
  }
}