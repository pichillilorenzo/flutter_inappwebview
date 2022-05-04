package com.pichillilorenzo.flutter_inappwebview.types;

import androidx.annotation.Nullable;

import io.flutter.plugin.common.MethodChannel;

public interface IChannelDelegate extends MethodChannel.MethodCallHandler {
  @Nullable
  MethodChannel getChannel();
  void dispose();
}
