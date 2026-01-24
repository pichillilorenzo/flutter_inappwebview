#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_SHOW_FILE_CHOOSER_RESPONSE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_SHOW_FILE_CHOOSER_RESPONSE_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>
#include <vector>

namespace flutter_inappwebview_plugin {

class ShowFileChooserResponse {
 public:
  bool handledByClient;
  std::optional<std::vector<std::string>> filePaths;

  ShowFileChooserResponse();
  ShowFileChooserResponse(bool handledByClient,
                          std::optional<std::vector<std::string>> filePaths);
  ~ShowFileChooserResponse() = default;

  static ShowFileChooserResponse fromFlValue(FlValue* value);

  FlValue* toFlValue() const;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_SHOW_FILE_CHOOSER_RESPONSE_H_
