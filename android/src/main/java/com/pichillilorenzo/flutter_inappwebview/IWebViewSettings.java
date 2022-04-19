package com.pichillilorenzo.flutter_inappwebview;

import java.util.Map;

public interface IWebViewSettings<T> {
  public IWebViewSettings parse(Map<String, Object> settings);
  public Map<String, Object> toMap();
  public Map<String, Object> getRealSettings(T obj);
}
