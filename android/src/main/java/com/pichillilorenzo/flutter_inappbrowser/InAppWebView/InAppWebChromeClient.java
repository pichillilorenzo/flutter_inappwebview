package com.pichillilorenzo.flutter_inappbrowser.InAppWebView;

import android.Manifest;
import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.text.Html;
import android.util.Log;
import android.view.View;
import android.webkit.ConsoleMessage;
import android.webkit.GeolocationPermissions;
import android.webkit.JsPromptResult;
import android.webkit.JsResult;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import androidx.appcompat.app.AlertDialog;

import com.pichillilorenzo.flutter_inappbrowser.FlutterWebView;
import com.pichillilorenzo.flutter_inappbrowser.InAppBrowserActivity;
import com.pichillilorenzo.flutter_inappbrowser.InAppBrowserFlutterPlugin;
import com.pichillilorenzo.flutter_inappbrowser.R;
import com.pichillilorenzo.flutter_inappbrowser.RequestPermissionHandler;
import com.pichillilorenzo.flutter_inappbrowser.Util;

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
  public boolean onJsAlert(final WebView view, String url, final String message,
                           final JsResult result) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("message", message);

    getChannel().invokeMethod("onJsAlert", obj, new MethodChannel.Result() {
      @Override
      public void success(Object response) {
        Map<String, Object> responseMap = (Map<String, Object>) response;
        String responseMessage = (String) responseMap.get("message");
        String confirmButtonTitle = (String) responseMap.get("confirmButtonTitle");
        boolean handledByClient = (boolean) responseMap.get("handledByClient");
        if (handledByClient) {
          Integer action = (Integer) responseMap.get("action");
          action = action != null ? action : 1;
          switch (action) {
            case 0:
              result.confirm();
              break;
            case 1:
            default:
              result.cancel();
          }
        } else {
          String alertMessage = (responseMessage != null && !responseMessage.isEmpty()) ? responseMessage : message;
          Log.d(LOG_TAG, alertMessage);
          DialogInterface.OnClickListener clickListener = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
              result.confirm();
              dialog.dismiss();
            }
          };

          AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(view.getContext(), R.style.Theme_AppCompat_Dialog_Alert);
          alertDialogBuilder.setMessage(alertMessage);
          if (confirmButtonTitle != null && !confirmButtonTitle.isEmpty()) {
            alertDialogBuilder.setPositiveButton(confirmButtonTitle, clickListener);
          } else {
            alertDialogBuilder.setPositiveButton(android.R.string.ok, clickListener);
          }

          alertDialogBuilder.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
              result.cancel();
              dialog.dismiss();
            }
          });

          AlertDialog alertDialog = alertDialogBuilder.create();
          alertDialog.show();
        }
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
      }

      @Override
      public void notImplemented() {

      }
    });

    return true;
  }

  @Override
  public boolean onJsConfirm(final WebView view, String url, final String message,
                             final JsResult result) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("message", message);

    getChannel().invokeMethod("onJsConfirm", obj, new MethodChannel.Result() {
      @Override
      public void success(Object response) {
        Map<String, Object> responseMap = (Map<String, Object>) response;
        String responseMessage = (String) responseMap.get("message");
        String confirmButtonTitle = (String) responseMap.get("confirmButtonTitle");
        String cancelButtonTitle = (String) responseMap.get("cancelButtonTitle");
        boolean handledByClient = (boolean) responseMap.get("handledByClient");
        if (handledByClient) {
          Integer action = (Integer) responseMap.get("action");
          action = action != null ? action : 1;
          switch (action) {
            case 0:
              result.confirm();
              break;
            case 1:
            default:
              result.cancel();
          }
        } else {
          String alertMessage = (responseMessage != null && !responseMessage.isEmpty()) ? responseMessage : message;
          DialogInterface.OnClickListener confirmClickListener = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
              result.confirm();
              dialog.dismiss();
            }
          };
          DialogInterface.OnClickListener cancelClickListener = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
              result.cancel();
              dialog.dismiss();
            }
          };

          AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(view.getContext(), R.style.Theme_AppCompat_Dialog_Alert);
          alertDialogBuilder.setMessage(alertMessage);
          if (confirmButtonTitle != null && !confirmButtonTitle.isEmpty()) {
            alertDialogBuilder.setPositiveButton(confirmButtonTitle, confirmClickListener);
          } else {
            alertDialogBuilder.setPositiveButton(android.R.string.ok, confirmClickListener);
          }
          if (cancelButtonTitle != null && !cancelButtonTitle.isEmpty()) {
            alertDialogBuilder.setNegativeButton(cancelButtonTitle, cancelClickListener);
          } else {
            alertDialogBuilder.setNegativeButton(android.R.string.cancel, cancelClickListener);
          }

          alertDialogBuilder.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
              result.cancel();
              dialog.dismiss();
            }
          });

          AlertDialog alertDialog = alertDialogBuilder.create();
          alertDialog.show();
        }
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
      }

      @Override
      public void notImplemented() {

      }
    });

    return true;
  }

  @Override
  public boolean onJsPrompt(final WebView view, String url, final String message,
                            final String defaultValue, final JsPromptResult result) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("message", message);
    obj.put("defaultValue", defaultValue);

    getChannel().invokeMethod("onJsPrompt", obj, new MethodChannel.Result() {
      @Override
      public void success(Object response) {
        Map<String, Object> responseMap = (Map<String, Object>) response;
        String responseMessage = (String) responseMap.get("message");
        String responseDefaultValue = (String) responseMap.get("defaultValue");
        String confirmButtonTitle = (String) responseMap.get("confirmButtonTitle");
        String cancelButtonTitle = (String) responseMap.get("cancelButtonTitle");
        final String value = (String) responseMap.get("value");
        boolean handledByClient = (boolean) responseMap.get("handledByClient");
        if (handledByClient) {
          Integer action = (Integer) responseMap.get("action");
          action = action != null ? action : 1;
          switch (action) {
            case 0:
              if (value != null)
                result.confirm(value);
              else
                result.confirm();
              break;
            case 1:
            default:
              result.cancel();
          }
        } else {
          FrameLayout layout = new FrameLayout(view.getContext());

          final EditText input = new EditText(view.getContext());
          input.setMaxLines(1);
          input.setText((responseDefaultValue != null && !responseDefaultValue.isEmpty()) ? responseDefaultValue : defaultValue);
          LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                  LinearLayout.LayoutParams.MATCH_PARENT,
                  LinearLayout.LayoutParams.MATCH_PARENT);
          input.setLayoutParams(lp);

          layout.setPaddingRelative(45,15,45,0);
          layout.addView(input);

          String alertMessage = (responseMessage != null && !responseMessage.isEmpty()) ? responseMessage : message;
          DialogInterface.OnClickListener confirmClickListener = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
              String text = input.getText().toString();
              result.confirm(value != null ? value : text);
              dialog.dismiss();
            }
          };
          DialogInterface.OnClickListener cancelClickListener = new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
              result.cancel();
              dialog.dismiss();
            }
          };

          AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(view.getContext(), R.style.Theme_AppCompat_Dialog_Alert);
          alertDialogBuilder.setMessage(alertMessage);
          if (confirmButtonTitle != null && !confirmButtonTitle.isEmpty()) {
            alertDialogBuilder.setPositiveButton(confirmButtonTitle, confirmClickListener);
          } else {
            alertDialogBuilder.setPositiveButton(android.R.string.ok, confirmClickListener);
          }
          if (cancelButtonTitle != null && !cancelButtonTitle.isEmpty()) {
            alertDialogBuilder.setNegativeButton(cancelButtonTitle, cancelClickListener);
          } else {
            alertDialogBuilder.setNegativeButton(android.R.string.cancel, cancelClickListener);
          }

          alertDialogBuilder.setOnCancelListener(new DialogInterface.OnCancelListener() {
            @Override
            public void onCancel(DialogInterface dialog) {
              result.cancel();
              dialog.dismiss();
            }
          });

          AlertDialog alertDialog = alertDialogBuilder.create();
          alertDialog.setView(layout);
          alertDialog.show();
        }
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
      }

      @Override
      public void notImplemented() {

      }
    });

    return true;
  }

  @Override
  public boolean onCreateWindow(WebView view, boolean dialog, boolean userGesture, android.os.Message resultMsg)
  {
    WebView.HitTestResult result = view.getHitTestResult();
    String data = result.getExtra();
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("url", data);
    getChannel().invokeMethod("onTargetBlank", obj);
    return false;
  }

  @Override
  public void onGeolocationPermissionsShowPrompt (final String origin, final GeolocationPermissions.Callback callback) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("origin", origin);
    getChannel().invokeMethod("onGeolocationPermissionsShowPrompt", obj, new MethodChannel.Result() {
      @Override
      public void success(Object o) {
        Map<String, Object> response = (Map<String, Object>) o;
        if (response != null)
          callback.invoke((String) response.get("origin"),(Boolean) response.get("allow"),(Boolean) response.get("retain"));
        else
          callback.invoke(origin,false,false);
      }

      @Override
      public void error(String s, String s1, Object o) {
        callback.invoke(origin,false,false);
      }

      @Override
      public void notImplemented() {
        callback.invoke(origin,false,false);
      }
    });
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
    return (inAppBrowserActivity != null) ? InAppBrowserFlutterPlugin.instance.channel : flutterWebView.channel;
  }
}
