package com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

public class FileChooserUriSanitizerTest {
  @Test
  public void rejectsPrivateDataPathsAndTraversal() {
    final String dataDir = "/data/user/0/example.app";

    assertTrue(FileChooserUriSanitizer.isUnsafeFilePath(dataDir, dataDir));
    assertTrue(FileChooserUriSanitizer.isUnsafeFilePath(dataDir + "/files/secret", dataDir));
    assertTrue(FileChooserUriSanitizer.isUnsafeFilePath(
            "/data/local/../user/0/example.app/files/secret", dataDir));
    assertTrue(FileChooserUriSanitizer.isUnsafeFilePath("/data", dataDir));
    assertTrue(FileChooserUriSanitizer.isUnsafeFilePath("/data/other.app/secret", dataDir));
  }

  @Test
  public void allowsExternalFilePaths() {
    assertFalse(FileChooserUriSanitizer.isUnsafeFilePath(
            "/storage/emulated/0/Download/document.pdf", "/data/user/0/example.app"));
  }

  @Test
  public void rejectsNullAndCanonicalizationFailure() {
    assertTrue(FileChooserUriSanitizer.isUnsafeFilePath(null, "/data/user/0/example.app"));
    assertTrue(FileChooserUriSanitizer.isUnsafeFilePath("/tmp/file", null));
    assertTrue(FileChooserUriSanitizer.isUnsafeFilePath(
            "\u0000", "/data/user/0/example.app"));
    assertTrue(FileChooserUriSanitizer.isUnsafeFilePath(
            "/tmp/file", "\u0000"));
  }

  @Test
  public void resolvesSymlinksIntoPrivateData() throws IOException {
    final Path root = Files.createTempDirectory("file-chooser-uri-test");
    final Path dataDir = Files.createDirectory(root.resolve("private"));
    final Path secret = Files.createFile(dataDir.resolve("secret"));
    final Path link = root.resolve("picked-file");
    try {
      Files.createSymbolicLink(link, secret);
      assertTrue(FileChooserUriSanitizer.isUnsafeFilePath(
              link.toString(), dataDir.toString()));
    } finally {
      Files.deleteIfExists(link);
      Files.deleteIfExists(secret);
      Files.deleteIfExists(dataDir);
      Files.deleteIfExists(root);
    }
  }
}
