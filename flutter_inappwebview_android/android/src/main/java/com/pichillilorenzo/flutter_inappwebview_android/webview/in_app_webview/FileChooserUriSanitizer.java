package com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview;

import java.io.File;
import java.io.IOException;

final class FileChooserUriSanitizer {
  private FileChooserUriSanitizer() {}

  /** Returns whether a file-picker path could expose private application data. */
  static boolean isUnsafeFilePath(String path, String dataDir) {
    if (path == null || dataDir == null) {
      return true;
    }

    final String normalizedPath;
    final String normalizedDataDir;
    try {
      normalizedPath = new File(path).getCanonicalPath();
      normalizedDataDir = new File(dataDir).getCanonicalPath();
    } catch (IOException ignored) {
      return true;
    }

    return isSameOrDescendant(normalizedPath, normalizedDataDir)
            || isSameOrDescendant(normalizedPath, "/data");
  }

  private static boolean isSameOrDescendant(String path, String directory) {
    final String prefix = directory.endsWith(File.separator)
            ? directory
            : directory + File.separator;
    return path.equals(directory) || path.startsWith(prefix);
  }
}
