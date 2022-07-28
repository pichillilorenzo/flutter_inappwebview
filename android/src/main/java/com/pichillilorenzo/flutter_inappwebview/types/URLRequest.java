package com.pichillilorenzo.flutter_inappwebview.types;

import androidx.annotation.Nullable;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class URLRequest {
  @Nullable
  private String url;
  @Nullable
  private String intentData;
  @Nullable
  private String method;
  @Nullable
  private byte[] body;
  @Nullable
  private Map<String, String> headers;

  public URLRequest(@Nullable String url, @Nullable String intentData, @Nullable String method, @Nullable byte[] body, @Nullable Map<String, String> headers) {
    this.url = url;
    this.intentData = intentData;
    this.method = method;
    this.body = body;
    this.headers = headers;
  }

  @Nullable
  public static URLRequest fromMap(@Nullable Map<String, Object> map) {
    if (map == null) {
      return null;
    }
    String url = (String) map.get("url");
    if (url == null) {
      url = "about:blank";
    }
    String intentData = (String) map.get("intentData");
    String method = (String) map.get("method");
    byte[] body = (byte[]) map.get("body");
    Map<String, String> headers = (Map<String, String>) map.get("headers");
    return new URLRequest(url, intentData, method, body, headers);
  }

  public Map<String, Object> toMap() {
    if (intentData != null) {
      url = "about:blank";
    }
    Map<String, Object> urlRequestMap = new HashMap<>();
    urlRequestMap.put("url", url);
    urlRequestMap.put("intentData", intentData);
    urlRequestMap.put("method", method);
    urlRequestMap.put("body", body);
    return urlRequestMap;
  }

  @Nullable
  public String getUrl() {
    return url;
  }

  public void setUrl(@Nullable String url) {
    this.url = url;
  }

  @Nullable
  public String getIntentData() {
    return intentData;
  }

  public void setIntentData(@Nullable String intentData) {
    this.intentData = intentData;
  }

  @Nullable
  public String getMethod() {
    return method;
  }

  public void setMethod(@Nullable String method) {
    this.method = method;
  }

  @Nullable
  public byte[] getBody() {
    return body;
  }

  public void setBody(@Nullable byte[] body) {
    this.body = body;
  }

  @Nullable
  public Map<String, String> getHeaders() {
    return headers;
  }

  public void setHeaders(@Nullable Map<String, String> headers) {
    this.headers = headers;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    URLRequest that = (URLRequest) o;

    if (url != null ? !url.equals(that.url) : that.url != null) return false;
    if (intentData != null ? !intentData.equals(that.intentData) : that.intentData != null) return false;
    if (method != null ? !method.equals(that.method) : that.method != null) return false;
    if (!Arrays.equals(body, that.body)) return false;
    return headers != null ? headers.equals(that.headers) : that.headers == null;
  }

  @Override
  public int hashCode() {
    int result = url != null ? url.hashCode() : 0;
    result = 31 * result + (intentData != null ? intentData.hashCode() : 0);
    result = 31 * result + (method != null ? method.hashCode() : 0);
    result = 31 * result + Arrays.hashCode(body);
    result = 31 * result + (headers != null ? headers.hashCode() : 0);
    return result;
  }

  @Override
  public String toString() {
    return "URLRequest{" +
            "url='" + url + '\'' +
            ", intentData='" + intentData + '\'' +
            ", method='" + method + '\'' +
            ", body=" + Arrays.toString(body) +
            ", headers=" + headers +
            '}';
  }
}
