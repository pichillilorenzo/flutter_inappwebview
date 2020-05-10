package com.pichillilorenzo.flutter_inappwebview;

import java.util.HashMap;

public interface Options {
  static String LOG_TAG = "Options";
  public Options parse(HashMap<String, Object> options);
  public HashMap<String, Object> getHashMap();
}
