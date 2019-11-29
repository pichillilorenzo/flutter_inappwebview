package com.pichillilorenzo.flutter_inappwebview;

import android.util.Log;

import java.lang.reflect.Field;
import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;

public class Options {

  static String LOG_TAG = "Options";

  public Options parse(HashMap<String, Object> options) {
    Iterator it = options.entrySet().iterator();
    while (it.hasNext()) {
      Map.Entry<String, Object> pair = (Map.Entry<String, Object>) it.next();
      Object value = this.onParse(pair);
      try {
        this.getClass().getDeclaredField(pair.getKey()).set(this, value);
      } catch (NoSuchFieldException e) {
        Log.d(LOG_TAG, e.getMessage());
      } catch (IllegalAccessException e) {
        Log.d(LOG_TAG, e.getMessage());
      }
    }
    return this;
  }

  public Object onParse(Map.Entry<String, Object> pair) {
    return pair.getValue();
  }

  public HashMap<String, Object> getHashMap() {
    HashMap<String, Object> options = new HashMap<>();
    for (Field field : this.getClass().getDeclaredFields()) {
      options.put(field.getName(), onGetHashMap(field));
    }
    return options;
  }

  public Object onGetHashMap(Field field) {
    try {
      return field.get(this);
    } catch (IllegalAccessException e) {
      Log.d(LOG_TAG, e.getMessage());
    }
    return null;
  }

}
