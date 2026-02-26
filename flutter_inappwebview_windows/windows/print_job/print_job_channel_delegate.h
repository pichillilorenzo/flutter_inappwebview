#ifndef FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_JOB_CHANNEL_DELEGATE_H_
#define FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_JOB_CHANNEL_DELEGATE_H_

#include <flutter/binary_messenger.h>
#include <flutter/method_call.h>
#include <flutter/method_result.h>

#include <optional>
#include <string>

#include "../types/channel_delegate.h"

namespace flutter_inappwebview_plugin
{
  class PrintJobController;

  class PrintJobChannelDelegate : public ChannelDelegate
  {
  public:
    PrintJobChannelDelegate(PrintJobController* printJobController,
      flutter::BinaryMessenger* messenger, const std::string& channelName);
    ~PrintJobChannelDelegate() override;

    void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) override;

    void onComplete(const bool completed, const std::optional<std::string>& error) const;

    void dispose();

  private:
    PrintJobController* printJobController_ = nullptr;
    bool disposed_ = false;
  };
}

#endif //FLUTTER_INAPPWEBVIEW_PLUGIN_PRINT_JOB_CHANNEL_DELEGATE_H_
