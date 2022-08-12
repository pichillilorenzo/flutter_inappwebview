package com.pichillilorenzo.flutter_inappwebview;

import android.content.res.AssetManager;
import android.net.http.SslCertificate;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.Parcelable;
import android.util.Log;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.security.Key;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

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

  public static String getUrlAsset(String assetFilePath) throws IOException {
    String key = (Shared.registrar != null) ? Shared.registrar.lookupKeyForAsset(assetFilePath) : Shared.flutterAssets.getAssetFilePathByName(assetFilePath);
    InputStream is = null;
    IOException e = null;

    try {
      is = getFileAsset(assetFilePath);
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

  public static InputStream getFileAsset(String assetFilePath) throws IOException {
    String key = (Shared.registrar != null) ? Shared.registrar.lookupKeyForAsset(assetFilePath) : Shared.flutterAssets.getAssetFilePathByName(assetFilePath);
    AssetManager mg = Shared.applicationContext.getResources().getAssets();
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

  public static PrivateKeyAndCertificates loadPrivateKeyAndCertificate(String certificatePath, String certificatePassword, String keyStoreType) {

    PrivateKeyAndCertificates privateKeyAndCertificates = null;

    try {
      InputStream certificateFileStream = getFileAsset(certificatePath);

      KeyStore keyStore = KeyStore.getInstance(keyStoreType);
      keyStore.load(certificateFileStream, certificatePassword != null ? certificatePassword.toCharArray() : null);

      Enumeration<String> aliases = keyStore.aliases();
      String alias = aliases.nextElement();

      Key key = keyStore.getKey(alias, certificatePassword.toCharArray());
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

  public static OkHttpClient getUnsafeOkHttpClient() {
    try {
      // Create a trust manager that does not validate certificate chains
      final TrustManager[] trustAllCerts = new TrustManager[] {
              new X509TrustManager() {
                @Override
                public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException {
                }

                @Override
                public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType) throws CertificateException {
                }

                @Override
                public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                  return new java.security.cert.X509Certificate[]{};
                }
              }
      };

      // Install the all-trusting trust manager
      final SSLContext sslContext = SSLContext.getInstance("SSL");
      sslContext.init(null, trustAllCerts, new java.security.SecureRandom());
      // Create an ssl socket factory with our all-trusting manager
      final SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();

      OkHttpClient.Builder builder = new OkHttpClient.Builder();
      builder.sslSocketFactory(sslSocketFactory, (X509TrustManager)trustAllCerts[0]);
      builder.hostnameVerifier(new HostnameVerifier() {
        @Override
        public boolean verify(String hostname, SSLSession session) {
          return true;
        }
      });

      OkHttpClient okHttpClient = builder
              .connectTimeout(15, TimeUnit.SECONDS)
              .writeTimeout(15, TimeUnit.SECONDS)
              .readTimeout(15, TimeUnit.SECONDS)
              .build();
      return okHttpClient;
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
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
}
