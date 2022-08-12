import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'custom_widget_test.dart';
import 'main_test.dart';

class InAppWebViewCookieManagerTest extends WidgetTest {
  final InAppWebViewCookieManagerTestState state = InAppWebViewCookieManagerTestState();

  @override
  InAppWebViewCookieManagerTestState createState() => state;
}

class InAppWebViewCookieManagerTestState extends WidgetTestState {

  String appBarTitle = "InAppWebViewCookieManagerTest";
  CookieManager cookieManager = CookieManager.instance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: this.scaffoldKey,
        appBar: myAppBar(state: this, title: appBarTitle),
        drawer: myDrawer(context: context),
        body: Container(
            child: Column(children: <Widget>[
              Expanded(
                child: Container(
                  child: InAppWebView(
                    initialUrl: "https://flutter.dev/",
                    initialHeaders: {},
                    initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                            clearCache: true,
                            debuggingEnabled: true
                        )
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      webView = controller;
                    },
                    onLoadStart: (InAppWebViewController controller, String url) {

                    },
                    onLoadStop: (InAppWebViewController controller, String url) async {
                      var title = "";
                      await cookieManager.getCookies(url: url);
                      await cookieManager.setCookie(url: url, name: "myCookie", value: "myValue");
                      Cookie cookie = await cookieManager.getCookie(url: url, name: "myCookie");
                      title = cookie.value.toString();
                      await cookieManager.deleteCookie(url: url, name: "myCookie");
                      cookie = await cookieManager.getCookie(url: url, name: "myCookie");
                      title += " " + ((cookie == null) ? "true" : "false");
                      await cookieManager.deleteCookies(url: url);
                      List<Cookie> cookies = await cookieManager.getCookies(url: url);
                      title += " " + ((cookies.length == 0) ? "true" : "false");

                      setState(() {
                        appBarTitle = title;
                      });
                    },
                  ),
                ),
              ),
            ])
        )
    );
  }
}
