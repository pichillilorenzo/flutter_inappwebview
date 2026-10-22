package android.print;

import android.os.CancellationSignal;
import android.os.ParcelFileDescriptor;

import java.io.File;

/**
 * Lives in package android.print because PrintDocumentAdapter.LayoutResultCallback and
 * WriteResultCallback have package-private constructors. Writes a WebView print adapter's
 * output to a file without needing an Activity or the print spooler.
 */
public class DragoPdfPrinter {
  public interface Callback {
    void onDone(boolean success);
  }

  public static void print(final PrintDocumentAdapter adapter, final PrintAttributes attributes,
                           final File outFile, final Callback callback) {
    adapter.onStart();
    adapter.onLayout(null, attributes, new CancellationSignal(), new PrintDocumentAdapter.LayoutResultCallback() {
      @Override
      public void onLayoutFinished(PrintDocumentInfo info, boolean changed) {
        final ParcelFileDescriptor pfd;
        try {
          pfd = ParcelFileDescriptor.open(outFile, ParcelFileDescriptor.MODE_CREATE
                  | ParcelFileDescriptor.MODE_TRUNCATE | ParcelFileDescriptor.MODE_READ_WRITE);
        } catch (Exception e) {
          finish(adapter, callback, false);
          return;
        }
        adapter.onWrite(new PageRange[]{PageRange.ALL_PAGES}, pfd, new CancellationSignal(),
                new PrintDocumentAdapter.WriteResultCallback() {
                  @Override
                  public void onWriteFinished(PageRange[] pages) {
                    close(pfd);
                    finish(adapter, callback, pages != null && pages.length > 0);
                  }

                  @Override
                  public void onWriteFailed(CharSequence error) {
                    close(pfd);
                    finish(adapter, callback, false);
                  }

                  @Override
                  public void onWriteCancelled() {
                    close(pfd);
                    finish(adapter, callback, false);
                  }
                });
      }

      @Override
      public void onLayoutFailed(CharSequence error) {
        finish(adapter, callback, false);
      }

      @Override
      public void onLayoutCancelled() {
        finish(adapter, callback, false);
      }
    }, null);
  }

  private static void close(ParcelFileDescriptor pfd) {
    try {
      pfd.close();
    } catch (Exception ignored) {
    }
  }

  private static void finish(PrintDocumentAdapter adapter, Callback callback, boolean ok) {
    try {
      adapter.onFinish();
    } catch (Exception ignored) {
    }
    callback.onDone(ok);
  }
}
