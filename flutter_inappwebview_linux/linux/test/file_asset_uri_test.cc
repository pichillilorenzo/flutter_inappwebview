#include <cassert>
#include <filesystem>
#include <string>
#include <glib.h>

static void verifyRoundTrip(const std::filesystem::path& path, const std::string& expected) {
  GError* error = nullptr;
  gchar* uri = g_filename_to_uri(path.c_str(), nullptr, &error);
  assert(error == nullptr && uri != nullptr);
  const std::string encoded(uri);
  assert(encoded.rfind("file:///", 0) == 0);
  assert(encoded.find(expected) != std::string::npos);

  gchar* restored = g_filename_from_uri(uri, nullptr, &error);
  assert(error == nullptr && restored != nullptr);
  assert(std::string(restored) == path.string());

  g_free(restored);
  g_free(uri);
}

int main() {
  const auto root = std::filesystem::temp_directory_path();
  verifyRoundTrip(root / "Otzaria books" / "chapter one.html", "%20");
  verifyRoundTrip(root / "אוצריא" / "ספרי קודש.html", "%D7");
  verifyRoundTrip(root / "books" / "a#b?c%d.html", "%23b%3Fc%25");
  verifyRoundTrip(root / "space path" / "book+notes.html", "%20");
  // A relative filename is rejected by GLib rather than forming a fake URI.
  GError* error = nullptr;
  gchar* relative = g_filename_to_uri("not/absolute.html", nullptr, &error);
  assert(relative == nullptr && error != nullptr);
  g_error_free(error);
}
