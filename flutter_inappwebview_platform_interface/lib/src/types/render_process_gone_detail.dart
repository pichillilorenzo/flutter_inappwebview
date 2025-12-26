import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'renderer_priority.dart';
import 'enum_method.dart';

part 'render_process_gone_detail.g.dart';

///Class that provides more specific information about why the render process exited.
///It is used by the [PlatformWebViewCreationParams.onRenderProcessGone] event.
@ExchangeableObject()
class RenderProcessGoneDetail_ {
  ///Indicates whether the render process was observed to crash, or whether it was killed by the system.
  ///
  ///If the render process was killed, this is most likely caused by the system being low on memory.
  bool didCrash;

  /// Returns the renderer priority that was set at the time that the renderer exited. This may be greater than the priority that
  /// any individual `WebView` requested using [].
  RendererPriority_? rendererPriorityAtExit;

  RenderProcessGoneDetail_(
      {required this.didCrash, this.rendererPriorityAtExit});
}
