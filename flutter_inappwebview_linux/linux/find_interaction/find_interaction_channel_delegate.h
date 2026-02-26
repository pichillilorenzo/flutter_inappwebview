#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CHANNEL_DELEGATE_H_

#include <flutter_linux/flutter_linux.h>

#include <cstdint>
#include <string>

#include "../types/channel_delegate.h"

namespace flutter_inappwebview_plugin {

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

}  // namespace flutter_inappwebview_plugin

#endif  // FLUTTER_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CHANNEL_DELEGATE_H_
