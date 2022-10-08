package com.pichillilorenzo.flutter_inappwebview.find_interaction;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pichillilorenzo.flutter_inappwebview.types.ChannelDelegateImpl;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class FindInteractionChannelDelegate extends ChannelDelegateImpl {
  @Nullable
  private FindInteractionController findInteractionController;

  public FindInteractionChannelDelegate(@NonNull FindInteractionController findInteractionController, @NonNull MethodChannel channel) {
    super(channel);
    this.findInteractionController = findInteractionController;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final MethodChannel.Result result) {
    switch (call.method) {
      case "findAllAsync":
        if (findInteractionController != null && findInteractionController.webView != null) {
          String find = (String) call.argument("find");
          findInteractionController.webView.findAllAsync(find);
        }
        result.success(true);
        break;
      case "findNext":
        if (findInteractionController != null && findInteractionController.webView != null) {
          Boolean forward = (Boolean) call.argument("forward");
          findInteractionController.webView.findNext(forward);
        }
        result.success(true);
        break;
      case "clearMatches":
        if (findInteractionController != null && findInteractionController.webView != null) {
          findInteractionController.webView.clearMatches();
        }
        result.success(true);
        break;
      default:
        result.notImplemented();
    }
  }

  public void onFindResultReceived(int activeMatchOrdinal, int numberOfMatches, boolean isDoneCounting) {
    MethodChannel channel = getChannel();
    if (channel == null) return;
    Map<String, Object> obj = new HashMap<>();
    obj.put("activeMatchOrdinal", activeMatchOrdinal);
    obj.put("numberOfMatches", numberOfMatches);
    obj.put("isDoneCounting", isDoneCounting);
    channel.invokeMethod("onFindResultReceived", obj);
  }

  @Override
  public void dispose() {
    super.dispose();
    findInteractionController = null;
  }
}
