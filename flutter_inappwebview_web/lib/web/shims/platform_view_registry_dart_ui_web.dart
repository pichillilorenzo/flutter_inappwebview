import 'dart:html' as html;
// ignore: uri_does_not_exist
import 'dart:ui_web' as ui_web;

class platformViewRegistry {
  static bool registerViewFactory(
      String viewTypeId, html.Element Function(int viewId) viewFactory) {
    return ui_web.platformViewRegistry
        .registerViewFactory(viewTypeId, viewFactory);
  }
}
