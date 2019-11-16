import 'package:flutter/foundation.dart';

///ContentBlocker class represents a set of rules to use block content in the browser window.
///
///On iOS, it uses [WKContentRuleListStore](https://developer.apple.com/documentation/webkit/wkcontentruleliststore).
///On Android, it uses a custom implementation because such functionality doesn't exist.
///
///In general, this [article](https://developer.apple.com/documentation/safariservices/creating_a_content_blocker) can be used to get an overview about this functionality
///but on Android there are two types of [action] that are unavailable: `block-cookies` and `ignore-previous-rules`.
class ContentBlocker {
  ///Trigger of the content blocker. The trigger tells to the WebView when to perform the corresponding action.
  ContentBlockerTrigger trigger;
  ///Action associated to the trigger. The action tells to the WebView what to do when the trigger is matched.
  ContentBlockerAction action;

  ContentBlocker({@required this.trigger,@required this.action});

  Map<String, Map<String, dynamic>> toMap() {
    return {
      "trigger": trigger.toMap(),
      "action": action.toMap()
    };
  }

  static ContentBlocker fromMap(Map<dynamic, Map<dynamic, dynamic>> map) {
    return ContentBlocker(
        trigger: ContentBlockerTrigger.fromMap(
          Map<String, dynamic>.from(map["trigger"])
        ),
        action: ContentBlockerAction.fromMap(
          Map<String, dynamic>.from(map["action"])
        )
      );
  }
}

///ContentBlockerTriggerResourceType class represents the possible resource type defined for a [ContentBlockerTrigger].
class ContentBlockerTriggerResourceType {
  final String _value;
  const ContentBlockerTriggerResourceType._internal(this._value);
  static ContentBlockerTriggerResourceType fromValue(String value) {
    return (["document", "image", "style-sheet", "script", "font",
      "media", "svg-document", "raw"].contains(value)) ? ContentBlockerTriggerResourceType._internal(value) : null;
  }
  toValue() => _value;

  static const DOCUMENT = const ContentBlockerTriggerResourceType._internal('document');
  static const IMAGE = const ContentBlockerTriggerResourceType._internal('image');
  static const STYLE_SHEET = const ContentBlockerTriggerResourceType._internal('style-sheet');
  static const SCRIPT = const ContentBlockerTriggerResourceType._internal('script');
  static const FONT = const ContentBlockerTriggerResourceType._internal('font');
  static const MEDIA = const ContentBlockerTriggerResourceType._internal('media');
  static const SVG_DOCUMENT = const ContentBlockerTriggerResourceType._internal('svg-document');
  ///Any untyped load
  static const RAW = const ContentBlockerTriggerResourceType._internal('raw');

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///ContentBlockerTriggerLoadType class represents the possible load type for a [ContentBlockerTrigger].
class ContentBlockerTriggerLoadType {
  final String _value;
  const ContentBlockerTriggerLoadType._internal(this._value);
  static ContentBlockerTriggerLoadType fromValue(String value) {
    return (["first-party", "third-party"].contains(value)) ? ContentBlockerTriggerLoadType._internal(value) : null;
  }
  toValue() => _value;

  ///FIRST_PARTY is triggered only if the resource has the same scheme, domain, and port as the main page resource.
  static const FIRST_PARTY = const ContentBlockerTriggerLoadType._internal('first-party');
  ///THIRD_PARTY is triggered if the resource is not from the same domain as the main page resource.
  static const THIRD_PARTY = const ContentBlockerTriggerLoadType._internal('third-party');

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Trigger of the content blocker. The trigger tells to the WebView when to perform the corresponding action.
///A trigger dictionary must include an [ContentBlockerTrigger.urlFilter], which specifies a pattern to match the URL against.
///The remaining properties are optional and modify the behavior of the trigger.
///For example, you can limit the trigger to specific domains or have it not apply when a match is found on a specific domain.
class ContentBlockerTrigger {
  ///A regular expression pattern to match the URL against.
  String urlFilter;
  ///Used only by iOS. A Boolean value. The default value is false.
  bool urlFilterIsCaseSensitive;
  ///A list of [ContentBlockerTriggerResourceType] representing the resource types (how the browser intends to use the resource) that the rule should match.
  ///If not specified, the rule matches all resource types.
  List<ContentBlockerTriggerResourceType> resourceType;
  ///A list of strings matched to a URL's domain; limits action to a list of specific domains.
  ///Values must be lowercase ASCII, or punycode for non-ASCII. Add * in front to match domain and subdomains. Can't be used with [ContentBlockerTrigger.unlessDomain].
  List<String> ifDomain;
  ///A list of strings matched to a URL's domain; acts on any site except domains in a provided list.
  ///Values must be lowercase ASCII, or punycode for non-ASCII. Add * in front to match domain and subdomains. Can't be used with [ContentBlockerTrigger.ifDomain].
  List<String> unlessDomain;
  ///A list of [ContentBlockerTriggerLoadType] that can include one of two mutually exclusive values. If not specified, the rule matches all load types.
  List<ContentBlockerTriggerLoadType> loadType;
  ///A list of strings matched to the entire main document URL; limits the action to a specific list of URL patterns.
  ///Values must be lowercase ASCII, or punycode for non-ASCII. Can't be used with [ContentBlockerTrigger.unlessTopUrl].
  List<String> ifTopUrl;
  ///An array of strings matched to the entire main document URL; acts on any site except URL patterns in provided list.
  ///Values must be lowercase ASCII, or punycode for non-ASCII. Can't be used with [ContentBlockerTrigger.ifTopUrl].
  List<String> unlessTopUrl;

