package com.pichillilorenzo.flutter_inappwebview.ContentBlocker;

import java.util.Map;

public class ContentBlockerAction {
    ContentBlockerActionType type;
    String selector;

    ContentBlockerAction(ContentBlockerActionType type, String selector) {
        this.type = type;
        if (this.type.equals(ContentBlockerActionType.CSS_DISPLAY_NONE)) {
            assert(selector != null);
        }
        this.selector = selector;
    }

    public static ContentBlockerAction fromMap(Map<String, Object> map) {
        ContentBlockerActionType type = ContentBlockerActionType.fromValue((String) map.get("type"));
        String selector = (String) map.get("selector");
        return new ContentBlockerAction(type, selector);
    }
}
