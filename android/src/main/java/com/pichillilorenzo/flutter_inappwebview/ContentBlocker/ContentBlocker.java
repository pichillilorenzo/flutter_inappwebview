package com.pichillilorenzo.flutter_inappwebview.ContentBlocker;

public class ContentBlocker {
    public ContentBlockerTrigger trigger;
    public ContentBlockerAction action;

    public ContentBlocker (ContentBlockerTrigger trigger, ContentBlockerAction action) {
        this.trigger = trigger;
        this.action = action;
    }
}
