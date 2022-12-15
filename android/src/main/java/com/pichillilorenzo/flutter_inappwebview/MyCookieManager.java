package com.pichillilorenzo.flutter_inappwebview;

import android.os.Build;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.ValueCallback;

import androidx.annotation.Nullable;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MyCookieManager implements MethodChannel.MethodCallHandler {

  static final String LOG_TAG = "MyCookieManager";

  public MethodChannel channel;
  public static CookieManager cookieManager;
  @Nullable
  public InAppWebViewFlutterPlugin plugin;

  public MyCookieManager(final InAppWebViewFlutterPlugin plugin) {
    this.plugin = plugin;
    channel = new MethodChannel(plugin.messenger, "com.pichillilorenzo/flutter_inappwebview_cookiemanager");
    channel.setMethodCallHandler(this);
  }

  public static void init() {
    if (cookieManager == null) {
      cookieManager = getCookieManager();
    }
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    init();

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
          setCookie(url,
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
        result.success(getCookies((String) call.argument("url")));
        break;
      case "deleteCookie":
        {
          String url = (String) call.argument("url");
          String name = (String) call.argument("name");
          String domain = (String) call.argument("domain");
          String path = (String) call.argument("path");
          deleteCookie(url, name, domain, path, result);
        }
        break;
      case "deleteCookies":
        {
          String url = (String) call.argument("url");
          String domain = (String) call.argument("domain");
          String path = (String) call.argument("path");
          deleteCookies(url, domain, path, result);
        }
        break;
      case "deleteAllCookies":
        deleteAllCookies(result);
        break;
      default:
        result.notImplemented();
    }
  }

  /**
   * Instantiating CookieManager will load the Chromium task taking a 100ish ms so we do it lazily
   * to make sure it's done on a background thread as needed.
   *
   * https://github.com/facebook/react-native/blob/1903f6680d9750e244d97c3cd4a9f755a9a47c61/ReactAndroid/src/main/java/com/facebook/react/modules/network/ForwardingCookieHandler.java#L132
   */
  static private @Nullable CookieManager getCookieManager() {
    if (cookieManager == null) {
      try {
        cookieManager = CookieManager.getInstance();
      } catch (IllegalArgumentException ex) {
        // https://bugs.chromium.org/p/chromium/issues/detail?id=559720
        return null;
      } catch (Exception exception) {
        String message = exception.getMessage();
        // We cannot catch MissingWebViewPackageException as it is in a private / system API
        // class. This validates the exception's message to ensure we are only handling this
        // specific exception.
        // https://android.googlesource.com/platform/frameworks/base/+/master/core/java/android/webkit/WebViewFactory.java#348
        if (message != null
                && exception
                .getClass()
                .getCanonicalName()
                .equals("android.webkit.WebViewFactory.MissingWebViewPackageException")) {
          return null;
        } else {
          throw exception;
        }
      }
    }

    return cookieManager;
  }

  public void setCookie(String url,
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
    cookieManager = getCookieManager();
    if (cookieManager == null) return;

    String cookieValue = name + "=" + value + "; Path=" + path;

    if (domain != null)
      cookieValue += "; Domain=" + domain;

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
    else if (plugin != null) {
      CookieSyncManager cookieSyncMngr = CookieSyncManager.createInstance(plugin.applicationContext);
      cookieSyncMngr.startSync();
      cookieManager.setCookie(url, cookieValue);
      result.success(true);
      cookieSyncMngr.stopSync();
      cookieSyncMngr.sync();
    } else {
      cookieManager.setCookie(url, cookieValue);
      result.success(true);
    }
  }

  public List<Map<String, Object>> getCookies(final String url) {

    final List<Map<String, Object>> cookieListMap = new ArrayList<>();

    cookieManager = getCookieManager();
    if (cookieManager == null) return cookieListMap;

    String cookiesString = cookieManager.getCookie(url);

    if (cookiesString != null) {
      String[] cookies = cookiesString.split(";");
      for (String cookie : cookies) {
        String[] nameValue = cookie.split("=", 2);
        String name = nameValue[0].trim();
        String value = (nameValue.length > 1) ? nameValue[1].trim() : "";
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

  public void deleteCookie(String url, String name, String domain, String path, final MethodChannel.Result result) {
    cookieManager = getCookieManager();
    if (cookieManager == null) return;

    String cookieValue = name + "=; Path=" + path + "; Max-Age=-1";

    if (domain != null)
      cookieValue += "; Domain=" + domain;

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
    else if (plugin != null) {
      CookieSyncManager cookieSyncMngr = CookieSyncManager.createInstance(plugin.applicationContext);
      cookieSyncMngr.startSync();
      cookieManager.setCookie(url, cookieValue);
      result.success(true);
      cookieSyncMngr.stopSync();
      cookieSyncMngr.sync();
    } else {
      cookieManager.setCookie(url, cookieValue);
      result.success(true);
    }
  }

  public void deleteCookies(String url, String domain, String path, final MethodChannel.Result result) {
    cookieManager = getCookieManager();
    if (cookieManager == null) return;

    CookieSyncManager cookieSyncMngr = null;

    String cookiesString = cookieManager.getCookie(url);
    if (cookiesString != null) {

      if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP && plugin != null) {
        cookieSyncMngr = CookieSyncManager.createInstance(plugin.applicationContext);
        cookieSyncMngr.startSync();
      }

      String[] cookies = cookiesString.split(";");
      for (String cookie : cookies) {
        String[] nameValue = cookie.split("=", 2);
        String name = nameValue[0].trim();

        String cookieValue = name + "=; Path=" + path + "; Max-Age=-1";

        if (domain != null)
          cookieValue += "; Domain=" + domain;

        cookieValue += ";";

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

  public void deleteAllCookies(final MethodChannel.Result result) {
    cookieManager = getCookieManager();
    if (cookieManager == null) return;

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      cookieManager.removeAllCookies(new ValueCallback<Boolean>() {
        @Override
        public void onReceiveValue(Boolean aBoolean) {
          result.success(true);
        }
      });
      cookieManager.flush();
    }
    else if (plugin != null) {
      CookieSyncManager cookieSyncMngr = CookieSyncManager.createInstance(plugin.applicationContext);
      cookieSyncMngr.startSync();
      cookieManager.removeAllCookie();
      result.success(true);
      cookieSyncMngr.stopSync();
      cookieSyncMngr.sync();
    } else {
      cookieManager.removeAllCookie();
      result.success(true);
    }
  }

  public static String getCookieExpirationDate(Long timestamp) {
    final SimpleDateFormat sdf = new SimpleDateFormat("EEE, dd MMM yyyy hh:mm:ss z", Locale.US);
    sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
    return sdf.format(new Date(timestamp));
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
    plugin = null;
  }
}
