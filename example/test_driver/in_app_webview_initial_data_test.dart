import 'package:flutter/material.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main_test.dart';
import 'custom_widget_test.dart';

class InAppWebViewInitialDataTest extends WidgetTest {
  final InAppWebViewInitialDataTestState state = InAppWebViewInitialDataTestState();

  @override
  InAppWebViewInitialDataTestState createState() => state;
}

class InAppWebViewInitialDataTestState extends WidgetTestState {
  String appBarTitle = "InAppWebViewInitialDataTest";

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
                    initialData: InAppWebViewInitialData(data: """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewInitialDataTest</title>
        <link rel="stylesheet" href="https://getbootstrap.com/docs/4.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="css/style.css">
        <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
        <link rel="shortcut icon" href="favicon.ico">
    </head>
    <body class="text-center">
        <div class="cover-container d-flex w-100 h-100 p-3 mx-auto flex-column">
            <header class="masthead mb-auto">
                <div class="inner">
                    <h3 class="masthead-brand">InAppWebViewInitialDataTest</h3>
                    <nav class="nav nav-masthead justify-content-center">
                        <a class="nav-link active" href="index.html">Home</a>
                        <a class="nav-link" href="page-1.html">Page 1</a>
                        <a class="nav-link" href="page-2.html">Page 2</a>
                    </nav>
                </div>
            </header>

            <main role="main" class="inner cover">
                <h1 class="cover-heading">InAppWebViewInitialFileTest</h1>
                <img src="images/flutter-logo.svg" alt="flutter logo">
                <p>
                    <img src="https://via.placeholder.com/100x50" alt="placeholder 100x50">
                </p>
                <a id="link" href="https://github.com/pichillilorenzo/flutter_inappwebview">flutter_inappwebview</a>
            </main>
        </div>
    </body>
</html>
                    """),
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
                    onLoadStop: (InAppWebViewController controller, String url) {
                      setState(() {
                        appBarTitle = "true";
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
