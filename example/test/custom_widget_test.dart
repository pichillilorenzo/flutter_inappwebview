import 'package:ansicolor/ansicolor.dart';
import 'package:flutter/widgets.dart';

class WidgetTest extends StatefulWidget {
  final String name;

  WidgetTest({this.name, Key key}): super(key: key) {
    AnsiPen pen = new AnsiPen()..white()..rgb(r: 1.0, g: 0.8, b: 0.2);
    print("\n");
    print(pen("'" + this.name + "' test loading..."));
    print("\n");
  }

  @override
  State<StatefulWidget> createState() {
    return null;
  }
}