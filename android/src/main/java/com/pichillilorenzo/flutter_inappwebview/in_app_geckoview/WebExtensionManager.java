package com.pichillilorenzo.flutter_inappwebview.in_app_geckoview;

import android.graphics.Bitmap;
import android.util.Log;
import android.util.LruCache;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.json.JSONException;
import org.json.JSONObject;
import org.mozilla.geckoview.AllowOrDeny;
import org.mozilla.geckoview.GeckoResult;
import org.mozilla.geckoview.GeckoRuntime;
import org.mozilla.geckoview.GeckoSession;
import org.mozilla.geckoview.Image;
import org.mozilla.geckoview.WebExtension;
import org.mozilla.geckoview.WebExtensionController;

import java.util.List;

public class WebExtensionManager implements WebExtension.SessionTabDelegate,
        WebExtension.MessageDelegate,
        WebExtension.PortDelegate,
        WebExtensionController.PromptDelegate,
        WebExtensionController.DebuggerDelegate {

  static final String LOG_TAG = "WebExtensionManager";
  
  public WebExtension extension;

  private LruCache<Image, Bitmap> mBitmapCache = new LruCache<>(5);
  private GeckoRuntime mRuntime;
  private WebExtension.Action mDefaultAction;

  @Nullable
  @Override
  public GeckoResult<AllowOrDeny> onInstallPrompt(final @NonNull WebExtension extension) {
    return GeckoResult.allow();
  }

  @Nullable
  @Override
  public GeckoResult<AllowOrDeny> onUpdatePrompt(@NonNull WebExtension currentlyInstalled,
                                                 @NonNull WebExtension updatedExtension,
                                                 @NonNull String[] newPermissions,
                                                 @NonNull String[] newOrigins) {
    return GeckoResult.allow();
  }

  @Override
  public void onExtensionListUpdated() {
    refreshExtensionList();
  }

//  // We only support either one browserAction or one pageAction
//  private void onAction(final WebExtension extension, final GeckoSession session,
//                        final WebExtension.Action action) {
//    WebExtensionDelegate delegate = mExtensionDelegate.get();
//    if (delegate == null) {
//      return;
//    }
//
//    WebExtension.Action resolved;
//
//    if (session == null) {
//      // This is the default action
//      mDefaultAction = action;
//      resolved = actionFor(delegate.getCurrentSession());
//    } else {
//      if (delegate.getSession(session) == null) {
//        return;
//      }
//      delegate.getSession(session).action = action;
//      if (delegate.getCurrentSession() != session) {
//        // This update is not for the session that we are currently displaying,
//        // no need to update the UI
//        return;
//      }
//      resolved = action.withDefault(mDefaultAction);
//    }
//
//    updateAction(resolved);
//  }

//  @Override
//  public GeckoResult<GeckoSession> onNewTab(WebExtension source,
//                                            WebExtension.CreateTabDetails details) {
//    WebExtensionDelegate delegate = mExtensionDelegate.get();
//    if (delegate == null) {
//      return GeckoResult.fromValue(null);
//    }
//    return GeckoResult.fromValue(delegate.openNewTab(details));
//  }

//  @Override
//  public GeckoResult<AllowOrDeny> onCloseTab(WebExtension extension, GeckoSession session) {
//    final WebExtensionDelegate delegate = mExtensionDelegate.get();
//    if (delegate == null) {
//      return GeckoResult.deny();
//    }
//
//    final TabSession tabSession = mTabManager.getSession(session);
//    if (tabSession != null) {
//      delegate.closeTab(tabSession);
//    }
//
//    return GeckoResult.allow();
//  }

//  @Override
//  public GeckoResult<AllowOrDeny> onUpdateTab(WebExtension extension,
//                                              GeckoSession session,
//                                              WebExtension.UpdateTabDetails updateDetails) {
//    final WebExtensionDelegate delegate = mExtensionDelegate.get();
//    if (delegate == null) {
//      return GeckoResult.deny();
//    }
//
//    final TabSession tabSession = mTabManager.getSession(session);
//    if (tabSession != null) {
//      delegate.updateTab(tabSession, updateDetails);
//    }
//
//    return GeckoResult.allow();
//  }
//
//  @Override
//  public void onPageAction(final WebExtension extension,
//                           final GeckoSession session,
//                           final WebExtension.Action action) {
//    onAction(extension, session, action);
//  }
//
//  @Override
//  public void onBrowserAction(final WebExtension extension,
//                              final GeckoSession session,
//                              final WebExtension.Action action) {
//    onAction(extension, session, action);
//  }
//
//  private GeckoResult<GeckoSession> togglePopup(boolean force) {
//    WebExtensionDelegate extensionDelegate = mExtensionDelegate.get();
//    if (extensionDelegate == null) {
//      return null;
//    }
//
//    GeckoSession session = extensionDelegate.toggleBrowserActionPopup(false);
//    if (session == null) {
//      return null;
//    }
//
//    return GeckoResult.fromValue(session);
//  }
//
//  @Override
//  public GeckoResult<GeckoSession> onTogglePopup(final @NonNull WebExtension extension,
//                                                 final @NonNull WebExtension.Action action) {
//    return togglePopup(false);
//  }
//
//  @Override
//  public GeckoResult<GeckoSession> onOpenPopup(final @NonNull WebExtension extension,
//                                               final @NonNull WebExtension.Action action) {
//    return togglePopup(true);
//  }
//
//  private WebExtension.Action actionFor(TabSession session) {
//    if (session.action == null) {
//      return mDefaultAction;
//    } else {
//      return session.action.withDefault(mDefaultAction);
//    }
//  }
//
//  private void updateAction(WebExtension.Action resolved) {
//    WebExtensionDelegate extensionDelegate = mExtensionDelegate.get();
//    if (extensionDelegate == null) {
//      return;
//    }
//
//    if (resolved == null || resolved.enabled == null || !resolved.enabled) {
//      extensionDelegate.onActionButton(null);
//      return;
//    }
//
//    if (resolved.icon != null) {
//      if (mBitmapCache.get(resolved.icon) != null) {
//        extensionDelegate.onActionButton(new ActionButton(
//                mBitmapCache.get(resolved.icon), resolved.badgeText,
//                resolved.badgeTextColor,
//                resolved.badgeBackgroundColor
//        ));
//      } else {
//        resolved.icon.getBitmap(100).accept(bitmap -> {
//          mBitmapCache.put(resolved.icon, bitmap);
//          extensionDelegate.onActionButton(new ActionButton(
//                  bitmap, resolved.badgeText,
//                  resolved.badgeTextColor,
//                  resolved.badgeBackgroundColor));
//        });
//      }
//    } else {
//      extensionDelegate.onActionButton(null);
//    }
//  }
//
//  public void onClicked(TabSession session) {
//    WebExtension.Action action = actionFor(session);
//    if (action != null) {
//      action.click();
//    }
//  }
//
//  public void setExtensionDelegate(WebExtensionDelegate delegate) {
//    mExtensionDelegate = new WeakReference<>(delegate);
//  }
//
//  @Override
//  public void onCurrentSession(TabSession session) {
//    if (mDefaultAction == null) {
//      // No action was ever defined, so nothing to do
//      return;
//    }
//
//    if (session.action != null) {
//      updateAction(session.action.withDefault(mDefaultAction));
//    } else {
//      updateAction(mDefaultAction);
//    }
//  }

  public GeckoResult<Void> unregisterExtension() {
    if (extension == null) {
      return GeckoResult.fromValue(null);
    }

   // mTabManager.unregisterWebExtension();

    return mRuntime.getWebExtensionController().uninstall(extension).accept(new GeckoResult.Consumer<Void>() {
      @Override
      public void accept(@Nullable Void unused) {
        extension = null;
        mDefaultAction = null;
        //updateAction(null);
      }
    });
  }

  public GeckoResult<WebExtension> updateExtension() {
    if (extension == null) {
      return GeckoResult.fromValue(null);
    }

    return mRuntime.getWebExtensionController().update(extension).map(new GeckoResult.OnValueMapper<WebExtension, WebExtension>() {
      @Nullable
      @Override
      public WebExtension onValue(@Nullable WebExtension newExtension) throws Throwable {
        WebExtensionManager.this.registerExtension(newExtension);
        return newExtension;
      }
    });
  }

  public void registerExtension(WebExtension extension) {
    Log.d(LOG_TAG, extension.toString());
    extension.setMessageDelegate(this, "browser");
    // mTabManager.setWebExtensionDelegates(extension, this, this);
    this.extension = extension;
  }

  private void refreshExtensionList() {
    mRuntime.getWebExtensionController()
            .list().accept(new GeckoResult.Consumer<List<WebExtension>>() {
      @Override
      public void accept(@Nullable List<WebExtension> extensions) {
        for (final WebExtension extension : extensions) {
          WebExtensionManager.this.registerExtension(extension);
        }
      }
    });
  }

  @Nullable
  @Override
  public GeckoResult<Object> onMessage(@NonNull String nativeApp, @NonNull Object message, @NonNull WebExtension.MessageSender sender) {
    Log.d(LOG_TAG, "\n\n\nMESSAGE\n\n\n" + message.toString());
    return null;
  }

  @Nullable
  @Override
  public void onConnect(@NonNull WebExtension.Port port) {
    port.setDelegate(this);
    port.postMessage(null);
    Log.d(LOG_TAG, "\n\n\nON CONNECT\n\n\n");
  }

  @Override
  public void onPortMessage(@NonNull Object message, @NonNull WebExtension.Port port) {
    Log.d(LOG_TAG, message.toString());
  }

  @NonNull
  @Override
  public void onDisconnect(@NonNull WebExtension.Port port) {

  }

  public WebExtensionManager(GeckoRuntime runtime) {
    mRuntime = runtime;
    refreshExtensionList();
  }
}