  ContentBlockerTrigger({@required String urlFilter, bool urlFilterIsCaseSensitive = false, List<ContentBlockerTriggerResourceType> resourceType = const [],
    List<String> ifDomain = const [], List<String> unlessDomain = const [], List<ContentBlockerTriggerLoadType> loadType = const [],
    List<String> ifTopUrl = const [], List<String> unlessTopUrl = const []}) {
    this.urlFilter = urlFilter;
    assert(this.urlFilter != null);
    this.resourceType = resourceType;
    this.urlFilterIsCaseSensitive = urlFilterIsCaseSensitive;
    this.ifDomain = ifDomain;
    this.unlessDomain = unlessDomain;
    assert(!(this.ifDomain.isEmpty || this.unlessDomain.isEmpty) == false);
    this.loadType = loadType;
    assert(this.loadType.length <= 2);
    this.ifTopUrl = ifTopUrl;
    this.unlessTopUrl = unlessTopUrl;
    assert(!(this.ifTopUrl.isEmpty || this.unlessTopUrl.isEmpty) == false);
  }

  Map<String, dynamic> toMap() {
    List<String> resourceTypeStringList = [];
    resourceType.forEach((type) {
      resourceTypeStringList.add(type.toValue());
    });
    List<String> loadTypeStringList = [];
    loadType.forEach((type) {
      loadTypeStringList.add(type.toValue());
    });

    Map<String, dynamic> map = {
      "url-filter": urlFilter,
      "url-filter-is-case-sensitive": urlFilterIsCaseSensitive,
      "if-domain": ifDomain,
      "unless-domain": unlessDomain,
      "resource-type": resourceTypeStringList,
      "load-type": loadTypeStringList,
      "if-top-url": ifTopUrl,
      "unless-top-url": unlessTopUrl
    };

    map.keys
        .where((key) => map[key] == null || (map[key] is List && (map[key] as List).length == 0)) // filter keys
        .toList() // create a copy to avoid concurrent modifications
        .forEach(map.remove);

    return map;
  }

  static ContentBlockerTrigger fromMap(Map<String, dynamic> map) {
    List<ContentBlockerTriggerResourceType> resourceType = [];
    List<ContentBlockerTriggerLoadType> loadType = [];

    List<String> resourceTypeStringList = List<String>.from(map["resource-type"] ?? []);
    resourceTypeStringList.forEach((type) {
      resourceType.add(ContentBlockerTriggerResourceType.fromValue(type));
    });

    List<String> loadTypeStringList = List<String>.from(map["load-type"] ?? []);
    loadTypeStringList.forEach((type) {
      loadType.add(ContentBlockerTriggerLoadType.fromValue(type));
    });

    return ContentBlockerTrigger(
        urlFilter: map["url-filter"],
        urlFilterIsCaseSensitive: map["url-filter-is-case-sensitive"],
        ifDomain: List<String>.from(map["if-domain"] ?? []),
        unlessDomain: List<String>.from(map["unless-domain"] ?? []),
        resourceType: resourceType,
        loadType: loadType,
        ifTopUrl: List<String>.from(map["if-top-url"] ?? []),
        unlessTopUrl: List<String>.from(map["unless-top-url"] ?? [])
    );
  }
}

///ContentBlockerActionType class represents the kind of action that can be used with a [ContentBlockerTrigger].
class ContentBlockerActionType {
  final String _value;
  const ContentBlockerActionType._internal(this._value);
  static ContentBlockerActionType fromValue(String value) {
    return (["block", "css-display-none", "make-https"].contains(value)) ? ContentBlockerActionType._internal(value) : null;
  }
  toValue() => _value;

  ///Stops loading of the resource. If the resource was cached, the cache is ignored.
  static const BLOCK = const ContentBlockerActionType._internal('block');
  ///Hides elements of the page based on a CSS selector. A selector field contains the selector list. Any matching element has its display property set to none, which hides it.
  ///
  ///**NOTE**: on Android, JavaScript must be enabled.
  static const CSS_DISPLAY_NONE = const ContentBlockerActionType._internal('css-display-none');
  ///Changes a URL from http to https. URLs with a specified (nondefault) port and links using other protocols are unaffected.
  static const MAKE_HTTPS = const ContentBlockerActionType._internal('make-https');

  bool operator ==(value) => value == _value;

  @override
  int get hashCode => _value.hashCode;
}

///Action associated to the trigger. The action tells to the WebView what to do when the trigger is matched.
///When a trigger matches a resource, the browser queues the associated action for execution.
///The WebView evaluates all the triggers, it executes the actions in order.
///When a domain matches a trigger, all rules after the triggered rule that specify the same action are skipped.
///Group the rules with similar actions together to improve performance.
class ContentBlockerAction {
  ///Type of the action.
  ContentBlockerActionType type;
  ///If the action type is [ContentBlockerActionType.CSS_DISPLAY_NONE], then also the [selector] property is required, otherwise it is ignored.
  ///It specify a string that defines a selector list. Use CSS identifiers as the individual selector values, separated by commas.
  String selector;

  ContentBlockerAction({@required ContentBlockerActionType type, String selector}) {
    this.type = type;
    assert(this.type != null);
    if (this.type == ContentBlockerActionType.CSS_DISPLAY_NONE) {
      assert(selector != null);
    }
    this.selector = selector;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map =  {
      "type": type.toValue(),
      "selector": selector
    };

    map.keys
        .where((key) => map[key] == null || (map[key] is List && (map[key] as List).length == 0)) // filter keys
        .toList() // create a copy to avoid concurrent modifications
        .forEach(map.remove);

    return map;
  }

  static ContentBlockerAction fromMap(Map<String, dynamic> map) {
    return ContentBlockerAction(
        type: ContentBlockerActionType.fromValue(map["type"]),
        selector: map["selector"]
    );
  }
}