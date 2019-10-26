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
}

class ContentBlockerTriggerResourceType {
  final String _value;
  const ContentBlockerTriggerResourceType._internal(this._value);
  toString() => _value;

  static const DOCUMENT = const ContentBlockerTriggerResourceType._internal('document');
  static const IMAGE = const ContentBlockerTriggerResourceType._internal('image');
  static const STYLE_SHEET = const ContentBlockerTriggerResourceType._internal('style-sheet');
  static const SCRIPT = const ContentBlockerTriggerResourceType._internal('script');
  static const FONT = const ContentBlockerTriggerResourceType._internal('font');
  static const MEDIA = const ContentBlockerTriggerResourceType._internal('media');
  static const SVG_DOCUMENT = const ContentBlockerTriggerResourceType._internal('svg-document');
  static const RAW = const ContentBlockerTriggerResourceType._internal('raw');
}

class ContentBlockerTrigger {
  String urlFilter;
  List<ContentBlockerTriggerResourceType> resourceType;

  ContentBlockerTrigger(this.urlFilter, {this.resourceType = const []});

  Map<String, dynamic> toMap() {
    List<String> resourceTypeStringList = [];
    resourceType.forEach((type) {
      resourceTypeStringList.add(type.toString());
    });

    return {
      "url-filter": urlFilter,
      "resource-type": resourceTypeStringList
    };
  }
}

class ContentBlockerActionType {
  final String _value;
  const ContentBlockerActionType._internal(this._value);
  toString() => _value;

  static const BLOCK = const ContentBlockerActionType._internal('block');
  static const CSS_DISPLAY_NONE = const ContentBlockerActionType._internal('css-display-none');
  static const MAKE_HTTPS = const ContentBlockerActionType._internal('make-https');
}

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
    return {
      "type": type.toString(),
      "selector": selector
    };
  }
}