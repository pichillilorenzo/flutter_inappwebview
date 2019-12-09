/*import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'chrome_safari_browser_example.screen.dart';
import 'in_app_webiew_example.screen.dart';
import 'in_app_browser_example.screen.dart';

// InAppLocalhostServer localhostServer = new InAppLocalhostServer();

Future main() async {
  // await localhostServer.start();
  runApp(new MyApp());
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
        }
    );
  }
}*/

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
        home: InAppWebViewPage()
    );
  }
}

class InAppWebViewPage extends StatefulWidget {

  @override
  _InAppWebViewPageState createState() => new _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> with WidgetsBindingObserver {
  InAppWebViewController webView;
  String defaultUserAgent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (webView != null) {
      if (Platform.isAndroid) {
        if (state == AppLifecycleState.paused) {
          webView.pause();
        } else if (state == AppLifecycleState.resumed) {
          webView.resume();
        }
      }

      if (state == AppLifecycleState.paused) {
        webView.pauseTimers();
      } else if (state == AppLifecycleState.resumed) {
        webView.resumeTimers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            title: Text("InAppWebView")
        ),
        body: SafeArea(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    //initialUrl: "https:/flutter.dev",
                    //initialFile: "assets/index.html",
                    initialData: InAppWebViewInitialData(
                      data: """
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Flutter InAppWebView</title>
    <link rel="stylesheet" href="https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="css/style.css">
    <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
    <link rel="shortcut icon" href="favicon.ico">
</head>
<body class="text-center">
    <div class="cover-container d-flex w-100 h-100 p-3 mx-auto flex-column">
        <header class="masthead mb-auto">
            <div class="inner">
                <h3 class="masthead-brand">Flutter InAppWebView</h3>
                <nav class="nav nav-masthead justify-content-center">
                    <a class="nav-link active" href="index.html">Home</a>
                    <a class="nav-link" href="page-1.html">Page 1</a>
                    <a class="nav-link" href="page-2.html">Page 2</a>
                </nav>
            </div>
        </header>
        
        <form action="https://example.org/" method="POST">
          <input type="submit" />
        </form>

        <main role="main" class="inner cover">
            <h1 class="cover-heading">Inline WebView</h1>
            <img src="images/flutter-logo.svg" alt="flutter logo">
            <p class="lead">Cover is a one-page template for building simple and beautiful home pages. Download, edit the text, and add your own fullscreen background photo to make it your own.</p>
        </main>

        <footer class="mastfoot mt-auto">
            <div class="inner">
                <p>Cover template for <a target="_blank" href="https://getbootstrap.com/">Bootstrap</a>, by <a href="https://twitter.com/mdo">@mdo</a>.</p>
                <p>Phone link example <a href="tel:1-408-555-5555">1-408-555-5555</a></p>
                <p>Email link example <a href="mailto:example@gmail.com">example@gmail.com</a></p>
            </div>
        </footer>
    </div>
</body>
</html>
                      """
                    ),
                    initialHeaders: {},
                    initialOptions: InAppWebViewWidgetOptions(
                        inAppWebViewOptions: InAppWebViewOptions(
                          debuggingEnabled: true,
                          useShouldOverrideUrlLoading: true
                        ),
                        androidInAppWebViewOptions: AndroidInAppWebViewOptions(
                          domStorageEnabled: true,
                          regexToCancelSubFramesLoading: ""
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {
                      print("start $url");
                    },
                    onLoadStop: (InAppWebViewController controller, String url) async {
                      print("stop $url");
                    },
                    onPrint: (InAppWebViewController controller, String url) async {
                      print("print $url");
                    },
                    onCreateWindow: (InAppWebViewController controller, String url) async {
                      print("target blank $url");
                    },
                    shouldOverrideUrlLoading: (InAppWebViewController controller, ShouldOverrideUrlLoadingRequest shouldOverrideUrlLoadingRequest) async {
                      print("overidde url ${shouldOverrideUrlLoadingRequest.url}, method: ${shouldOverrideUrlLoadingRequest.method}, headers: ${shouldOverrideUrlLoadingRequest.headers}, isForMainFrame: ${shouldOverrideUrlLoadingRequest.isForMainFrame}");
                      return ShouldOverrideUrlLoadingAction.ALLOW;
                    },
                  ),
                )
                /*Container(
                  child: InAppWebView(
                    initialUrl: "about:blank",
                    //initialUrl: "https://www.youtube.com/embed/fq4N0hgOWzU",
                    initialHeaders: {},
                    initialOptions: InAppWebViewWidgetOptions(
                      inAppWebViewOptions: InAppWebViewOptions(
                        debuggingEnabled: true,
                      )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) async {

                      if (url == "about:blank" && defaultUserAgent == null) {
                        defaultUserAgent = await controller.evaluateJavascript(
                            source: "navigator.userAgent");

                        webView.setOptions(options: InAppWebViewWidgetOptions(
                            inAppWebViewOptions: InAppWebViewOptions(
                              userAgent: defaultUserAgent + " my-custom-value",
                            )
                        ));

                        webView.loadUrl(url: "https://flutter.dev");
                      }

                      print(await controller.evaluateJavascript(
                          source: "navigator.userAgent"));
                    },
                  ),
                )*/
                /*child: FutureBuilder(
                future: InAppWebViewController.getDefaultUserAgent(),
                    builder: (context, projectSnap) {
                      if (!projectSnap.hasData) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        return Container(
                          child: InAppWebView(
                            initialUrl: "https://flutter.dev",
                            //initialUrl: "https://www.youtube.com/embed/fq4N0hgOWzU",
                            initialHeaders: {},
                            initialOptions: InAppWebViewWidgetOptions(
                                inAppWebViewOptions: InAppWebViewOptions(
                                    debuggingEnabled: true,
                                    userAgent: projectSnap.data.toString() + "; my-value"
                                )
                            ),
                            onWebViewCreated: (InAppWebViewController controller) {
                              webView = controller;
                            },
                            onLoadStart: (InAppWebViewController controller, String url) {

                            },
                            onLoadStop: (InAppWebViewController controller, String url) async {
                              print(await controller.evaluateJavascript(source: "navigator.userAgent"));
                            },
                          ),
                        );
                      }
                    }
                ),*/
              ),
              ButtonBar(
                alignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      if (webView != null) {
                        webView.goBack();
                      }
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (webView != null) {
                        webView.goForward();
                      }
                    },
                  ),
                  RaisedButton(
                    child: Icon(Icons.refresh),
                    onPressed: () {
                      if (webView != null) {
                        webView.reload();
                      }
                    },
                  ),
                ],
              ),
            ]))
    );
  }
}