import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  MyChromeSafariBrowser(browserFallback) : super(bFallback: browserFallback);

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

class ChromeSafariBrowserExampleScreen extends StatefulWidget {
  final ChromeSafariBrowser browser =
      new MyChromeSafariBrowser(new InAppBrowser());

  @override
  _ChromeSafariBrowserExampleScreenState createState() =>
      new _ChromeSafariBrowserExampleScreenState();
}

class _ChromeSafariBrowserExampleScreenState
    extends State<ChromeSafariBrowserExampleScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          "ChromeSafariBrowser",
        )),
        drawer: Drawer(
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
            ],
          ),
        ),
        body: Center(
          child: RaisedButton(
              onPressed: () async {
                await widget.browser.open(
                    url: "https://flutter.dev/",
                    options: ChromeSafariBrowserClassOptions(
                        androidChromeCustomTabsOptions:
                            AndroidChromeCustomTabsOptions(
                                addShareButton: false),
                        iosSafariOptions:
                            IosSafariOptions(barCollapsingEnabled: true)));
              },
              child: Text("Open Chrome Safari Browser")),
        ));
  }
}
