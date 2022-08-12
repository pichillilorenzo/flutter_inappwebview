package com.pichillilorenzo.flutter_inappwebview;

import android.os.Build;
import android.util.Log;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.ValueCallback;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class MyCookieManager implements MethodChannel.MethodCallHandler {

  static final String LOG_TAG = "MyCookieManager";

  public static MethodChannel channel;
  public static CookieManager cookieManager;

  public MyCookieManager(BinaryMessenger messenger) {
    channel = new MethodChannel(messenger, "com.pichillilorenzo/flutter_inappwebview_cookiemanager");
    channel.setMethodCallHandler(this);
    cookieManager = CookieManager.getInstance();
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
          String expiresDateString = (String) call.argument("expiresDate");
          Long expiresDate = (expiresDateString != null ? new Long(expiresDateString) : null);
          Integer maxAge = (Integer) call.argument("maxAge");
          Boolean isSecure = (Boolean) call.argument("isSecure");
          Boolean isHttpOnly = (Boolean) call.argument("isHttpOnly");
          String sameSite = (String) call.argument("sameSite");
          MyCookieManager.setCookie(url,
                  name,
                  value,
                  domain,
                  path,
                  expiresDate,
                  maxAge,
                  isSecure,
                  isHttpOnly,
                  sameSite,
                  result);
        }
        break;
      case "getCookies":
        result.success(MyCookieManager.getCookies((String) call.argument("url")));
        break;
      case "deleteCookie":
        {
          String url = (String) call.argument("url");
          String name = (String) call.argument("name");
          String domain = (String) call.argument("domain");
          String path = (String) call.argument("path");
          MyCookieManager.deleteCookie(url, name, domain, path, result);
        }
        break;
      case "deleteCookies":
        {
          String url = (String) call.argument("url");
          String domain = (String) call.argument("domain");
          String path = (String) call.argument("path");
          MyCookieManager.deleteCookies(url, domain, path, result);
        }
        break;
      case "deleteAllCookies":
        MyCookieManager.deleteAllCookies(result);
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
                               Integer maxAge,
                               Boolean isSecure,
                               Boolean isHttpOnly,
                               String sameSite,
                               final MethodChannel.Result result) {

    String cookieValue = name + "=" + value + "; Domain=" + domain + "; Path=" + path;

    if (expiresDate != null)
      cookieValue += "; Expires=" + getCookieExpirationDate(expiresDate);

    if (maxAge != null)
      cookieValue += "; Max-Age=" + maxAge.toString();

    if (isSecure != null && isSecure)
      cookieValue += "; Secure";

    if (isHttpOnly != null && isHttpOnly)
      cookieValue += "; HttpOnly";

    if (sameSite != null)
      cookieValue += "; SameSite=" + sameSite;

    cookieValue += ";";

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
      CookieSyncManager cookieSyncMngr = CookieSyncManager.createInstance(Shared.applicationContext);
      cookieSyncMngr.startSync();
      cookieManager.setCookie(url, cookieValue);
      result.success(true);
      cookieSyncMngr.stopSync();
      cookieSyncMngr.sync();
    }
  }

  public static List<Map<String, Object>> getCookies(final String url) {

    final List<Map<String, Object>> cookieListMap = new ArrayList<>();

    String cookiesString = cookieManager.getCookie(url);

    if (cookiesString != null) {
      String[] cookies = cookiesString.split(";");
      for (String cookie : cookies) {
        String[] nameValue = cookie.split("=", 2);
        String name = nameValue[0].trim();
        String value = nameValue[1].trim();
        Map<String, Object> cookieMap = new HashMap<>();
        cookieMap.put("name", name);
        cookieMap.put("value", value);
        cookieMap.put("expiresDate", null);
        cookieMap.put("isSessionOnly", null);
        cookieMap.put("domain", null);
        cookieMap.put("sameSite", null);
        cookieMap.put("isSecure", null);
        cookieMap.put("isHttpOnly", null);
        cookieMap.put("path", null);

        cookieListMap.add(cookieMap);
      }
    }
    return cookieListMap;

  }

  public static void deleteCookie(String url, String name, String domain, String path, final MethodChannel.Result result) {

    String cookieValue = name + "=; Path=" + path + "; Domain=" + domain + "; Max-Age=-1;";

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
      CookieSyncManager cookieSyncMngr = CookieSyncManager.createInstance(Shared.applicationContext);
      cookieSyncMngr.startSync();
      cookieManager.setCookie(url, cookieValue);
      result.success(true);
      cookieSyncMngr.stopSync();
      cookieSyncMngr.sync();
    }
  }

  public static void deleteCookies(String url, String domain, String path, final MethodChannel.Result result) {

    CookieSyncManager cookieSyncMngr = null;

    String cookiesString = cookieManager.getCookie(url);
    if (cookiesString != null) {

      if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
        cookieSyncMngr = CookieSyncManager.createInstance(Shared.applicationContext);
        cookieSyncMngr.startSync();
      }

      String[] cookies = cookiesString.split(";");
      for (String cookie : cookies) {
        String[] nameValue = cookie.split("=", 2);
        String name = nameValue[0].trim();
        String cookieValue = name + "=; Path=" + path + "; Domain=" + domain + "; Max-Age=-1;";
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
          cookieManager.setCookie(url, cookieValue, null);
        else
          cookieManager.setCookie(url, cookieValue);
      }

      if (cookieSyncMngr != null) {
        cookieSyncMngr.stopSync();
        cookieSyncMngr.sync();
      } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
        cookieManager.flush();
    }
    result.success(true);
  }

  public static void deleteAllCookies(final MethodChannel.Result result) {

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
      CookieSyncManager cookieSyncMngr = CookieSyncManager.createInstance(Shared.applicationContext);
      cookieSyncMngr.startSync();
      cookieManager.removeAllCookie();
      result.success(true);
      cookieSyncMngr.stopSync();
      cookieSyncMngr.sync();
    }
  }

  public static String getCookieExpirationDate(Long timestamp) {
    final SimpleDateFormat sdf = new SimpleDateFormat("EEE, d MMM yyyy hh:mm:ss z", Locale.US);
    sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
    return sdf.format(new Date(timestamp));
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
  }
}
