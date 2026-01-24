#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CHANNEL_DELEGATE_H_

#include <flutter/method_channel.h>
#include <flutter/standard_message_codec.h>

#include <string>

#include "../types/channel_delegate.h"

namespace flutter_inappwebview_plugin
{
  class FindInteractionController;

  class FindInteractionChannelDelegate : public ChannelDelegate
  {
  public:
    FindInteractionChannelDelegate(FindInteractionController* findInteractionController,
      flutter::BinaryMessenger* messenger, const std::string& channelName);
    ~FindInteractionChannelDelegate() override;

    void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) override;

    void onFindResultReceived(const int32_t activeMatchOrdinal, const int32_t numberOfMatches,
      const bool isDoneCounting) const;

    void dispose();

  private:
    FindInteractionController* findInteractionController_;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_FIND_INTERACTION_CHANNEL_DELEGATE_H_
