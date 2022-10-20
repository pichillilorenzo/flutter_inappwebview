package com.pichillilorenzo.flutter_inappwebview;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Insets;
import android.graphics.Rect;
import android.net.http.SslCertificate;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.WindowInsets;
import android.view.WindowManager;
import android.view.WindowMetrics;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.pichillilorenzo.flutter_inappwebview.types.Size2D;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.security.Key;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import io.flutter.plugin.common.MethodChannel;
import okhttp3.OkHttpClient;

public class Util {

  static final String LOG_TAG = "Util";
  public static final String ANDROID_ASSET_URL = "file:///android_asset/";

  private Util() {}

  public static String getUrlAsset(InAppWebViewFlutterPlugin plugin, String assetFilePath) throws IOException {
    String key = (plugin.registrar != null) ? plugin.registrar.lookupKeyForAsset(assetFilePath) : plugin.flutterAssets.getAssetFilePathByName(assetFilePath);
    InputStream is = null;
    IOException e = null;

    try {
      is = getFileAsset(plugin, assetFilePath);
    } catch (IOException ex) {
      e = ex;
    } finally {
      if (is != null) {
        try {
          is.close();
        } catch (IOException ex) {
          e = ex;
        }
      }
    }
    if (e != null) {
      throw e;
    }

    return ANDROID_ASSET_URL + key;
  }

  public static InputStream getFileAsset(InAppWebViewFlutterPlugin plugin, String assetFilePath) throws IOException {
    String key = (plugin.registrar != null) ? plugin.registrar.lookupKeyForAsset(assetFilePath) : plugin.flutterAssets.getAssetFilePathByName(assetFilePath);
    AssetManager mg = plugin.applicationContext.getResources().getAssets();
    return mg.open(key);
  }

  public static WaitFlutterResult invokeMethodAndWait(final MethodChannel channel, final String method, final Object arguments) throws InterruptedException {
    final CountDownLatch latch = new CountDownLatch(1);

    final Map<String, Object> flutterResultMap = new HashMap<>();
    flutterResultMap.put("result", null);
    flutterResultMap.put("error", null);

    Handler handler = new Handler(Looper.getMainLooper());
    handler.post(new Runnable() {
      @Override
      public void run() {
        channel.invokeMethod(method, arguments, new MethodChannel.Result() {
          @Override
          public void success(Object result) {
            flutterResultMap.put("result", result);
            latch.countDown();
          }

          @Override
          public void error(String s, String s1, Object o) {
            flutterResultMap.put("error", "ERROR: " + s + " " + s1);
            flutterResultMap.put("result", o);
            latch.countDown();
          }

          @Override
          public void notImplemented() {
            latch.countDown();
          }
        });
      }
    });

    latch.await();

    return new WaitFlutterResult(flutterResultMap.get("result"), (String) flutterResultMap.get("error"));
  }

  public static class WaitFlutterResult {
    public Object result;
    public String error;

    public WaitFlutterResult(Object r, String e) {
      result = r;
      error = e;
    }
  }

  public static PrivateKeyAndCertificates loadPrivateKeyAndCertificate(InAppWebViewFlutterPlugin plugin, String certificatePath, String certificatePassword, String keyStoreType) {

    PrivateKeyAndCertificates privateKeyAndCertificates = null;
    InputStream certificateFileStream = null;

    try {
      certificateFileStream = getFileAsset(plugin, certificatePath);
    } catch (IOException ignored) {}

    try {
      if (certificateFileStream == null) {
        certificateFileStream = new FileInputStream(certificatePath);
      }
      KeyStore keyStore = KeyStore.getInstance(keyStoreType);
      keyStore.load(certificateFileStream, (certificatePassword != null ? certificatePassword : "").toCharArray());

      Enumeration<String> aliases = keyStore.aliases();
      String alias = aliases.nextElement();

      Key key = keyStore.getKey(alias, (certificatePassword != null ? certificatePassword : "").toCharArray());
      if (key instanceof PrivateKey) {
        PrivateKey privateKey = (PrivateKey)key;
        Certificate cert = keyStore.getCertificate(alias);
        X509Certificate[] certificates = new X509Certificate[1];
        certificates[0] = (X509Certificate)cert;
        privateKeyAndCertificates = new PrivateKeyAndCertificates(privateKey, certificates);
      }
      certificateFileStream.close();
    } catch (Exception e) {
      e.printStackTrace();
      Log.e(LOG_TAG, e.getMessage());
    } finally {
      if (certificateFileStream != null) {
        try {
          certificateFileStream.close();
        } catch (IOException ex) {
          ex.printStackTrace();
          Log.e(LOG_TAG, ex.getMessage());
        }
      }
    }

    return privateKeyAndCertificates;
  }

  public static class PrivateKeyAndCertificates {

    public X509Certificate[] certificates;
    public PrivateKey privateKey;

    public PrivateKeyAndCertificates(PrivateKey privateKey, X509Certificate[] certificates) {
      this.privateKey = privateKey;
      this.certificates = certificates;
    }
  }

