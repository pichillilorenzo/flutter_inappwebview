package com.pichillilorenzo.flutter_inappbrowser;

import android.os.Build;
import android.util.Log;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.ValueCallback;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class MyCookieManager implements MethodChannel.MethodCallHandler {

  static final String LOG_TAG = "MyCookieManager";

  public static PluginRegistry.Registrar registrar;
  public static MethodChannel channel;

  public MyCookieManager(PluginRegistry.Registrar r) {
    registrar = r;
    channel = new MethodChannel(registrar.messenger(), "com.pichillilorenzo/flutter_inappbrowser_cookiemanager");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "setCookie":
        {
          String url = (String) call.argument("url");
          String name = (String) call.argument("name");
          String value = (String) call.argument("value");
          String domain = (String) call.argument("domain");
          String path = (String) call.argument("path");
          Long expiresDate = new Long((Integer) call.argument("expiresDate"));
          Boolean isHTTPOnly = (Boolean) call.argument("isHTTPOnly");
          Boolean isSecure = (Boolean) call.argument("isSecure");
          MyCookieManager.setCookie(url, name, value, domain, path, expiresDate, isHTTPOnly, isSecure, result);
        }
        break;
      case "getCookies":
        result.success(MyCookieManager.getCookies((String) call.argument("url")));
        break;
      case "deleteCookie":
        {
          String url = (String) call.argument("url");
          String name = (String) call.argument("name");
          MyCookieManager.deleteCookie(url, name, result);
        }
        break;
      case "deleteCookies":
        MyCookieManager.deleteCookies(result);
        break;
      default:
        result.notImplemented();
    }
  }

  public static void setCookie(String url,
                               String name,
                               String value,
                               String domain,
                               String path,
                               Long expiresDate,
                               Boolean isHTTPOnly,
                               Boolean isSecure,
                               final MethodChannel.Result result) {

    String cookieValue = name + "=" + value;

    if (domain != null && !domain.isEmpty())
      cookieValue += "; Domain=" + domain;

    if (path != null && !path.isEmpty())
      cookieValue += "; Path=" + path;

    if (expiresDate != null)
      cookieValue += "; Expires=" + getCookieExpirationDate(expiresDate);

    if (isHTTPOnly != null && isHTTPOnly)
      cookieValue += "; HttpOnly";

    if (isSecure != null && isSecure)
      cookieValue += "; Secure";

    CookieManager cookieManager = CookieManager.getInstance();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      cookieManager.setCookie(url, cookieValue, new ValueCallback<Boolean>() {
        @Override
        public void onReceiveValue(Boolean aBoolean) {
          result.success(true);
        }
      });
      cookieManager.flush();
    }
    else {
      CookieSyncManager cookieSyncMngr = CookieSyncManager.createInstance(registrar.context());
      cookieSyncMngr.startSync();
      cookieManager.setCookie(url, cookieValue);
      result.success(true);
      cookieSyncMngr.stopSync();
      cookieSyncMngr.sync();
    }
  }

  public static List<Map<String, Object>> getCookies(final String url) {

    final List<Map<String, Object>> cookieListMap = new ArrayList<>();

    CookieManager cookieManager = CookieManager.getInstance();

    String[] cookies = cookieManager.getCookie(url).split(";");
    for (String cookie : cookies) {
      String[] nameValue = cookie.split("=", 2);
      String name = nameValue[0].trim();
      String value = nameValue[1].trim();
      Map<String, Object> cookieMap = new HashMap<>();
      cookieMap.put("name", name);
      cookieMap.put("value", value);
      cookieListMap.add(cookieMap);
    }
    return cookieListMap;

  }

  public static void deleteCookie(String url, String cookieName, final MethodChannel.Result result) {

    String cookieValue = cookieName + "=; Expires=Thu, 01 Jan 1970 00:00:01 GMT;";

    CookieManager cookieManager = CookieManager.getInstance();

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      cookieManager.setCookie(url, cookieValue, new ValueCallback<Boolean>() {
        @Override
        public void onReceiveValue(Boolean aBoolean) {
          result.success(true);
        }
      });
      cookieManager.flush();
    }
    else {
      CookieSyncManager cookieSyncMngr = CookieSyncManager.createInstance(registrar.context());
      cookieSyncMngr.startSync();
      cookieManager.setCookie(url, cookieValue);
      result.success(true);
      cookieSyncMngr.stopSync();
      cookieSyncMngr.sync();
    }
  }

  public static void deleteCookies(final MethodChannel.Result result) {
    CookieManager cookieManager = CookieManager.getInstance();
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      cookieManager.removeAllCookies(new ValueCallback<Boolean>() {
        @Override
        public void onReceiveValue(Boolean aBoolean) {
          result.success(true);
        }
      });
      cookieManager.flush();
    }
    else {
      CookieSyncManager cookieSyncMngr = CookieSyncManager.createInstance(registrar.context());
      cookieSyncMngr.startSync();
      cookieManager.removeAllCookie();
      result.success(true);
      cookieSyncMngr.stopSync();
      cookieSyncMngr.sync();
    }
  }

  public static String getCookieExpirationDate(Long timestamp) {
    final SimpleDateFormat sdf = new SimpleDateFormat("EEE, d MMM yyyy hh:mm:ss z");
    sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
    return sdf.format(new Date(timestamp));
  }

}
