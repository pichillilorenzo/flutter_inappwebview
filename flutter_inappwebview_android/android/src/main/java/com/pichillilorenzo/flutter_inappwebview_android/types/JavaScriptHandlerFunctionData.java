package com.pichillilorenzo.flutter_inappwebview_android.types;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashMap;
import java.util.Map;

public class JavaScriptHandlerFunctionData {
  @NonNull
  private String origin;
  private boolean isMainFrame;
  @NonNull
  private String args;

  public JavaScriptHandlerFunctionData(@NonNull String origin, boolean isMainFrame, @NonNull String args) {
    this.origin = origin;
    this.isMainFrame = isMainFrame;
    this.args = args;
  }

  @Nullable
  public static JavaScriptHandlerFunctionData fromMap(@Nullable Map<String, Object> map) {
    if (map == null) {
      return null;
    }
    String origin = (String) map.get("origin");
    boolean isMainFrame = (boolean) map.get("isMainFrame");
    String args = (String) map.get("args");
    return new JavaScriptHandlerFunctionData(origin, isMainFrame, args);
  }

  public Map<String, Object> toMap() {
    Map<String, Object> map = new HashMap<>();
    map.put("origin", origin);
    map.put("isMainFrame", isMainFrame);
    map.put("args", args);
    return map;
  }

  @NonNull
  public String getOrigin() {
    return origin;
  }

  public void setOrigin(@NonNull String origin) {
    this.origin = origin;
  }

  public boolean isMainFrame() {
    return isMainFrame;
  }

  public void setMainFrame(boolean mainFrame) {
    isMainFrame = mainFrame;
  }

  @NonNull
  public String getArgs() {
    return args;
  }

  public void setArgs(@NonNull String args) {
    this.args = args;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    JavaScriptHandlerFunctionData that = (JavaScriptHandlerFunctionData) o;
    return isMainFrame == that.isMainFrame && origin.equals(that.origin) && args.equals(that.args);
  }

  @Override
  public int hashCode() {
    int result = origin.hashCode();
    result = 31 * result + Boolean.hashCode(isMainFrame);
    result = 31 * result + args.hashCode();
    return result;
  }

  @Override
  public String toString() {
    return "JavaScriptHandlerFunctionData{" +
            "origin='" + origin + '\'' +
            ", isMainFrame=" + isMainFrame +
            ", args='" + args + '\'' +
            '}';
  }
}
