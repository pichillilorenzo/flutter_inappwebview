#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_SHOW_FILE_CHOOSER_RESPONSE_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_SHOW_FILE_CHOOSER_RESPONSE_H_

#include <flutter_linux/flutter_linux.h>

#include <optional>
#include <string>
#include <vector>

namespace drago_inappwebview_plugin {

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

}  // namespace drago_inappwebview_plugin

#endif  // DRAGO_INAPPWEBVIEW_PLUGIN_SHOW_FILE_CHOOSER_RESPONSE_H_
