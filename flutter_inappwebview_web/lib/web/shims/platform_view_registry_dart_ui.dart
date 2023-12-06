import 'dart:html' as html;
import 'dart:ui' as ui;

class platformViewRegistry {
  static bool registerViewFactory(
      String viewTypeId, html.Element Function(int viewId) viewFactory) {
    // ignore: undefined_prefixed_name
    return ui.platformViewRegistry.registerViewFactory(viewTypeId, viewFactory);
  }
}
