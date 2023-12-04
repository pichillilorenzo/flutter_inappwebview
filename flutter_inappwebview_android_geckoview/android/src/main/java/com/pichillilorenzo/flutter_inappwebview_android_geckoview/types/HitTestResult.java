package com.pichillilorenzo.flutter_inappwebview_android_geckoview.types;

import android.webkit.WebView;

import androidx.annotation.Nullable;

import org.mozilla.geckoview.GeckoSession;

import java.util.HashMap;
import java.util.Map;

public class HitTestResult {
  private int type;
  @Nullable
  private String extra;

  public HitTestResult(int type, @Nullable String extra) {
    this.type = type;
    this.extra = extra;
  }

  @Nullable
  static public HitTestResult fromContextElement(@Nullable GeckoSession.ContentDelegate.ContextElement contextElement) {
    if (contextElement == null) {
      return null;
    }

    int type = WebView.HitTestResult.UNKNOWN_TYPE;
    String extra = contextElement.linkUri;
    if (contextElement.type == GeckoSession.ContentDelegate.ContextElement.TYPE_IMAGE) {
      type = WebView.HitTestResult.IMAGE_TYPE;
      if (contextElement.linkUri != null) {
        type = WebView.HitTestResult.SRC_IMAGE_ANCHOR_TYPE;
        extra = contextElement.linkUri;
      } else if (contextElement.srcUri != null) {
        extra = contextElement.srcUri;
      }
    } else if (contextElement.type == GeckoSession.ContentDelegate.ContextElement.TYPE_NONE &&
            contextElement.linkUri != null) {
      type = WebView.HitTestResult.SRC_ANCHOR_TYPE;
    }
    return new HitTestResult(type, extra);
  }

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  @Nullable
  public String getExtra() {
    return extra;
  }

  public void setExtra(@Nullable String extra) {
    this.extra = extra;
  }

  @Nullable
  public Map<String, Object> toMap() {
    Map<String, Object> hitTestResultMap = new HashMap<>();
    hitTestResultMap.put("type", type);
    hitTestResultMap.put("extra", extra);
    return hitTestResultMap;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    HitTestResult that = (HitTestResult) o;

    if (type != that.type) return false;
    return extra != null ? extra.equals(that.extra) : that.extra == null;
  }

  @Override
  public int hashCode() {
    int result = type;
    result = 31 * result + (extra != null ? extra.hashCode() : 0);
    return result;
  }

  @Override
  public String toString() {
    return "HitTestResultMap{" +
            "type=" + type +
            ", extra='" + extra + '\'' +
            '}';
  }
}
