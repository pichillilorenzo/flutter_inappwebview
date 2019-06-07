package com.pichillilorenzo.flutter_inappbrowser.InAppWebView;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.view.View;
import android.webkit.ConsoleMessage;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.widget.FrameLayout;

import com.pichillilorenzo.flutter_inappbrowser.FlutterWebView;
import com.pichillilorenzo.flutter_inappbrowser.InAppBrowserActivity;
import com.pichillilorenzo.flutter_inappbrowser.InAppBrowserFlutterPlugin;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class InAppWebChromeClient extends WebChromeClient {

  protected static final String LOG_TAG = "IABWebChromeClient";
  private PluginRegistry.Registrar registrar;
  private FlutterWebView flutterWebView;
  private InAppBrowserActivity inAppBrowserActivity;
  private ValueCallback<Uri[]> mUploadMessageArray;
  private ValueCallback<Uri> mUploadMessage;
  private final static int FILECHOOSER_RESULTCODE = 1;

  private View mCustomView;
  private WebChromeClient.CustomViewCallback mCustomViewCallback;
  protected FrameLayout mFullscreenContainer;
  private int mOriginalOrientation;
  private int mOriginalSystemUiVisibility;

  public InAppWebChromeClient(Object obj, PluginRegistry.Registrar registrar) {
    super();
    this.registrar = registrar;
    if (obj instanceof InAppBrowserActivity)
      this.inAppBrowserActivity = (InAppBrowserActivity) obj;
    else if (obj instanceof FlutterWebView)
      this.flutterWebView = (FlutterWebView) obj;
  }

  public Bitmap getDefaultVideoPoster()
  {
    if (mCustomView == null) {
      return null;
    }
    return BitmapFactory.decodeResource(this.registrar.activeContext().getResources(), 2130837573);
  }

  public void onHideCustomView()
  {
    View decorView = this.registrar.activity().getWindow().getDecorView();
    ((FrameLayout) decorView).removeView(this.mCustomView);
    this.mCustomView = null;
    decorView.setSystemUiVisibility(this.mOriginalSystemUiVisibility);
    this.registrar.activity().setRequestedOrientation(this.mOriginalOrientation);
    this.mCustomViewCallback.onCustomViewHidden();
    this.mCustomViewCallback = null;
  }

  public void onShowCustomView(View paramView, WebChromeClient.CustomViewCallback paramCustomViewCallback)
  {
    if (this.mCustomView != null)
    {
      onHideCustomView();
      return;
    }
    View decorView = this.registrar.activity().getWindow().getDecorView();
    this.mCustomView = paramView;
    this.mOriginalSystemUiVisibility = decorView.getSystemUiVisibility();
    this.mOriginalOrientation = this.registrar.activity().getRequestedOrientation();
    this.mCustomViewCallback = paramCustomViewCallback;
    this.mCustomView.setBackgroundColor(Color.parseColor("#000000"));
    ((FrameLayout) decorView).addView(this.mCustomView, new FrameLayout.LayoutParams(-1, -1));
    decorView.setSystemUiVisibility(3846 | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
  }

  @Override
  public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("sourceURL", consoleMessage.sourceId());
    obj.put("lineNumber", consoleMessage.lineNumber());
    obj.put("message", consoleMessage.message());
    obj.put("messageLevel", consoleMessage.messageLevel().toString());
    getChannel().invokeMethod("onConsoleMessage", obj);
    return true;
  }

  @Override
  public void onProgressChanged(WebView view, int progress) {
    if (inAppBrowserActivity != null && inAppBrowserActivity.progressBar != null) {
      inAppBrowserActivity.progressBar.setVisibility(View.VISIBLE);
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        inAppBrowserActivity.progressBar.setProgress(progress, true);
      } else {
        inAppBrowserActivity.progressBar.setProgress(progress);
      }
      if (progress == 100) {
        inAppBrowserActivity.progressBar.setVisibility(View.GONE);
      }
    }

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("progress", progress);
    getChannel().invokeMethod("onProgressChanged", obj);

    super.onProgressChanged(view, progress);
  }

  @Override
  public void onReceivedTitle(WebView view, String title) {
    super.onReceivedTitle(view, title);
    if (inAppBrowserActivity != null && inAppBrowserActivity.actionBar != null && inAppBrowserActivity.options.toolbarTopFixedTitle.isEmpty())
      inAppBrowserActivity.actionBar.setTitle(title);
  }

  @Override
  public void onReceivedIcon(WebView view, Bitmap icon) {
    super.onReceivedIcon(view, icon);
  }

  //The undocumented magic method override
  //Eclipse will swear at you if you try to put @Override here
  // For Android 3.0+
  public void openFileChooser(ValueCallback<Uri> uploadMsg) {

    mUploadMessage = uploadMsg;
    Intent i = new Intent(Intent.ACTION_GET_CONTENT);
    i.addCategory(Intent.CATEGORY_OPENABLE);
    i.setType("image/*");
    ((inAppBrowserActivity != null) ? inAppBrowserActivity : flutterWebView.activity).startActivityForResult(Intent.createChooser(i, "File Chooser"), FILECHOOSER_RESULTCODE);

  }

  // For Android 3.0+
  public void openFileChooser(ValueCallback uploadMsg, String acceptType) {
    mUploadMessage = uploadMsg;
    Intent i = new Intent(Intent.ACTION_GET_CONTENT);
    i.addCategory(Intent.CATEGORY_OPENABLE);
    i.setType("*/*");
    ((inAppBrowserActivity != null) ? inAppBrowserActivity : flutterWebView.activity).startActivityForResult(
            Intent.createChooser(i, "File Browser"),
            FILECHOOSER_RESULTCODE);
  }

  //For Android 4.1
  public void openFileChooser(ValueCallback<Uri> uploadMsg, String acceptType, String capture) {
    mUploadMessage = uploadMsg;
    Intent i = new Intent(Intent.ACTION_GET_CONTENT);
    i.addCategory(Intent.CATEGORY_OPENABLE);
    i.setType("image/*");
    ((inAppBrowserActivity != null) ? inAppBrowserActivity : flutterWebView.activity).startActivityForResult(Intent.createChooser(i, "File Chooser"), FILECHOOSER_RESULTCODE);

  }

  //For Android 5.0+
  public boolean onShowFileChooser(
          WebView webView, ValueCallback<Uri[]> filePathCallback,
          FileChooserParams fileChooserParams) {
    if (mUploadMessageArray != null) {
      mUploadMessageArray.onReceiveValue(null);
    }
    mUploadMessageArray = filePathCallback;

    Intent contentSelectionIntent = new Intent(Intent.ACTION_GET_CONTENT);
    contentSelectionIntent.addCategory(Intent.CATEGORY_OPENABLE);
    contentSelectionIntent.setType("*/*");
    Intent[] intentArray;
    intentArray = new Intent[0];

    Intent chooserIntent = new Intent(Intent.ACTION_CHOOSER);
    chooserIntent.putExtra(Intent.EXTRA_INTENT, contentSelectionIntent);
    chooserIntent.putExtra(Intent.EXTRA_TITLE, "Image Chooser");
    chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, intentArray);
    ((inAppBrowserActivity != null) ? inAppBrowserActivity : flutterWebView.activity).startActivityForResult(chooserIntent, FILECHOOSER_RESULTCODE);
    return true;
  }

  private MethodChannel getChannel() {
    return (inAppBrowserActivity != null) ? InAppBrowserFlutterPlugin.channel : flutterWebView.channel;
  }
}
