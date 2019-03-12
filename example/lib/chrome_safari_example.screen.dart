import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  MyChromeSafariBrowser(browserFallback) : super(browserFallback);
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onLoaded() {
    print("ChromeSafari browser loaded");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}

class ChromeSafariExampleScreen extends StatefulWidget {
  final ChromeSafariBrowser browser = new MyChromeSafariBrowser(new InAppBrowser());
  @override
  _ChromeSafariExampleScreenState createState() => new _ChromeSafariExampleScreenState();
}

class _ChromeSafariExampleScreenState extends State<ChromeSafariExampleScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new RaisedButton(
          onPressed: () async {
            await widget.browser.open("https://flutter.dev/");
          },
          child: Text("Open Chrome Safari Browser")),
    );
  }
}
