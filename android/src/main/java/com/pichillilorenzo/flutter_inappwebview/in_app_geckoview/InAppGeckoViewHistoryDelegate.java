package com.pichillilorenzo.flutter_inappwebview.in_app_geckoview;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.GeckoSession;

import java.util.HashSet;

import io.flutter.plugin.common.MethodChannel;

public class InAppGeckoViewHistoryDelegate implements GeckoSession.HistoryDelegate {

  protected static final String LOG_TAG = "IAGeckoViewHistDelegate";
  private final MethodChannel channel;
  @Nullable
  private InAppGeckoView inAppGeckoView;
  private final HashSet<String> visitedURLs;

  public InAppGeckoViewHistoryDelegate(@NonNull InAppGeckoView inAppGeckoView, MethodChannel channel) {
    super();

    this.inAppGeckoView = inAppGeckoView;
    this.channel = channel;
    visitedURLs = new HashSet<String>();
  }

  @Nullable
  @Override
  public GeckoResult<Boolean> onVisited(@NonNull GeckoSession session, @NonNull String url, @Nullable String lastVisitedURL, int flags) {
    // TODO: add Flutter event with flag to enable it or use default native implementation
    visitedURLs.add(url);
    return GeckoResult.fromValue(true);
  }

  @Override
  public void onHistoryStateChange(@NonNull GeckoSession session, @NonNull HistoryList historyList) {
    // TODO: add Flutter event
    if (inAppGeckoView != null) {
      inAppGeckoView.historyList = historyList;
    }
  }

  @Nullable
  @Override
  public GeckoResult<boolean[]> getVisited(@NonNull GeckoSession session, @NonNull String[] urls) {
    boolean[] visited = new boolean[urls.length];
    for (int i = 0; i < urls.length; i++) {
      visited[i] = visitedURLs.contains(urls[i]);
    }
    return GeckoResult.fromValue(visited);
  }

  public void dispose() {
    if (inAppGeckoView != null) {
      inAppGeckoView = null;
    }
  }
}
