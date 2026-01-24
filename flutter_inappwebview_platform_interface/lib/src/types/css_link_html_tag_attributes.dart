import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import '../in_app_webview/platform_inappwebview_controller.dart';
import 'cross_origin.dart';
import 'referrer_policy.dart';
import 'enum_method.dart';

part 'css_link_html_tag_attributes.g.dart';

///Class that represents the possible CSS stylesheet `<link>` HTML attributes to be set used by [PlatformInAppWebViewController.injectCSSFileFromUrl].
@ExchangeableObject()
class CSSLinkHtmlTagAttributes_ {
  ///The HTML [id] attribute is used to specify a unique id for the `<link>` HTML element.
  String? id;

  ///This attribute specifies the media that the linked resource applies to. Its value must be a media type / media query.
  ///This attribute is mainly useful when linking to external stylesheets — it allows the user agent to pick the best adapted one for the device it runs on.
  String? media;

  ///Normal script elements pass minimal information to the `window.onerror` for scripts which do not pass the standard CORS checks.
  ///To allow error logging for sites which use a separate domain for static media, use this attribute.
  CrossOrigin_? crossOrigin;

  ///This attribute contains inline metadata that a user agent can use to verify that a fetched resource has been delivered free of unexpected manipulation.
  String? integrity;

  ///Indicates which referrer to send when fetching the script, or resources fetched by the script.
  ReferrerPolicy_? referrerPolicy;

  ///The [disabled] Boolean attribute indicates whether or not the described stylesheet should be loaded and applied to the document.
  ///If [disabled] is specified in the HTML when it is loaded, the stylesheet will not be loaded during page load.
  ///Instead, the stylesheet will be loaded on-demand, if and when the [disabled] attribute is changed to `false` or removed.
  ///
  ///Setting the [disabled] property in the DOM causes the stylesheet to be removed from the document's `DocumentOrShadowRoot.styleSheets` list.
  bool? disabled;

  ///Specify alternative style sheets.
  bool? alternate;

  ///The title attribute has special semantics on the `<link>` element.
  ///When used on a `<link rel="stylesheet">` it defines a preferred or an alternate stylesheet.
  ///Incorrectly using it may cause the stylesheet to be ignored.
  String? title;

  CSSLinkHtmlTagAttributes_({
    this.id,
    this.media,
    this.crossOrigin,
    this.integrity,
    this.referrerPolicy,
    this.disabled,
    this.alternate,
    this.title,
  });
}
