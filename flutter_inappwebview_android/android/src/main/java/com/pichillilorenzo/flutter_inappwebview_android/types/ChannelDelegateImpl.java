package com.pichillilorenzo.flutter_inappwebview_android.types;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview_android.Util;

import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.CancellationException;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ChannelDelegateImpl implements IChannelDelegate {
  @Nullable
  private MethodChannel channel;
  private final Set<SyncBaseCallbackResultImpl<?>> pendingCallbacks = new HashSet<>();

  public ChannelDelegateImpl(@NonNull MethodChannel channel) {
    this.channel = channel;
    this.channel.setMethodCallHandler(this);
  }
  
  @Override
  @Nullable
  public MethodChannel getChannel() {
    return channel;
  }

  @Nullable
  protected <T> T invokeMethodAndWaitResult(@NonNull String method, @Nullable Object arguments,
                                            @NonNull SyncBaseCallbackResultImpl<T> callback) throws InterruptedException {
    final MethodChannel currentChannel;
    synchronized (pendingCallbacks) {
      if (channel == null) {
        throw new CancellationException("Channel has been disposed");
      }
      currentChannel = channel;
      pendingCallbacks.add(callback);
    }
    try {
      return Util.invokeMethodAndWaitResult(currentChannel, method, arguments, callback);
    } finally {
      synchronized (pendingCallbacks) {
        pendingCallbacks.remove(callback);
      }
    }
  }

  @CallSuper
  public void dispose() {
    final Set<SyncBaseCallbackResultImpl<?>> callbacks;
    synchronized (pendingCallbacks) {
      if (channel != null) {
        channel.setMethodCallHandler(null);
        channel = null;
      }
      callbacks = new HashSet<>(pendingCallbacks);
      pendingCallbacks.clear();
    }
    for (SyncBaseCallbackResultImpl<?> callback : callbacks) {
      callback.cancel();
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
    
  }
}
