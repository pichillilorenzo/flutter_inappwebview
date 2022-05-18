package com.pichillilorenzo.flutter_inappwebview.types;

import android.os.Build;
import android.webkit.WebResourceError;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import java.util.HashMap;
import java.util.Map;

public class WebResourceErrorExt {
  private int errorCode;
  @NonNull
  private String description;

  public WebResourceErrorExt(int errorCode, @NonNull String description) {
    this.errorCode = errorCode;
    this.description = description;
  }

  @RequiresApi(Build.VERSION_CODES.M)
  static public WebResourceErrorExt fromWebResourceError(@NonNull WebResourceError error) {
    return new WebResourceErrorExt(error.getErrorCode(), error.getDescription().toString());
  }

  public Map<String, Object> toMap() {
    Map<String, Object> webResourceErrorMap = new HashMap<>();
    webResourceErrorMap.put("errorCode", getErrorCode());
    webResourceErrorMap.put("description", getDescription());
    return webResourceErrorMap;
  }

  public int getErrorCode() {
    return errorCode;
  }

  public void setErrorCode(int errorCode) {
    this.errorCode = errorCode;
  }

  @NonNull
  public String getDescription() {
    return description;
  }

  public void setDescription(@NonNull String description) {
    this.description = description;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    WebResourceErrorExt that = (WebResourceErrorExt) o;

    if (errorCode != that.errorCode) return false;
    return description.equals(that.description);
  }

  @Override
  public int hashCode() {
    int result = errorCode;
    result = 31 * result + description.hashCode();
    return result;
  }

  @Override
  public String toString() {
    return "WebResourceErrorExt{" +
            "errorCode=" + errorCode +
            ", description='" + description + '\'' +
            '}';
  }
}
