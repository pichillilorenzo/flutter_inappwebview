import com.pichillilorenzo.flutter_inappwebview_android.service_worker.ServiceWorkerChannelDelegate;
import com.pichillilorenzo.flutter_inappwebview_android.types.ChannelDelegateImpl;
import com.pichillilorenzo.flutter_inappwebview_android.types.SyncBaseCallbackResultImpl;
import com.pichillilorenzo.flutter_inappwebview_android.types.WebResourceRequestExt;
import com.pichillilorenzo.flutter_inappwebview_android.types.WebResourceResponseExt;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CancellationException;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

// Uses the real delegate, callback and wait helper with explicit platform doubles.
public class CallbackLifecycleTest {
  public static void main(String[] arguments) throws Exception {
    for (String reply : new String[] {"success", "null", "error", "notImplemented", "dispose"}) {
      checkReply(reply);
    }
    checkDisposeBeforeDispatch();
    checkReentrantDisposal();
  }

  private static void checkReply(String reply) throws Exception {
    AtomicReference<MethodChannel.Result> pending = new AtomicReference<>();
    CountDownLatch invoked = new CountDownLatch(1);
    MethodChannel channel = new MethodChannel(callback -> {
      pending.set(callback);
      invoked.countDown();
    });
    ServiceWorkerChannelDelegate delegate = new ServiceWorkerChannelDelegate(null, channel);
    ExecutorService worker = Executors.newSingleThreadExecutor();
    try {
      Future<WebResourceResponseExt> response = worker.submit(() -> delegate.shouldInterceptRequest(
          new WebResourceRequestExt("https://example.com/private", null, false, false, false, "GET")));
      require(invoked.await(1, TimeUnit.SECONDS), "Request was not invoked");
      if (reply.equals("dispose")) {
        delegate.dispose();
        try {
          response.get(1, TimeUnit.SECONDS);
          throw new AssertionError("Disposed request was not cancelled");
        } catch (ExecutionException error) {
          require(error.getCause() instanceof CancellationException, "Wrong cancellation error");
        }
        pending.get().success("invalid response that must not be decoded after disposal");
        pending.get().notImplemented();
        pending.get().error("late", "Late reply", null);
      } else {
        if (reply.equals("success")) {
          Map<String, Object> payload = new HashMap<>();
          payload.put("contentType", "text/plain");
          pending.get().success(payload);
        } else if (reply.equals("null")) {
          pending.get().success(null);
        } else if (reply.equals("error")) {
          pending.get().error("failed", "Request failed", null);
        } else {
          pending.get().notImplemented();
        }
        WebResourceResponseExt value = response.get(1, TimeUnit.SECONDS);
        require(reply.equals("success") ? value != null : value == null, "Reply changed");
        delegate.dispose();
        require(response.get(1, TimeUnit.SECONDS) == value, "Disposal replaced a completed reply");
        pending.get().success("invalid duplicate that must not replace a completed reply");
      }
      System.out.println("PASS: " + reply);
    } finally {
      delegate.dispose();
      if (pending.get() != null) pending.get().notImplemented();
      worker.shutdownNow();
      require(worker.awaitTermination(1, TimeUnit.SECONDS), "Worker leaked");
    }
  }

  private static void checkDisposeBeforeDispatch() throws Exception {
    AtomicReference<MethodChannel.Result> invoked = new AtomicReference<>();
    ServiceWorkerChannelDelegate delegate = new ServiceWorkerChannelDelegate(
        null, new MethodChannel(invoked::set));
    ExecutorService worker = Executors.newSingleThreadExecutor();
    android.os.Handler.paused = true;
    android.os.Handler.pending = null;
    try {
      Future<?> response = worker.submit(() -> delegate.shouldInterceptRequest(
          new WebResourceRequestExt("https://example.com/private", null, false, false, false, "GET")));
      long deadline = System.nanoTime() + TimeUnit.SECONDS.toNanos(1);
      while (android.os.Handler.pending == null && System.nanoTime() < deadline) Thread.yield();
      require(android.os.Handler.pending != null, "Request was not posted");
      delegate.dispose();
      expectCancelled(response);
      android.os.Handler.pending.run();
      require(invoked.get() == null, "Disposed request was dispatched to Dart");

      expectCancelled(worker.submit(() -> delegate.shouldInterceptRequest(
          new WebResourceRequestExt("https://example.com/new", null, false, false, false, "GET"))));
      System.out.println("PASS: dispose before dispatch and request after disposal");
    } finally {
      android.os.Handler.paused = false;
      delegate.dispose();
      worker.shutdownNow();
      require(worker.awaitTermination(1, TimeUnit.SECONDS), "Worker leaked");
    }
  }

  private static void checkReentrantDisposal() throws Exception {
    class Delegate extends ChannelDelegateImpl {
      Delegate(MethodChannel channel) { super(channel); }
      Object request(SyncBaseCallbackResultImpl<Object> callback) throws InterruptedException {
        return invokeMethodAndWaitResult("handle", null, callback);
      }
    }
    Delegate delegate = new Delegate(new MethodChannel(reply -> reply.success("response")));
    SyncBaseCallbackResultImpl<Object> callback = new SyncBaseCallbackResultImpl<>() {
      @Override public Object decodeResult(Object value) { return value; }
      @Override public boolean nonNullSuccess(Object value) {
        delegate.dispose();
        return true;
      }
      @Override public void defaultBehaviour(Object value) {
        throw new AssertionError("Cancelled callback ran a late default hook");
      }
    };
    ExecutorService worker = Executors.newSingleThreadExecutor();
    try {
      expectCancelled(worker.submit(() -> delegate.request(callback)));
      callback.notImplemented();
      callback.error("late", "Late reply", null);
      callback.success("late");
      System.out.println("PASS: reentrant disposal and suppressed late hooks");
    } finally {
      delegate.dispose();
      worker.shutdownNow();
      require(worker.awaitTermination(1, TimeUnit.SECONDS), "Worker leaked");
    }
  }

  private static void expectCancelled(Future<?> response) throws Exception {
    try {
      response.get(1, TimeUnit.SECONDS);
      throw new AssertionError("Disposed request was not cancelled");
    } catch (ExecutionException error) {
      require(error.getCause() instanceof CancellationException, "Wrong cancellation error");
    }
  }

  private static void require(boolean condition, String message) {
    if (!condition) throw new AssertionError(message);
  }
}
