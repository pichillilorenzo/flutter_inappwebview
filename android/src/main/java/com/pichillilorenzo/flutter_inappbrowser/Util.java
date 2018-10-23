package com.pichillilorenzo.flutter_inappbrowser;

import android.content.res.AssetManager;

import java.io.IOException;
import java.io.InputStream;
import io.flutter.plugin.common.PluginRegistry;

public class Util {

  static final String LOG_TAG = "Util";
  public static final String ANDROID_ASSET_URL = "file:///android_asset/";

  public static String getUrlAsset(PluginRegistry.Registrar registrar, String assetFilePath) throws IOException {
    String key = registrar.lookupKeyForAsset(assetFilePath);
    AssetManager mg = registrar.activeContext().getResources().getAssets();
    InputStream is = null;
    IOException e = null;

    try {
      is = mg.open(key);
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

}
