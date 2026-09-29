#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_CONTAINER_MANAGER_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_CONTAINER_MANAGER_H_

#include <flutter_linux/flutter_linux.h>

#include "types/channel_delegate.h"

namespace flutter_inappwebview_plugin {

class PluginInstance;

// MethodChannel handler for the per-WebView container controller. Wraps
// the filesystem under <XDG_DATA_HOME>/flutter_inappwebview/containers/
// and <XDG_CACHE_HOME>/flutter_inappwebview/containers/, since WPE
// WebKit's WebKitNetworkSession (the runtime side of container join)
// is keyed off these directories rather than a registry maintained by
// the platform.
//
// Methods:
//   - getAllContainerNames: lists subdirectories of the data root
//   - hasContainer:         checks for one such subdirectory
//   - deleteContainer:      removes both the data and cache subtrees
class ContainerManager : public ChannelDelegate {
 public:
  static constexpr const char* METHOD_CHANNEL_NAME =
      "com.pichillilorenzo/flutter_inappwebview_containercontroller";

  ContainerManager(PluginInstance* plugin);
  ~ContainerManager() override;

  PluginInstance* plugin() const { return plugin_; }

  void HandleMethodCall(FlMethodCall* method_call) override;

 private:
  PluginInstance* plugin_ = nullptr;
};

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_CONTAINER_MANAGER_H_
