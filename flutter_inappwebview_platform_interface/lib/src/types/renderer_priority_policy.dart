import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import 'renderer_priority.dart';
import 'enum_method.dart';

part 'renderer_priority_policy.g.dart';

///Class that represents the priority policy will be used to determine whether an out of process renderer should be considered to be a target for OOM killing.
///When a WebView is destroyed it will cease to be considerered when calculating the renderer priority.
///Once no WebViews remain associated with the renderer, the priority of the renderer will be reduced to [RendererPriority.RENDERER_PRIORITY_WAIVED].
///The default policy is to set the priority to [RendererPriority.RENDERER_PRIORITY_IMPORTANT] regardless of visibility,
///and this should not be changed unless the caller also handles renderer crashes with [PlatformWebViewCreationParams.onRenderProcessGone].
///Any other setting will result in WebView renderers being killed by the system more aggressively than the application.
@ExchangeableObject()
class RendererPriorityPolicy_ {
  ///The minimum priority at which this WebView desires the renderer process to be bound.
  RendererPriority_? rendererRequestedPriority;

  ///If `true`, this flag specifies that when this WebView is not visible, it will be treated as if it had requested a priority of [RendererPriority.RENDERER_PRIORITY_WAIVED].
  bool waivedWhenNotVisible;

  RendererPriorityPolicy_(
      {required this.rendererRequestedPriority,
      required this.waivedWhenNotVisible});
}
