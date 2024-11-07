// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'renderer_priority_policy.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the priority policy will be used to determine whether an out of process renderer should be considered to be a target for OOM killing.
///When a WebView is destroyed it will cease to be considerered when calculating the renderer priority.
///Once no WebViews remain associated with the renderer, the priority of the renderer will be reduced to [RendererPriority.RENDERER_PRIORITY_WAIVED].
///The default policy is to set the priority to [RendererPriority.RENDERER_PRIORITY_IMPORTANT] regardless of visibility,
///and this should not be changed unless the caller also handles renderer crashes with [PlatformWebViewCreationParams.onRenderProcessGone].
///Any other setting will result in WebView renderers being killed by the system more aggressively than the application.
class RendererPriorityPolicy {
  ///The minimum priority at which this WebView desires the renderer process to be bound.
  RendererPriority? rendererRequestedPriority;

  ///If `true`, this flag specifies that when this WebView is not visible, it will be treated as if it had requested a priority of [RendererPriority.RENDERER_PRIORITY_WAIVED].
  bool waivedWhenNotVisible;
  RendererPriorityPolicy(
      {this.rendererRequestedPriority, required this.waivedWhenNotVisible});

  ///Gets a possible [RendererPriorityPolicy] instance from a [Map] value.
  static RendererPriorityPolicy? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    final instance = RendererPriorityPolicy(
      rendererRequestedPriority: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue =>
          RendererPriority.fromNativeValue(map['rendererRequestedPriority']),
        EnumMethod.value =>
          RendererPriority.fromValue(map['rendererRequestedPriority']),
        EnumMethod.name =>
          RendererPriority.byName(map['rendererRequestedPriority'])
      },
      waivedWhenNotVisible: map['waivedWhenNotVisible'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "rendererRequestedPriority": switch (
          enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => rendererRequestedPriority?.toNativeValue(),
        EnumMethod.value => rendererRequestedPriority?.toValue(),
        EnumMethod.name => rendererRequestedPriority?.name()
      },
      "waivedWhenNotVisible": waivedWhenNotVisible,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'RendererPriorityPolicy{rendererRequestedPriority: $rendererRequestedPriority, waivedWhenNotVisible: $waivedWhenNotVisible}';
  }
}
