#pragma once

#include <flutter/method_channel.h>

#include <memory>
#include <set>

#include "../flutter_inappwebview_windows_base_plugin.h"

namespace flutter_inappwebview_plugin
{
	class ChannelDelegate
	{
		using FlutterMethodChannel = std::shared_ptr<flutter::MethodChannel<flutter::EncodableValue>>;

	public:
		FlutterMethodChannel channel;
		flutter::BinaryMessenger* messenger;

		ChannelDelegate(flutter::BinaryMessenger* messenger, const std::string& name);
		~ChannelDelegate();

		virtual void HandleMethodCall(
			const flutter::MethodCall<flutter::EncodableValue>& method_call,
			std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
	};
}