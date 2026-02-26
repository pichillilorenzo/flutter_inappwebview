// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script_html_tag_attributes.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents the possible the `<script>` HTML attributes to be set used by [PlatformInAppWebViewController.injectJavascriptFileFromUrl].
class ScriptHtmlTagAttributes {
  ///For classic scripts, if the [async] attribute is present,
  ///then the classic script will be fetched in parallel to parsing and evaluated as soon as it is available.
  ///
  ///For module scripts, if the [async] attribute is present then the scripts and all their dependencies will be executed in the defer queue,
  ///therefore they will get fetched in parallel to parsing and evaluated as soon as they are available.
  ///
  ///This attribute allows the elimination of parser-blocking JavaScript where the browser
  ///would have to load and evaluate scripts before continuing to parse.
  ///[defer] has a similar effect in this case.
  ///
  ///This is a boolean attribute: the presence of a boolean attribute on an element represents the true value,
  ///and the absence of the attribute represents the false value.
  bool? async;

  ///Normal script elements pass minimal information to the `window.onerror` for scripts which do not pass the standard CORS checks.
  ///To allow error logging for sites which use a separate domain for static media, use this attribute.
  CrossOrigin? crossOrigin;

  ///This Boolean attribute is set to indicate to a browser that the script is meant to be executed after the document has been parsed, but before firing `DOMContentLoaded`.
  ///
  ///Scripts with the [defer] attribute will prevent the `DOMContentLoaded` event from firing until the script has loaded and finished evaluating.
  ///
  ///Scripts with the [defer] attribute will execute in the order in which they appear in the document.
  ///
  ///This attribute allows the elimination of parser-blocking JavaScript where the browser would have to load and evaluate scripts before continuing to parse.
  ///[async] has a similar effect in this case.
  bool? defer;

  ///The HTML [id] attribute is used to specify a unique id for the `<script>` HTML element.
  String? id;

  ///This attribute contains inline metadata that a user agent can use to verify that a fetched resource has been delivered free of unexpected manipulation.
  String? integrity;

  ///This Boolean attribute is set to indicate that the script should not be executed in browsers that support ES2015 modules — in effect,
  ///this can be used to serve fallback scripts to older browsers that do not support modular JavaScript code.
  bool? noModule;

  ///A cryptographic nonce (number used once) to whitelist scripts in a script-src Content-Security-Policy.
  ///The server must generate a unique nonce value each time it transmits a policy.
  ///It is critical to provide a nonce that cannot be guessed as bypassing a resource's policy is otherwise trivial.
  String? nonce;

  ///Represents a callback function that will be called if an error occurred while trying to load the script.
  ///
  ///**NOTE**: This callback requires the [id] property to be set.
  Function? onError;

  ///Represents a callback function that will be called as soon as the script has been loaded successfully.
  ///
  ///**NOTE**: This callback requires the [id] property to be set.
  Function? onLoad;

  ///Indicates which referrer to send when fetching the script, or resources fetched by the script.
  ReferrerPolicy? referrerPolicy;

  ///This attribute indicates the type of script represented. The value of this attribute will be in one of the following categories.
  ///The default value is `text/javascript`.
  String type;
  ScriptHtmlTagAttributes({
    this.type = "text/javascript",
    this.id,
    this.async,
    this.defer,
    this.crossOrigin,
    this.integrity,
    this.noModule,
    this.nonce,
    this.referrerPolicy,
    this.onLoad,
    this.onError,
  }) {
    if (this.onLoad != null || this.onError != null) {
      assert(
        this.id != null,
        'onLoad and onError callbacks require the id property to be set.',
      );
    }
  }

  ///Gets a possible [ScriptHtmlTagAttributes] instance from a [Map] value.
  static ScriptHtmlTagAttributes? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = ScriptHtmlTagAttributes(
      async: map['async'],
      crossOrigin: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => CrossOrigin.fromNativeValue(
          map['crossOrigin'],
        ),
        EnumMethod.value => CrossOrigin.fromValue(map['crossOrigin']),
        EnumMethod.name => CrossOrigin.byName(map['crossOrigin']),
      },
      defer: map['defer'],
      id: map['id'],
      integrity: map['integrity'],
      noModule: map['noModule'],
      nonce: map['nonce'],
      referrerPolicy: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => ReferrerPolicy.fromNativeValue(
          map['referrerPolicy'],
        ),
        EnumMethod.value => ReferrerPolicy.fromValue(map['referrerPolicy']),
        EnumMethod.name => ReferrerPolicy.byName(map['referrerPolicy']),
      },
    );
    if (map['type'] != null) {
      instance.type = map['type'];
    }
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "async": async,
      "crossOrigin": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => crossOrigin?.toNativeValue(),
        EnumMethod.value => crossOrigin?.toValue(),
        EnumMethod.name => crossOrigin?.name(),
      },
      "defer": defer,
      "id": id,
      "integrity": integrity,
      "noModule": noModule,
      "nonce": nonce,
      "referrerPolicy": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => referrerPolicy?.toNativeValue(),
        EnumMethod.value => referrerPolicy?.toValue(),
        EnumMethod.name => referrerPolicy?.name(),
      },
      "type": type,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'ScriptHtmlTagAttributes{async: $async, crossOrigin: $crossOrigin, defer: $defer, id: $id, integrity: $integrity, noModule: $noModule, nonce: $nonce, referrerPolicy: $referrerPolicy, type: $type}';
  }
}
