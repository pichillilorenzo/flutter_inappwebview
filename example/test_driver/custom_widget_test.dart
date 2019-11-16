import 'package:flutter/widgets.dart';

import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

class WidgetTest extends StatefulWidget {
  final WidgetTestState state = WidgetTestState();

  WidgetTest({Key key}): super(key: key);

  @override
  WidgetTestState createState() {
    return state;
  }
}

class WidgetTestState extends State<WidgetTest> {
  InAppWebViewController webView;
  String appBarTitle;

  @override
  Widget build(BuildContext context) {
    return null;
  }
}