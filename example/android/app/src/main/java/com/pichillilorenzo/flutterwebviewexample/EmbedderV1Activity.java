package com.pichillilorenzo.flutterwebviewexample;

import android.os.Bundle;
import dev.flutter.plugins.e2e.E2EPlugin;
import io.flutter.app.FlutterActivity;
import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;

public class EmbedderV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    E2EPlugin.registerWith(registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));
    InAppWebViewFlutterPlugin.registerWith(
            registrarFor("com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin"));
  }
}