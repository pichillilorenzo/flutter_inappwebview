//import 'dart:async';
//import 'dart:convert';
//import 'package:flutter/material.dart';
//import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
//
//class MyInAppBrowser extends InAppBrowser {
//  @override
//  Future onBrowserCreated() async {
//    print("\n\nBrowser Ready!\n\n");
//  }
//
//  @override
//  Future onLoadStart(String url) async {
//    print("\n\nStarted $url\n\n");
////    print("\n\n ${await this.isHidden()} \n\n");
////    print(await this.webViewController.canGoBack());
////    print(await this.webViewController.canGoForward());
//  }
//
//  @override
//  Future onLoadStop(String url) async {
//    print("\n\nStopped $url\n\n");
//
////    print(base64.encode(await this.webViewController.getFavicon()));
////    WebHistory history = await this.webViewController.getCopyBackForwardList();
////    print(history.list.length);
////    print(history.currentIndex);
////    print(history.list[history.currentIndex].url);
////    for(WebHistoryItem item in history.list) {
////      print(item.title);
////    }
//
////
////    print(await this.webViewController.canGoBackOrForward(1));
////    if (await this.webViewController.canGoBackOrForward(-2)) {
////      this.webViewController.goTo(history.list[0]);
////    }
//
////    await this.webViewController.goBackOrForward(-1);
//
////    print(await this.webViewController.canGoBack());
////    print(await this.webViewController.canGoForward());
//
////    var screenshot = await this.webViewController.takeScreenshot();
////    await this.webViewController.injectScriptCode("""
////    document.body.innerHTML = '<img style="max-width: 100%; width: 100%" src="data:image/png;base64,${base64.encode(screenshot)}" />';
////    """);
//
////    var options = await this.getOptions();
////    if (options["javaScriptEnabled"]) {
////      await this.setOptions({
////        //"progressBar": true,
////        //"useOnLoadResource": true,
////        //"hidden": true,
////        //"toolbarTopFixedTitle": "Fixed title A",
////        //"useShouldOverrideUrlLoading": true
////        //"hideUrlBar": true,
////        "javaScriptEnabled": false,
////        "toolbarTop": true,
////        "toolbarBottom": false
////      });
////    }
////    else {
////      await this.setOptions({
////        //"progressBar": false,
////        //"useOnLoadResource": false,
////        //"hidden": true,
////        //"toolbarTopFixedTitle": "Fixed title B",
////        //"useShouldOverrideUrlLoading": true
////        //"hideUrlBar": false,
////        "javaScriptEnabled": true,
////        "toolbarTop": false,
////        "toolbarBottom": true
////      });
////    }
//
////    print("\n\n ${await this.isHidden()} \n\n");
////
////    await this.webViewController.injectScriptCode("window.flutter_inappbrowser.callHandler('handlerTest', 1, 5,'string', {'key': 5}, [4,6,8]);");
////    await this.webViewController.injectScriptCode("window.flutter_inappbrowser.callHandler('handlerTest2', false, null, undefined);");
////    await this.webViewController.injectScriptCode("setTimeout(function(){window.flutter_inappbrowser.callHandler('handlerTest', 'anotherString');}, 1000);");
//
////    await this.webViewController.injectScriptCode("console.log({'testObject': 5});");
////    await this.webViewController.injectScriptCode("console.warn('testWarn',null);");
////    await this.webViewController.injectScriptCode("console.log('testObjectStringify', JSON.stringify({'asd': 5}));");
////    await this.webViewController.injectScriptCode("console.info('testInfo', 6);");
////    await this.webViewController.injectScriptCode("console.error('testError', false);");
////    await this.webViewController.injectScriptCode("console.debug('testDebug', true);");
////
////    print(await this.webViewController.injectScriptCode("document.cookie"));
////
////    print("");
////    print(await CookieManager.getCookies(url));
////    print("");
////    print(await CookieManager.getCookie(url, "my_cookie2"));
////    print("");
////    await CookieManager.deleteCookie(url, "my_cookie2");
////    await CookieManager.deleteCookie(url, "_gid", domain: ".googleblog.com");
////    print("");
////    print(await CookieManager.getCookies(url));
////    print("");
////    await CookieManager.deleteCookies(url);
////    print("");
////    print(await CookieManager.getCookies(url));
////    print("");
////    await CookieManager.deleteAllCookies();
////    print("");
////    print(await CookieManager.getCookies(url));
////    print("");
////
////    print(await this.webViewController.injectScriptCode("null"));
////    print(await this.webViewController.injectScriptCode("undefined"));
////    print(await this.webViewController.injectScriptCode("3"));
////    print(await this.webViewController.injectScriptCode("""
////      function asd (a,b) {
////        return a+b;
////       };
////       asd(3,5);
////    """));
////    print(await this.webViewController.injectScriptCode("""
////      ["3",56,"sdf"];
////    """));
////    print(await this.webViewController.injectScriptCode("""
////      var x = {"as":4, "dfdfg": 6};
////      x;
////    """));
////
////    await this.webViewController.injectScriptFile("https://code.jquery.com/jquery-3.3.1.min.js");
////    this.webViewController.injectScriptCode("""
////      \$( "body" ).html( "Next Step..." )
////    """);
////
////    // add custom css
////    this.webViewController.injectStyleCode("""
////    body {
////      background-color: #3c3c3c !important;
////    }
////    """);
////    this.webViewController.injectStyleFile("https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css");
//  }
//
//  @override
//  Future onScrollChanged(int x, int y) async {
////    print(x.toString() + " " + y.toString());
//  }
//
//  @override
//  void onLoadError(String url, int code, String message) {
//    print("\n\nCan't load $url.. Error: $message\n\n");
//  }
//
//  @override
//  void onProgressChanged(int progress) {
////    print("Progress: $progress");
//  }
//
//  @override
//  void onExit() {
//    print("\n\nBrowser closed!\n\n");
//  }
//
//  @override
//  void shouldOverrideUrlLoading(String url) {
//    print("\n\n override $url\n\n");
//    this.webViewController.loadUrl(url);
//
////    var postData = "username=my_username&password=my_password";
////    inAppBrowserFallback.webViewController.postUrl("http://localhost:8080", utf8.encode(postData));
//
////    var htmlData = """
////<!doctype html>
////<html lang="en">
////<head>
////    <meta charset="UTF-8">
////    <meta name="viewport"
////          content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
////    <meta http-equiv="X-UA-Compatible" content="ie=edge">
////    <title>Document</title>
////    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
////    <link rel="stylesheet" href="http://localhost:8080/assets/css/style.css">
////    <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
////</head>
////<body>
////<div class="container">
////    <div class="container">
////        <img src="http://localhost:8080/assets/images/dart.svg" alt="dart logo">
////        <div class="row">
////            <div class="col-sm">
////                One of three columns
////            </div>
////            <div class="col-sm">
////                One of three columns
////            </div>
////            <div class="col-sm">
////                One of three columns
////            </div>
////        </div>
////    </div>
////    <script>
////        console.log("hello");
////    </script>
////</div>
////</body>
////</html>
////    """;
////    inAppBrowserFallback.webViewController.loadData(htmlData);
//  }
//
//  @override
//  void onLoadResource(
//      WebResourceResponse response, WebResourceRequest request) {
//    print("Started at: " +
//        response.startTime.toString() +
//        "ms ---> duration: " +
//        response.duration.toString() +
//        "ms " +
//        response.url);
////    if (response.headers["content-length"] != null)
////      print(response.headers["content-length"] + " length");
//  }
//
//  @override
//  void onConsoleMessage(ConsoleMessage consoleMessage) {
//    print(consoleMessage.message);
////    print("""
////    console output:
////      sourceURL: ${consoleMessage.sourceURL}
////      lineNumber: ${consoleMessage.lineNumber}
////      message: ${consoleMessage.message}
////      messageLevel: ${consoleMessage.messageLevel}
////    """);
//  }
//}
//
//MyInAppBrowser inAppBrowserFallback = new MyInAppBrowser();
//
//class MyChromeSafariBrowser extends ChromeSafariBrowser {
//  MyChromeSafariBrowser(browserFallback) : super(browserFallback);
//
//  @override
//  void onOpened() {
//    print("ChromeSafari browser opened");
//  }
//
//  @override
//  void onLoaded() {
//    print("ChromeSafari browser loaded");
//  }
//
//  @override
//  void onClosed() {
//    print("ChromeSafari browser closed");
//  }
//}
//
//// adding a webview fallback
//MyChromeSafariBrowser chromeSafariBrowser =
//    new MyChromeSafariBrowser(inAppBrowserFallback);
//InAppLocalhostServer localhostServer = new InAppLocalhostServer();
//
//Future main() async {
////  await localhostServer.start();
//  runApp(new MyApp());
//}
//
//class MyApp extends StatefulWidget {
//  @override
//  _MyAppState createState() => new _MyAppState();
//}
//
//class _MyAppState extends State<MyApp> {
//  @override
//  void initState() {
//    super.initState();
////    int indexTest = inAppBrowserFallback.webViewController.addJavaScriptHandler("handlerTest",
////        (arguments) async {
////      print("handlerTest arguments");
////      print(arguments);
////    });
////    int indexTest2 = inAppBrowserFallback.webViewController.addJavaScriptHandler("test2", (arguments) async {
////      print("handlerTest2 arguments");
////      print(arguments);
////      inAppBrowserFallback.webViewController.removeJavaScriptHandler("test", indexTest);
////    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new MaterialApp(
//      home: new Scaffold(
//        appBar: new AppBar(
//          title: const Text('Flutter InAppBrowser Plugin example app'),
//        ),
//        body: new Center(
//          child: new RaisedButton(
//            onPressed: () async {
////              await chromeSafariBrowser.open("https://flutter.io/");
////
////              await InAppBrowser.openWithSystemBrowser("https://flutter.io/");
////
////              await inAppBrowserFallback.open(url: "http://localhost:8080/assets/index.html", options: {
////                "useOnLoadResource": true,
////                //"hidden": true,
////                //"toolbarTopFixedTitle": "Fixed title",
////                //"useShouldOverrideUrlLoading": true
////                //"hideUrlBar": true,
////                //"toolbarTop": false,
////                "toolbarBottom": false
////              });
////
////              await inAppBrowserFallback.openFile("assets/index.html", options: {
////                "useOnLoadResource": true,
////                //"hidden": true,
////                //"useShouldOverrideUrlLoading": true
////                //"hideUrlBar": true,
////                //"toolbarTop": false,
////                //"toolbarBottom": false
////              });
////
////              await CookieManager.setCookie("https://flutter.io/", "my_cookie2", "cookieValue2", domain: "flutter.io", expiresDate: 1540838864611);
////              await CookieManager.setCookie("https://flutter.io/", "my_cookie", "cookieValue", domain: "flutter.io", expiresDate: 1540838864611);
//
////              await inAppBrowserFallback.openData("<html><head><title>Data example</title></head><body><p>This is a \"p\" tag</p></body></html>", options: {});
//
//              await inAppBrowserFallback.open(url: "https://flutter.io/", options: {
//                //"useOnLoadResource": true,
//                //"hidden": true,
//                //"toolbarTopFixedTitle": "Fixed title",
//                "useShouldOverrideUrlLoading": true,
//                //"hideUrlBar": true,
//                //"toolbarTop": false,
//                //"toolbarBottom": false
//              });
//
//            },
//            child: Text("Open InAppBrowser")
//          ),
//        ),
//      ),
//    );
//  }
//}


// Inline WebView Example

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

Future main() async {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  InAppWebViewController webView;
  String url = "";
  double progress = 0;

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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Inline WebView example app'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20.0),
                child: Text("CURRENT URL\n${ (url.length > 50) ? url.substring(0, 50) + "..." : url }"),
              ),
              (progress != 1.0) ? LinearProgressIndicator(value: progress) : null,
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                  ),
                  child: InAppWebView(
                    initialUrl: "https://flutter.io/",
                    //initialData: InAppWebViewInitialData("<html><head><title>Data example</title></head><body><p>This is a \"p\" tag</p></body></html>"),
                    initialHeaders: {

                    },
                    initialOptions: {

                    },
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {
                      print("started $url");
                      setState(() {
                        this.url = url;
                      });
                    },
                    onProgressChanged: (InAppWebViewController controller, int progress) {
                      setState(() {
                        this.progress = progress/100;
                      });
                    },
                  ),
                ),
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
            ].where((Object o) => o != null).toList(),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mail),
              title: Text('Item 2'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              title: Text('Item 3')
            )
          ],
        ),
      ),
    );
  }
}
