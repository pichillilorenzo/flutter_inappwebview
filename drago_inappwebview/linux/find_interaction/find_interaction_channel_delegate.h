#ifndef DRAGO_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CHANNEL_DELEGATE_H_
#define DRAGO_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CHANNEL_DELEGATE_H_

#include <flutter_linux/flutter_linux.h>

#include <cstdint>
#include <string>

#include "../types/channel_delegate.h"

namespace drago_inappwebview_plugin {

class FindInteractionController;

class FindInteractionChannelDelegate : public ChannelDelegate {
 public:
  FindInteractionChannelDelegate(FindInteractionController* controller,
                                 FlBinaryMessenger* messenger,
                                 const std::string& channelName);
  ~FindInteractionChannelDelegate() override;

  void HandleMethodCall(FlMethodCall* method_call) override;

  void onFindResultReceived(int32_t activeMatchOrdinal,
                            int32_t numberOfMatches,
                            bool isDoneCounting) const;

 private:
  FindInteractionController* findInteractionController_;
};

}  // namespace drago_inappwebview_plugin

#endif  // DRAGO_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CHANNEL_DELEGATE_H_
