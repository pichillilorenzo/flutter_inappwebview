// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'css_link_html_tag_attributes.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the possible CSS stylesheet `<link>` HTML attributes to be set used by [PlatformInAppWebViewController.injectCSSFileFromUrl].
class CSSLinkHtmlTagAttributes {
  ///Specify alternative style sheets.
  bool? alternate;

  ///Normal script elements pass minimal information to the `window.onerror` for scripts which do not pass the standard CORS checks.
  ///To allow error logging for sites which use a separate domain for static media, use this attribute.
  CrossOrigin? crossOrigin;

  ///The [disabled] Boolean attribute indicates whether or not the described stylesheet should be loaded and applied to the document.
  ///If [disabled] is specified in the HTML when it is loaded, the stylesheet will not be loaded during page load.
  ///Instead, the stylesheet will be loaded on-demand, if and when the [disabled] attribute is changed to `false` or removed.
  ///
  ///Setting the [disabled] property in the DOM causes the stylesheet to be removed from the document's `DocumentOrShadowRoot.styleSheets` list.
  bool? disabled;

  ///The HTML [id] attribute is used to specify a unique id for the `<link>` HTML element.
  String? id;

  ///This attribute contains inline metadata that a user agent can use to verify that a fetched resource has been delivered free of unexpected manipulation.
  String? integrity;

  ///This attribute specifies the media that the linked resource applies to. Its value must be a media type / media query.
  ///This attribute is mainly useful when linking to external stylesheets — it allows the user agent to pick the best adapted one for the device it runs on.
  String? media;

  ///Indicates which referrer to send when fetching the script, or resources fetched by the script.
  ReferrerPolicy? referrerPolicy;

  ///The title attribute has special semantics on the `<link>` element.
  ///When used on a `<link rel="stylesheet">` it defines a preferred or an alternate stylesheet.
  ///Incorrectly using it may cause the stylesheet to be ignored.
  String? title;
  CSSLinkHtmlTagAttributes(
      {this.alternate,
      this.crossOrigin,
      this.disabled,
      this.id,
      this.integrity,
      this.media,
      this.referrerPolicy,
      this.title});

  ///Gets a possible [CSSLinkHtmlTagAttributes] instance from a [Map] value.
  static CSSLinkHtmlTagAttributes? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = CSSLinkHtmlTagAttributes(
      alternate: map['alternate'],
      crossOrigin: CrossOrigin.fromNativeValue(map['crossOrigin']),
      disabled: map['disabled'],
      id: map['id'],
      integrity: map['integrity'],
      media: map['media'],
      referrerPolicy: ReferrerPolicy.fromNativeValue(map['referrerPolicy']),
      title: map['title'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "alternate": alternate,
      "crossOrigin": crossOrigin?.toNativeValue(),
      "disabled": disabled,
      "id": id,
      "integrity": integrity,
      "media": media,
      "referrerPolicy": referrerPolicy?.toNativeValue(),
      "title": title,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'CSSLinkHtmlTagAttributes{alternate: $alternate, crossOrigin: $crossOrigin, disabled: $disabled, id: $id, integrity: $integrity, media: $media, referrerPolicy: $referrerPolicy, title: $title}';
  }
}
