package com.pichillilorenzo.flutter_inappbrowser.ContentBlocker;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class ContentBlockerTrigger {

    public String urlFilter;
    List<ContentBlockerTriggerResourceType> resourceType = new ArrayList<>();

    public ContentBlockerTrigger(String urlFilter, List<ContentBlockerTriggerResourceType> resourceType) {
        this.urlFilter = urlFilter;
        this.resourceType = resourceType != null ? resourceType : this.resourceType;
    }

    public static ContentBlockerTrigger fromMap(Map<String, Object> map) {
        String urlFilter = (String) map.get("url-filter");
        List<String> resourceTypeStringList = (List<String>) map.get("resource-type");
        List<ContentBlockerTriggerResourceType> resourceType = new ArrayList<>();
        for (String type : resourceTypeStringList) {
            resourceType.add(ContentBlockerTriggerResourceType.fromValue(type));
        }
        return new ContentBlockerTrigger(urlFilter, resourceType);
    }

}
