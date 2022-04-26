import '../in_app_webview/webview.dart';
import 'renderer_priority.dart';

///Class that provides more specific information about why the render process exited.
///It is used by the [WebView.onRenderProcessGone] event.
class RenderProcessGoneDetail {
  ///Indicates whether the render process was observed to crash, or whether it was killed by the system.
  ///
  ///If the render process was killed, this is most likely caused by the system being low on memory.
  bool didCrash;

  /// Returns the renderer priority that was set at the time that the renderer exited. This may be greater than the priority that
  /// any individual [WebView] requested using [].
  RendererPriority? rendererPriorityAtExit;

  RenderProcessGoneDetail(
      {required this.didCrash, this.rendererPriorityAtExit});

  ///Gets a possible [RenderProcessGoneDetail] instance from a [Map] value.
  static RenderProcessGoneDetail? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return RenderProcessGoneDetail(
      didCrash: map["didCrash"],
      rendererPriorityAtExit:
      RendererPriority.fromValue(map["rendererPriorityAtExit"]),
    );
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "didCrash": didCrash,
      "rendererPriorityAtExit": rendererPriorityAtExit?.toValue()
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}