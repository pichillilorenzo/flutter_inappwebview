import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WidgetTest extends StatefulWidget {
  final WidgetTestState state = WidgetTestState();

  WidgetTest({Key key}): super(key: key);

  @override
  WidgetTestState createState() {
    return state;
  }
}

class WidgetTestState extends State<WidgetTest> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  InAppWebViewController webView;
  String appBarTitle;

  @override
  Widget build(BuildContext context) {
    return null;
  }
}