  public static OkHttpClient getBasicOkHttpClient() {
    return new OkHttpClient.Builder()
            .connectTimeout(15, TimeUnit.SECONDS)
            .writeTimeout(15, TimeUnit.SECONDS)
            .readTimeout(15, TimeUnit.SECONDS)
            .build();
  }

  /**
   * SslCertificate class does not has a public getter for the underlying
   * X509Certificate, we can only do this by hack. This only works for andorid 4.0+
   * https://groups.google.com/forum/#!topic/android-developers/eAPJ6b7mrmg
   */
  public static X509Certificate getX509CertFromSslCertHack(SslCertificate sslCert) {
    X509Certificate x509Certificate = null;

    Bundle bundle = SslCertificate.saveState(sslCert);
    byte[] bytes = bundle.getByteArray("x509-certificate");

    if (bytes == null) {
      x509Certificate = null;
    } else {
      try {
        CertificateFactory certFactory = CertificateFactory.getInstance("X.509");
        Certificate cert = certFactory.generateCertificate(new ByteArrayInputStream(bytes));
        x509Certificate = (X509Certificate) cert;
      } catch (CertificateException e) {
        x509Certificate = null;
      }
    }

    return x509Certificate;
  }

  @RequiresApi(api = Build.VERSION_CODES.KITKAT)
  public static String JSONStringify(@Nullable Object value) {
    if (value == null) {
      return "null";
    }
    if (value instanceof Map) {
      return new JSONObject((Map<String, Object>) value).toString();
    } else if (value instanceof List) {
      return new JSONArray((List<Object>) value).toString();
    } else if (value instanceof String) {
      return JSONObject.quote((String) value);
    } else {
      return JSONObject.wrap(value).toString();
    }
  }

  public static boolean objEquals(@Nullable Object a, @Nullable Object b) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      return Objects.equals(a, b);
    }
    return (a == b) || (a != null && a.equals(b));
  }

  public static String replaceAll(String s, String oldString, String newString) {
    return TextUtils.join(newString, s.split(Pattern.quote(oldString)));
  }

  public static void log(String tag, String message) {
    // Split by line, then ensure each line can fit into Log's maximum length.
    for (int i = 0, length = message.length(); i < length; i++) {
      int newline = message.indexOf('\n', i);
      newline = newline != -1 ? newline : length;
      do {
        int end = Math.min(newline, i + 4000);
        Log.d(tag, message.substring(i, end));
        i = end;
      } while (i < newline);
    }
  }

  public static float getPixelDensity(Context context) {
    return context.getResources().getDisplayMetrics().density;
  }

  public static Size2D getFullscreenSize(Context context) {
    Size2D fullscreenSize = new Size2D(-1, -1);
    WindowManager wm = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
    if (wm != null) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        final WindowMetrics metrics = wm.getCurrentWindowMetrics();
        // Gets all excluding insets
        final WindowInsets windowInsets = metrics.getWindowInsets();
        Insets insets = windowInsets.getInsetsIgnoringVisibility(WindowInsets.Type.navigationBars()
                | WindowInsets.Type.displayCutout());
        int insetsWidth = insets.right + insets.left;
        int insetsHeight = insets.top + insets.bottom;
        final Rect bounds = metrics.getBounds();
        fullscreenSize.setWidth(bounds.width() - insetsWidth);
        fullscreenSize.setHeight(bounds.height() - insetsHeight);
      } else {
        DisplayMetrics displayMetrics = new DisplayMetrics();
        wm.getDefaultDisplay().getMetrics(displayMetrics);
        fullscreenSize.setWidth(displayMetrics.widthPixels);
        fullscreenSize.setHeight(displayMetrics.heightPixels);
      }
    }
    return fullscreenSize;
  }

  public static boolean isClass(String className) {
    try  {
      Class.forName(className);
      return true;
    }  catch (ClassNotFoundException e) {
      return false;
    }
  }
  
  public static boolean isIPv6(String address) {
    try {
      Inet6Address.getByName(address);
    } catch (UnknownHostException e) {
      return false;
    }
    return true;
  }

  public static String normalizeIPv6(String address) throws Exception {
    if (!Util.isIPv6(address)) {
      throw new Exception("Invalid address: " + address);
    }
    return InetAddress.getByName(address).getCanonicalHostName();
  }

  public static Object getOrDefault(Map map, String key, Object defaultValue) {
    return map.containsKey(key) ? map.get(key) : defaultValue;
  }

  @Nullable
  public static <O> Object invokeMethodIfExists(final O o, final String methodName, Object... args) {
    Method[] methods = o.getClass().getMethods();
    for (Method method : methods) {
      if (method.getName().equals(methodName)) {
        try {
          return method.invoke(o, args);
        } catch (IllegalAccessException e) {
          return null;
        } catch (InvocationTargetException e) {
          return null;
        }
      }
    }
    return null;
  }
}
