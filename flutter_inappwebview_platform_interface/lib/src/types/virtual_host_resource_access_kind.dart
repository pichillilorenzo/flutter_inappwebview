import '../in_app_webview/platform_inappwebview_controller.dart';

///Cross-origin access policy for resources served through
///[PlatformInAppWebViewController.setVirtualHostNameToFolderMapping].
///
///Values mirror the WebView2 `COREWEBVIEW2_HOST_RESOURCE_ACCESS_KIND` enum.
enum VirtualHostResourceAccessKind {
  ///All cross-origin access to the mapped resources is denied.
  DENY(0),

  ///All cross-origin access is allowed, including access from origins that
  ///could not normally read local resources.
  ALLOW(1),

  ///Cross-origin access follows regular CORS rules.
  DENY_CORS(2);

  final int nativeValue;
  const VirtualHostResourceAccessKind(this.nativeValue);

  int toNativeValue() => nativeValue;
}
