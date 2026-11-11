package com.pichillilorenzo.flutter_inappwebview_android.types;

import androidx.annotation.CallSuper;
import androidx.annotation.Nullable;

import java.util.concurrent.CountDownLatch;

public class SyncBaseCallbackResultImpl<T> extends BaseCallbackResultImpl<T> {
  final public CountDownLatch latch = new CountDownLatch(1);
  @Nullable
  public T result = null;
  private boolean cancelled;

  public synchronized void cancel() {
    if (latch.getCount() == 0) {
      return;
    }
    cancelled = true;
    latch.countDown();
  }

  public synchronized boolean isCancelled() {
    return cancelled;
  }

  @CallSuper
  @Override
  public synchronized void defaultBehaviour(@Nullable T result) {
    if (latch.getCount() == 0) {
      return;
    }
    latch.countDown();
  }

  @Override
  public synchronized void success(@Nullable Object obj) {
    if (latch.getCount() == 0) {
      return;
    }
    T result = decodeResult(obj);
    this.result = result;
    boolean shouldRunDefaultBehaviour;
    if (result == null) {
      shouldRunDefaultBehaviour = nullSuccess();
    } else {
      shouldRunDefaultBehaviour = nonNullSuccess(result);
    }
    if (latch.getCount() == 0) {
      return;
    }
    if (shouldRunDefaultBehaviour) {
      defaultBehaviour(result);
    } else {
      latch.countDown();
    }
  }
  
  @CallSuper
  @Override
  public synchronized void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
    if (latch.getCount() == 0) {
      return;
    }
    latch.countDown();
  }

  @CallSuper
  @Override
  public synchronized void notImplemented() {
    if (latch.getCount() == 0) {
      return;
    }
    defaultBehaviour(null);
  }
}
