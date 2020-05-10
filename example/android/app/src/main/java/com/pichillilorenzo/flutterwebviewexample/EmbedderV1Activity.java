package com.pichillilorenzo.flutterwebviewexample;

import android.os.Bundle;
import android.view.ActionMode;
import android.view.Menu;

import io.flutter.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class EmbedderV1Activity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
  }
}