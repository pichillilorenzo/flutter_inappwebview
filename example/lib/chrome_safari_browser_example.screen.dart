import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main.dart';

class MyChromeSafariBrowser extends ChromeSafariBrowser {
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
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();

  @override
  _ChromeSafariBrowserExampleScreenState createState() =>
      _ChromeSafariBrowserExampleScreenState();
}

class _ChromeSafariBrowserExampleScreenState
    extends State<ChromeSafariBrowserExampleScreen> {
  @override
  void initState() {
    rootBundle.load('assets/images/flutter-logo.png').then((actionButtonIcon) {
      widget.browser.setActionButton(ChromeSafariBrowserActionButton(
          id: 1,
          description: 'Action Button description',
          icon: actionButtonIcon.buffer.asUint8List(),
          action: (url, title) {
            print('Action Button 1 clicked!');
            print(url);
            print(title);
          }));
    });

    widget.browser.addMenuItem(ChromeSafariBrowserMenuItem(
        id: 2,
        label: 'Custom item menu 1',
        action: (url, title) {
          print('Custom item menu 1 clicked!');
          print(url);
          print(title);
        }));
    widget.browser.addMenuItem(ChromeSafariBrowserMenuItem(
        id: 3,
        label: 'Custom item menu 2',
        action: (url, title) {
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
          child: ElevatedButton(
              onPressed: () async {
                await widget.browser.open(
                    url: Uri.parse("https://flutter.dev/"),
                    options: ChromeSafariBrowserClassOptions(
                        android: AndroidChromeCustomTabsOptions(
                            shareState: CustomTabsShareState.SHARE_STATE_OFF,
                            isSingleInstance: false,
                            isTrustedWebActivity: false,
                            keepAliveEnabled: true),
                        ios: IOSSafariOptions(
                            dismissButtonStyle:
                                IOSSafariDismissButtonStyle.CLOSE,
                            presentationStyle:
                                IOSUIModalPresentationStyle.OVER_FULL_SCREEN)));
              },
              child: Text("Open Chrome Safari Browser")),
        ));
  }
}
