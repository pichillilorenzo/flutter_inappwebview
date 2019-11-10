///
class ContentBlocker {
  ContentBlockerTrigger trigger;
  ContentBlockerAction action;

  ContentBlocker(this.trigger, this.action);

  Map<String, Map<String, dynamic>> toMap() {
    return {
      "trigger": trigger.toMap(),
      "action": action.toMap()
    };
  }

  static ContentBlocker fromMap(Map<dynamic, Map<dynamic, dynamic>> map) {
    return ContentBlocker(
        ContentBlockerTrigger.fromMap(
          Map<String, dynamic>.from(map["trigger"])
        ),
        ContentBlockerAction.fromMap(
          Map<String, dynamic>.from(map["action"])
        )
      );
  }
}

///
class ContentBlockerTriggerResourceType {
  final String _value;
  const ContentBlockerTriggerResourceType._internal(this._value);
  static ContentBlockerTriggerResourceType fromValue(String value) {
    return (["document", "image", "LINK", "style-sheet", "script", "font",
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
  static const RAW = const ContentBlockerTriggerResourceType._internal('raw');
}

///
class ContentBlockerTriggerLoadType {
  final String _value;
  const ContentBlockerTriggerLoadType._internal(this._value);
  static ContentBlockerTriggerLoadType fromValue(String value) {
    return (["first-party", "third-party"].contains(value)) ? ContentBlockerTriggerLoadType._internal(value) : null;
  }
  toValue() => _value;

  static const FIRST_PARTY = const ContentBlockerTriggerLoadType._internal('first-party');
  static const THIRD_PARTY = const ContentBlockerTriggerLoadType._internal('third-party');
}

///
class ContentBlockerTrigger {
  String urlFilter;
  bool urlFilterIsCaseSensitive;
  List<ContentBlockerTriggerResourceType> resourceType;
  List<String> ifDomain;
  List<String> unlessDomain;
  List<ContentBlockerTriggerLoadType> loadType;
  List<String> ifTopUrl;
  List<String> unlessTopUrl;

  ContentBlockerTrigger(String urlFilter, {bool urlFilterIsCaseSensitive = false, List<ContentBlockerTriggerResourceType> resourceType = const [],
    List<String> ifDomain = const [], List<String> unlessDomain = const [], List<ContentBlockerTriggerLoadType> loadType = const [],
    List<String> ifTopUrl = const [], List<String> unlessTopUrl = const []}) {
    this.urlFilter = urlFilter;
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
        map["url-filter"],
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

///
class ContentBlockerActionType {
  final String _value;
  const ContentBlockerActionType._internal(this._value);
  static ContentBlockerActionType fromValue(String value) {
    return (["block", "css-display-none", "make-https"].contains(value)) ? ContentBlockerActionType._internal(value) : null;
  }
  toValue() => _value;

  static const BLOCK = const ContentBlockerActionType._internal('block');
  static const CSS_DISPLAY_NONE = const ContentBlockerActionType._internal('css-display-none');
  static const MAKE_HTTPS = const ContentBlockerActionType._internal('make-https');
}

///
class ContentBlockerAction {
  ContentBlockerActionType type;
  String selector;

  ContentBlockerAction(ContentBlockerActionType type, {String selector}) {
    this.type = type;
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
        ContentBlockerActionType.fromValue(map["type"]),
        selector: map["selector"]
    );
  }
}