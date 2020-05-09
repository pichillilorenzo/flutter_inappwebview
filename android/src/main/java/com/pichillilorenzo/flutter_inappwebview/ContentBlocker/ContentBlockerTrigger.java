package com.pichillilorenzo.flutter_inappwebview.ContentBlocker;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

public class ContentBlockerTrigger {

    public String urlFilter;
    public Pattern urlFilterPatternCompiled;
    public Boolean urlFilterIsCaseSensitive;
    public List<ContentBlockerTriggerResourceType> resourceType = new ArrayList<>();
    public List<String> ifDomain = new ArrayList<>();
    public List<String> unlessDomain = new ArrayList<>();
    public List<String> loadType = new ArrayList<>();
    public List<String> ifTopUrl = new ArrayList<>();
    public List<String> unlessTopUrl = new ArrayList<>();

    public ContentBlockerTrigger(String urlFilter, Boolean urlFilterIsCaseSensitive, List<ContentBlockerTriggerResourceType> resourceType, List<String> ifDomain,
                                 List<String> unlessDomain, List<String> loadType, List<String> ifTopUrl, List<String> unlessTopUrl) {
        this.urlFilter = urlFilter;
        this.urlFilterPatternCompiled = Pattern.compile(this.urlFilter);

        this.resourceType = resourceType != null ? resourceType : this.resourceType;
        this.urlFilterIsCaseSensitive = urlFilterIsCaseSensitive != null ? urlFilterIsCaseSensitive : false;
        this.ifDomain = ifDomain != null ? ifDomain : this.ifDomain;
        this.unlessDomain = unlessDomain != null ? unlessDomain : this.unlessDomain;
        if ((!(this.ifDomain.isEmpty() || this.unlessDomain.isEmpty()) != false))
            throw new AssertionError();
        this.loadType = loadType != null ? loadType : this.loadType;
        if ((this.loadType.size() > 2)) throw new AssertionError();
        this.ifTopUrl = ifTopUrl != null ? ifTopUrl : this.ifTopUrl;
        this.unlessTopUrl = unlessTopUrl != null ? unlessTopUrl : this.unlessTopUrl;
        if ((!(this.ifTopUrl.isEmpty() || this.unlessTopUrl.isEmpty()) != false))
            throw new AssertionError();
    }

    public static ContentBlockerTrigger fromMap(Map<String, Object> map) {
        String urlFilter = (String) map.get("url-filter");
        Boolean urlFilterIsCaseSensitive = (Boolean) map.get("url-filter-is-case-sensitive");
        List<String> resourceTypeStringList = (List<String>) map.get("resource-type");
        List<ContentBlockerTriggerResourceType> resourceType = new ArrayList<>();
        for (String type : resourceTypeStringList) {
            resourceType.add(ContentBlockerTriggerResourceType.fromValue(type));
        }
        List<String> ifDomain = (List<String>) map.get("if-domain");
        List<String> unlessDomain = (List<String>) map.get("unless-domain");
        List<String> loadType = (List<String>) map.get("load-type");
        List<String> ifTopUrl = (List<String>) map.get("if-top-url");
        List<String> unlessTopUrl = (List<String>) map.get("unless-top-url");
        return new ContentBlockerTrigger(urlFilter, urlFilterIsCaseSensitive, resourceType, ifDomain, unlessDomain, loadType, ifTopUrl, unlessTopUrl);
    }

}
