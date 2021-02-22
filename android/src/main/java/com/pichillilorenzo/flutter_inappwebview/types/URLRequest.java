package com.pichillilorenzo.flutter_inappwebview.types;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class URLRequest {
  @NonNull
  private String url;
  @Nullable
  private String method;
  @Nullable
  private byte[] body;
  @Nullable
  private Map<String, String> headers;

  public URLRequest(@NonNull String url, @Nullable String method, @Nullable byte[] body, @Nullable Map<String, String> headers) {
    this.url = url;
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
    String method = (String) map.get("method");
    byte[] body = (byte[]) map.get("body");
    Map<String, String> headers = (Map<String, String>) map.get("headers");
    assert url != null;
    return new URLRequest(url, method, body, headers);
  }

  public Map<String, Object> toMap() {
    Map<String, Object> urlRequestMap = new HashMap<>();
    urlRequestMap.put("url", url);
    urlRequestMap.put("method", method);
    urlRequestMap.put("body", body);
    return urlRequestMap;
  }

  @NonNull
  public String getUrl() {
    return url;
  }

  public void setUrl(@NonNull String url) {
    this.url = url;
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

    if (!url.equals(that.url)) return false;
    if (method != null ? !method.equals(that.method) : that.method != null) return false;
    if (!Arrays.equals(body, that.body)) return false;
    return headers != null ? headers.equals(that.headers) : that.headers == null;
  }

  @Override
  public int hashCode() {
    int result = url.hashCode();
    result = 31 * result + (method != null ? method.hashCode() : 0);
    result = 31 * result + Arrays.hashCode(body);
    result = 31 * result + (headers != null ? headers.hashCode() : 0);
    return result;
  }

  @Override
  public String toString() {
    return "URLRequest{" +
            "url='" + url + '\'' +
            ", method='" + method + '\'' +
            ", body=" + Arrays.toString(body) +
            ", headers=" + headers +
            '}';
  }
}
