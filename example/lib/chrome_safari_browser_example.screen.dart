import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main.dart';

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  MyChromeSafariBrowser({browserFallback}) : super(bFallback: browserFallback);

  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}

class ChromeSafariBrowserExampleScreen extends StatefulWidget {
  final ChromeSafariBrowser browser =
      MyChromeSafariBrowser(browserFallback: InAppBrowser());

  @override
  _ChromeSafariBrowserExampleScreenState createState() =>
      _ChromeSafariBrowserExampleScreenState();
}

class _ChromeSafariBrowserExampleScreenState
    extends State<ChromeSafariBrowserExampleScreen> {
  @override
  void initState() {
    widget.browser.addMenuItem(ChromeSafariBrowserMenuItem(id: 1, label: 'Custom item menu 1', action: (url, title) {
      print('Custom item menu 1 clicked!');
      print(url);
      print(title);
    }));
    widget.browser.addMenuItem(ChromeSafariBrowserMenuItem(id: 2, label: 'Custom item menu 2', action: (url, title) {
      print('Custom item menu 2 clicked!');
      print(url);
      print(title);
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          "ChromeSafariBrowser",
        )),
        drawer: myDrawer(context: context),
        body: Center(
          child: RaisedButton(
              onPressed: () async {
                await widget.browser.open(
                    url: "https://flutter.dev/",
                    options: ChromeSafariBrowserClassOptions(
                        android: AndroidChromeCustomTabsOptions(addDefaultShareMenuItem: false, keepAliveEnabled: true),
                        ios: IOSSafariOptions(
                            dismissButtonStyle: IOSSafariDismissButtonStyle.CLOSE,
                            presentationStyle: IOSUIModalPresentationStyle.OVER_FULL_SCREEN
                        )));
              },
              child: Text("Open Chrome Safari Browser")),
        ));
  }
}
