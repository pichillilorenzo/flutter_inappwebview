import 'dart:ui' as ui;
import 'package:web/web.dart';

class platformViewRegistry {
  static bool registerViewFactory(
      String viewTypeId, Element Function(int viewId) viewFactory) {
    // ignore: undefined_prefixed_name
    return ui.platformViewRegistry.registerViewFactory(viewTypeId, viewFactory);
  }
}
