package com.pichillilorenzo.flutter_inappwebview;

import java.util.Map;

public interface Options<T> {
  public Options parse(Map<String, Object> options);
  public Map<String, Object> toMap();
  public Map<String, Object> getRealOptions(T obj);
}
