import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:flutter_inappbrowser_example/chrome_safari_example.screen.dart';
import 'package:flutter_inappbrowser_example/inline_example.screen.dart';
import 'package:flutter_inappbrowser_example/webview_example.screen.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

// InAppLocalhostServer localhostServer = new InAppLocalhostServer();

Future main() async {
  // await localhostServer.start();
  // await FlutterDownloader.initialize();
  await PermissionHandler().requestPermissions([PermissionGroup.locationAlways]);
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
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Tabs Demo'),
          ),
          body: TabBarView(
            children: [
              WebviewExampleScreen(),
              ChromeSafariExampleScreen(),
              InlineExampleScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: "Webview"),
                Tab(text: "Chrome/Safari"),
                Tab(
                  text: "Inline",
                ),
              ],
            ),
          ))),
    );
  }
}
