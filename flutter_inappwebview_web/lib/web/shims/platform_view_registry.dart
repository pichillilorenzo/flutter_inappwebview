import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

class platformViewRegistry {
  static bool registerViewFactory(
      String viewTypeId, web.Element Function(int viewId) viewFactory) {
    return ui_web.platformViewRegistry
        .registerViewFactory(viewTypeId, viewFactory);
  }
}
