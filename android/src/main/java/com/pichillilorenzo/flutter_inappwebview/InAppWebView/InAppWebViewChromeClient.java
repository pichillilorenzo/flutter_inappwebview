package com.pichillilorenzo.flutter_inappwebview.InAppWebView;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Message;
import android.os.Parcelable;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.webkit.ConsoleMessage;
import android.webkit.GeolocationPermissions;
import android.webkit.JsPromptResult;
import android.webkit.JsResult;
import android.webkit.MimeTypeMap;
import android.webkit.PermissionRequest;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AlertDialog;
import androidx.core.content.ContextCompat;
import androidx.core.content.FileProvider;

import com.pichillilorenzo.flutter_inappwebview.InAppBrowser.InAppBrowserActivity;
import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview.R;
import com.pichillilorenzo.flutter_inappwebview.Shared;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

import static android.app.Activity.RESULT_OK;

public class InAppWebViewChromeClient extends WebChromeClient implements PluginRegistry.ActivityResultListener {

  protected static final String LOG_TAG = "IABWebChromeClient";
  private FlutterWebView flutterWebView;
  private InAppBrowserActivity inAppBrowserActivity;
  public MethodChannel channel;

  private static final String fileProviderAuthorityExtension = "flutter_inappwebview.fileprovider";

  private static final int PICKER = 1;
  private static final int PICKER_LEGACY = 3;
  final String DEFAULT_MIME_TYPES = "*/*";
  private Uri outputFileUri;

  protected static final FrameLayout.LayoutParams FULLSCREEN_LAYOUT_PARAMS = new FrameLayout.LayoutParams(
          ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, Gravity.CENTER);

  @RequiresApi(api = Build.VERSION_CODES.KITKAT)
  protected static final int FULLSCREEN_SYSTEM_UI_VISIBILITY_KITKAT = View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION |
          View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN |
          View.SYSTEM_UI_FLAG_LAYOUT_STABLE |
          View.SYSTEM_UI_FLAG_HIDE_NAVIGATION |
          View.SYSTEM_UI_FLAG_FULLSCREEN |
          View.SYSTEM_UI_FLAG_IMMERSIVE |
          View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY;

  protected static final int FULLSCREEN_SYSTEM_UI_VISIBILITY = View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION |
          View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN |
          View.SYSTEM_UI_FLAG_LAYOUT_STABLE |
          View.SYSTEM_UI_FLAG_HIDE_NAVIGATION |
          View.SYSTEM_UI_FLAG_FULLSCREEN;

  private View mCustomView;
  private WebChromeClient.CustomViewCallback mCustomViewCallback;
  private int mOriginalOrientation;
  private int mOriginalSystemUiVisibility;

  public InAppWebViewChromeClient(Object obj) {
    if (obj instanceof InAppBrowserActivity)
      this.inAppBrowserActivity = (InAppBrowserActivity) obj;
    else if (obj instanceof FlutterWebView)
      this.flutterWebView = (FlutterWebView) obj;
    this.channel = (this.inAppBrowserActivity != null) ? this.inAppBrowserActivity.channel : this.flutterWebView.channel;

    if (Shared.registrar != null)
      Shared.registrar.addActivityResultListener(this);
    else
      Shared.activityPluginBinding.addActivityResultListener(this);
  }

  @Override
  public Bitmap getDefaultVideoPoster() {
    if (mCustomView == null) {
      return null;
    }
    Activity activity = inAppBrowserActivity != null ? inAppBrowserActivity : Shared.activity;
    return BitmapFactory.decodeResource(activity.getApplicationContext().getResources(), 2130837573);
  }

  @Override
  public void onHideCustomView() {
    Activity activity = inAppBrowserActivity != null ? inAppBrowserActivity : Shared.activity;

    View decorView = getRootView();
    ((FrameLayout) decorView).removeView(this.mCustomView);
    this.mCustomView = null;
    decorView.setSystemUiVisibility(this.mOriginalSystemUiVisibility);
    activity.setRequestedOrientation(this.mOriginalOrientation);
    this.mCustomViewCallback.onCustomViewHidden();
    this.mCustomViewCallback = null;
    activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    channel.invokeMethod("onExitFullscreen", obj);
  }

  @Override
  public void onShowCustomView(final View paramView, final CustomViewCallback paramCustomViewCallback) {
    if (this.mCustomView != null) {
      onHideCustomView();
      return;
    }

    Activity activity = inAppBrowserActivity != null ? inAppBrowserActivity : Shared.activity;

    View decorView = getRootView();
    this.mCustomView = paramView;
    this.mOriginalSystemUiVisibility = decorView.getSystemUiVisibility();
    this.mOriginalOrientation = activity.getRequestedOrientation();
    this.mCustomViewCallback = paramCustomViewCallback;
    this.mCustomView.setBackgroundColor(Color.BLACK);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      decorView.setSystemUiVisibility(FULLSCREEN_SYSTEM_UI_VISIBILITY_KITKAT);
    } else {
      decorView.setSystemUiVisibility(FULLSCREEN_SYSTEM_UI_VISIBILITY);
    }
    activity.getWindow().setFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS, WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS);
    ((FrameLayout) decorView).addView(this.mCustomView, FULLSCREEN_LAYOUT_PARAMS);

    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    channel.invokeMethod("onEnterFullscreen", obj);
  }

  @Override
  public boolean onJsAlert(final WebView view, String url, final String message,
                           final JsResult result) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("message", message);

    channel.invokeMethod("onJsAlert", obj, new MethodChannel.Result() {
      @Override
      public void success(Object response) {
        String responseMessage = null;
        String confirmButtonTitle = null;

        if (response != null) {
          Map<String, Object> responseMap = (Map<String, Object>) response;
          responseMessage = (String) responseMap.get("message");
          confirmButtonTitle = (String) responseMap.get("confirmButtonTitle");
          Boolean handledByClient = (Boolean) responseMap.get("handledByClient");
          if (handledByClient != null && handledByClient) {
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
            return;
          }
        }

        createAlertDialog(view, message, result, responseMessage, confirmButtonTitle);
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
        result.cancel();
      }

      @Override
      public void notImplemented() {
        createAlertDialog(view, message, result, null, null);
      }
    });

    return true;
  }

  public void createAlertDialog(WebView view, String message, final JsResult result, String responseMessage, String confirmButtonTitle) {
    String alertMessage = (responseMessage != null && !responseMessage.isEmpty()) ? responseMessage : message;

    DialogInterface.OnClickListener clickListener = new DialogInterface.OnClickListener() {
      @Override
      public void onClick(DialogInterface dialog, int which) {
        result.confirm();
        dialog.dismiss();
      }
    };

    Activity activity = inAppBrowserActivity != null ? inAppBrowserActivity : Shared.activity;

    AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(activity, R.style.Theme_AppCompat_Dialog_Alert);
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

  @Override
  public boolean onJsConfirm(final WebView view, String url, final String message,
                             final JsResult result) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("message", message);

    channel.invokeMethod("onJsConfirm", obj, new MethodChannel.Result() {
      @Override
      public void success(Object response) {
        String responseMessage = null;
        String confirmButtonTitle = null;
        String cancelButtonTitle = null;

        if (response != null) {
          Map<String, Object> responseMap = (Map<String, Object>) response;
          responseMessage = (String) responseMap.get("message");
          confirmButtonTitle = (String) responseMap.get("confirmButtonTitle");
          cancelButtonTitle = (String) responseMap.get("cancelButtonTitle");
          Boolean handledByClient = (Boolean) responseMap.get("handledByClient");
          if (handledByClient != null && handledByClient) {
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
            return;
          }
        }

        createConfirmDialog(view, message, result, responseMessage, confirmButtonTitle, cancelButtonTitle);
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
        result.cancel();
      }

      @Override
      public void notImplemented() {
        createConfirmDialog(view, message, result, null, null, null);
      }
    });

    return true;
  }

  public void createConfirmDialog(WebView view, String message, final JsResult result, String responseMessage, String confirmButtonTitle, String cancelButtonTitle) {
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

    Activity activity = inAppBrowserActivity != null ? inAppBrowserActivity : Shared.activity;

    AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(activity, R.style.Theme_AppCompat_Dialog_Alert);
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

  @Override
  public boolean onJsPrompt(final WebView view, String url, final String message,
                            final String defaultValue, final JsPromptResult result) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("message", message);
    obj.put("defaultValue", defaultValue);

    channel.invokeMethod("onJsPrompt", obj, new MethodChannel.Result() {
      @Override
      public void success(Object response) {
        String responseMessage = null;
        String responseDefaultValue = null;
        String confirmButtonTitle = null;
        String cancelButtonTitle = null;
        String value = null;

        if (response != null) {
          Map<String, Object> responseMap = (Map<String, Object>) response;
          responseMessage = (String) responseMap.get("message");
          responseDefaultValue = (String) responseMap.get("defaultValue");
          confirmButtonTitle = (String) responseMap.get("confirmButtonTitle");
          cancelButtonTitle = (String) responseMap.get("cancelButtonTitle");
          value = (String) responseMap.get("value");
          Boolean handledByClient = (Boolean) responseMap.get("handledByClient");
          if (handledByClient != null && handledByClient) {
            Integer action = (Integer) responseMap.get("action");
            action = action != null ? action : 1;
            switch (action) {
              case 0:
                result.confirm(value);
                break;
              case 1:
              default:
                result.cancel();
            }
            return;
          }
        }

        createPromptDialog(view, message, defaultValue, result, responseMessage, responseDefaultValue, value, cancelButtonTitle, confirmButtonTitle);
      }

      @Override
      public void error(String s, String s1, Object o) {
        Log.e(LOG_TAG, s + ", " + s1);
        result.cancel();
      }

      @Override
      public void notImplemented() {
        createPromptDialog(view, message, defaultValue, result, null, null, null, null, null);
      }
    });

    return true;
  }

  public void createPromptDialog(WebView view, String message, String defaultValue, final JsPromptResult result, String responseMessage, String responseDefaultValue, String value, String cancelButtonTitle, String confirmButtonTitle) {
    FrameLayout layout = new FrameLayout(view.getContext());

    final EditText input = new EditText(view.getContext());
    input.setMaxLines(1);
    input.setText((responseDefaultValue != null && !responseDefaultValue.isEmpty()) ? responseDefaultValue : defaultValue);
    LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
            LinearLayout.LayoutParams.MATCH_PARENT,
            LinearLayout.LayoutParams.MATCH_PARENT);
    input.setLayoutParams(lp);

    layout.setPaddingRelative(45, 15, 45, 0);
    layout.addView(input);

    String alertMessage = (responseMessage != null && !responseMessage.isEmpty()) ? responseMessage : message;

    final String finalValue = value;
    DialogInterface.OnClickListener confirmClickListener = new DialogInterface.OnClickListener() {
      @Override
      public void onClick(DialogInterface dialog, int which) {
        String text = input.getText().toString();
        result.confirm(finalValue != null ? finalValue : text);
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

    Activity activity = inAppBrowserActivity != null ? inAppBrowserActivity : Shared.activity;

    AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(activity, R.style.Theme_AppCompat_Dialog_Alert);
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

  @Override
  public boolean onCreateWindow(WebView view, boolean isDialog, boolean isUserGesture, final Message resultMsg) {
    final Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("androidIsDialog", isDialog);
    obj.put("androidIsUserGesture", isUserGesture);
    obj.put("iosWKNavigationType", null);

    WebView.HitTestResult result = view.getHitTestResult();
    String data = result.getExtra();

    if (data == null) {
      // to get the URL, create a temp weview
      final WebView tempWebView = new WebView(view.getContext());
      // disable javascript
      tempWebView.getSettings().setJavaScriptEnabled(false);
      tempWebView.setWebViewClient(new WebViewClient(){
        @Override
        public void onPageStarted(WebView v, String url, Bitmap favicon) {
          super.onPageStarted(v, url, favicon);

          obj.put("url", url);
          channel.invokeMethod("onCreateWindow", obj);

          // stop webview loading
          v.stopLoading();

          // this will throw the error "Application attempted to call on a destroyed AwAutofillManager" that will kill the webview.
          // that's ok.
          v.destroy();
        }
      });
      ((WebView.WebViewTransport) resultMsg.obj).setWebView(tempWebView);
      resultMsg.sendToTarget();
      return true;
    }

    obj.put("url", data);
    channel.invokeMethod("onCreateWindow", obj);
    return false;
  }

  @Override
  public void onGeolocationPermissionsShowPrompt(final String origin, final GeolocationPermissions.Callback callback) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("origin", origin);
    channel.invokeMethod("onGeolocationPermissionsShowPrompt", obj, new MethodChannel.Result() {
      @Override
      public void success(Object o) {
        Map<String, Object> response = (Map<String, Object>) o;
        if (response != null)
          callback.invoke((String) response.get("origin"), (Boolean) response.get("allow"), (Boolean) response.get("retain"));
        else
          callback.invoke(origin, false, false);
      }

      @Override
      public void error(String s, String s1, Object o) {
        callback.invoke(origin, false, false);
      }

      @Override
      public void notImplemented() {
        callback.invoke(origin, false, false);
      }
    });
  }

  @Override
  public void onGeolocationPermissionsHidePrompt() {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    channel.invokeMethod("onGeolocationPermissionsHidePrompt", obj);
  }

  @Override
  public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
    Map<String, Object> obj = new HashMap<>();
    if (inAppBrowserActivity != null)
      obj.put("uuid", inAppBrowserActivity.uuid);
    obj.put("message", consoleMessage.message());
    obj.put("messageLevel", consoleMessage.messageLevel().ordinal());
    channel.invokeMethod("onConsoleMessage", obj);
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
    channel.invokeMethod("onProgressChanged", obj);

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

  protected ViewGroup getRootView() {
    Activity activity = inAppBrowserActivity != null ? inAppBrowserActivity : Shared.activity;
    return (ViewGroup) activity.findViewById(android.R.id.content);
  }

  protected void openFileChooser(ValueCallback<Uri> filePathCallback, String acceptType) {
    startPhotoPickerIntent(filePathCallback, acceptType);
  }

  protected void openFileChooser(ValueCallback<Uri> filePathCallback) {
    startPhotoPickerIntent(filePathCallback, "");
  }

  protected void openFileChooser(ValueCallback<Uri> filePathCallback, String acceptType, String capture) {
    startPhotoPickerIntent(filePathCallback, acceptType);
  }

  @TargetApi(Build.VERSION_CODES.LOLLIPOP)
  @Override
  public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, FileChooserParams fileChooserParams) {
    String[] acceptTypes = fileChooserParams.getAcceptTypes();
    boolean allowMultiple = fileChooserParams.getMode() == WebChromeClient.FileChooserParams.MODE_OPEN_MULTIPLE;
    Intent intent = fileChooserParams.createIntent();
    return startPhotoPickerIntent(filePathCallback, intent, acceptTypes, allowMultiple);
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    if (InAppWebViewFlutterPlugin.filePathCallback == null && InAppWebViewFlutterPlugin.filePathCallbackLegacy == null) {
      return true;
    }

    // based off of which button was pressed, we get an activity result and a file
    // the camera activity doesn't properly return the filename* (I think?) so we use
    // this filename instead
    switch (requestCode) {
      case PICKER:
        if (resultCode != RESULT_OK) {
          if (InAppWebViewFlutterPlugin.filePathCallback != null) {
            InAppWebViewFlutterPlugin.filePathCallback.onReceiveValue(null);
          }
        } else {
          Uri result[] = this.getSelectedFiles(data, resultCode);
          if (result != null) {
            InAppWebViewFlutterPlugin.filePathCallback.onReceiveValue(result);
          } else {
            InAppWebViewFlutterPlugin.filePathCallback.onReceiveValue(new Uri[]{outputFileUri});
          }
        }
        break;
      case PICKER_LEGACY:
        Uri result = resultCode != Activity.RESULT_OK ? null : data == null ? outputFileUri : data.getData();
        InAppWebViewFlutterPlugin.filePathCallbackLegacy.onReceiveValue(result);
        break;

    }
    InAppWebViewFlutterPlugin.filePathCallback = null;
    InAppWebViewFlutterPlugin.filePathCallbackLegacy = null;
    outputFileUri = null;

    return true;
  }

  private Uri[] getSelectedFiles(Intent data, int resultCode) {
    if (data == null) {
      return null;
    }

    // we have one file selected
    if (data.getData() != null) {
      if (resultCode == RESULT_OK && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        return WebChromeClient.FileChooserParams.parseResult(resultCode, data);
      } else {
        return null;
      }
    }

    // we have multiple files selected
    if (data.getClipData() != null) {
      final int numSelectedFiles = data.getClipData().getItemCount();
      Uri[] result = new Uri[numSelectedFiles];
      for (int i = 0; i < numSelectedFiles; i++) {
        result[i] = data.getClipData().getItemAt(i).getUri();
      }
      return result;
    }
    return null;
  }

  public void startPhotoPickerIntent(ValueCallback<Uri> filePathCallback, String acceptType) {
    InAppWebViewFlutterPlugin.filePathCallbackLegacy = filePathCallback;

    Intent fileChooserIntent = getFileChooserIntent(acceptType);
    Intent chooserIntent = Intent.createChooser(fileChooserIntent, "");

    ArrayList<Parcelable> extraIntents = new ArrayList<>();
    if (acceptsImages(acceptType)) {
      extraIntents.add(getPhotoIntent());
    }
    if (acceptsVideo(acceptType)) {
      extraIntents.add(getVideoIntent());
    }
    chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, extraIntents.toArray(new Parcelable[]{}));

    Activity activity = inAppBrowserActivity != null ? inAppBrowserActivity : Shared.activity;
    if (chooserIntent.resolveActivity(activity.getPackageManager()) != null) {
      activity.startActivityForResult(chooserIntent, PICKER_LEGACY);
    } else {
      Log.d(LOG_TAG, "there is no Activity to handle this Intent");
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  public boolean startPhotoPickerIntent(final ValueCallback<Uri[]> callback, final Intent intent, final String[] acceptTypes, final boolean allowMultiple) {
    InAppWebViewFlutterPlugin.filePathCallback = callback;

    ArrayList<Parcelable> extraIntents = new ArrayList<>();
    if (!needsCameraPermission()) {
      if (acceptsImages(acceptTypes)) {
        extraIntents.add(getPhotoIntent());
      }
      if (acceptsVideo(acceptTypes)) {
        extraIntents.add(getVideoIntent());
      }
    }

    Intent fileSelectionIntent = getFileChooserIntent(acceptTypes, allowMultiple);

    Intent chooserIntent = new Intent(Intent.ACTION_CHOOSER);
    chooserIntent.putExtra(Intent.EXTRA_INTENT, fileSelectionIntent);
    chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, extraIntents.toArray(new Parcelable[]{}));

    Activity activity = inAppBrowserActivity != null ? inAppBrowserActivity : Shared.activity;
    if (chooserIntent.resolveActivity(activity.getPackageManager()) != null) {
      activity.startActivityForResult(chooserIntent, PICKER);
    } else {
      Log.d(LOG_TAG, "there is no Activity to handle this Intent");
    }

    return true;
  }

  protected boolean needsCameraPermission() {
    boolean needed = false;

    Activity activity = inAppBrowserActivity != null ? inAppBrowserActivity : Shared.activity;
    PackageManager packageManager = activity.getPackageManager();
    try {
      String[] requestedPermissions = packageManager.getPackageInfo(activity.getApplicationContext().getPackageName(), PackageManager.GET_PERMISSIONS).requestedPermissions;
      if (Arrays.asList(requestedPermissions).contains(Manifest.permission.CAMERA)
              && ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
        needed = true;
      }
    } catch (PackageManager.NameNotFoundException e) {
      needed = true;
    }

    return needed;
  }

  private Intent getPhotoIntent() {
    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    outputFileUri = getOutputUri(MediaStore.ACTION_IMAGE_CAPTURE);
    intent.putExtra(MediaStore.EXTRA_OUTPUT, outputFileUri);
    return intent;
  }

  private Intent getVideoIntent() {
    Intent intent = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);
    outputFileUri = getOutputUri(MediaStore.ACTION_VIDEO_CAPTURE);
    intent.putExtra(MediaStore.EXTRA_OUTPUT, outputFileUri);
    return intent;
  }

  private Intent getFileChooserIntent(String acceptTypes) {
    String _acceptTypes = acceptTypes;
    if (acceptTypes.isEmpty()) {
      _acceptTypes = DEFAULT_MIME_TYPES;
    }
    if (acceptTypes.matches("\\.\\w+")) {
      _acceptTypes = getMimeTypeFromExtension(acceptTypes.replace(".", ""));
    }
    Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
    intent.addCategory(Intent.CATEGORY_OPENABLE);
    intent.setType(_acceptTypes);
    return intent;
  }

  @RequiresApi(api = Build.VERSION_CODES.KITKAT)
  private Intent getFileChooserIntent(String[] acceptTypes, boolean allowMultiple) {
    Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
    intent.addCategory(Intent.CATEGORY_OPENABLE);
    intent.setType("*/*");
    intent.putExtra(Intent.EXTRA_MIME_TYPES, getAcceptedMimeType(acceptTypes));
    intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, allowMultiple);
    return intent;
  }

  private Boolean acceptsImages(String types) {
    String mimeType = types;
    if (types.matches("\\.\\w+")) {
      mimeType = getMimeTypeFromExtension(types.replace(".", ""));
    }
    return mimeType.isEmpty() || mimeType.toLowerCase().contains("image");
  }

  private Boolean acceptsImages(String[] types) {
    String[] mimeTypes = getAcceptedMimeType(types);
    return isArrayEmpty(mimeTypes) || arrayContainsString(mimeTypes, "image");
  }

  private Boolean acceptsVideo(String types) {
    String mimeType = types;
    if (types.matches("\\.\\w+")) {
      mimeType = getMimeTypeFromExtension(types.replace(".", ""));
    }
    return mimeType.isEmpty() || mimeType.toLowerCase().contains("video");
  }

  private Boolean acceptsVideo(String[] types) {
    String[] mimeTypes = getAcceptedMimeType(types);
    return isArrayEmpty(mimeTypes) || arrayContainsString(mimeTypes, "video");
  }

  private Boolean arrayContainsString(String[] array, String pattern) {
    for (String content : array) {
      if (content.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  private String[] getAcceptedMimeType(String[] types) {
    if (isArrayEmpty(types)) {
      return new String[]{DEFAULT_MIME_TYPES};
    }
    String[] mimeTypes = new String[types.length];
    for (int i = 0; i < types.length; i++) {
      String t = types[i];
      // convert file extensions to mime types
      if (t.matches("\\.\\w+")) {
        String mimeType = getMimeTypeFromExtension(t.replace(".", ""));
        mimeTypes[i] = mimeType;
      } else {
        mimeTypes[i] = t;
      }
    }
    return mimeTypes;
  }

  private String getMimeTypeFromExtension(String extension) {
    String type = null;
    if (extension != null) {
      type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
    }
    return type;
  }

  private Uri getOutputUri(String intentType) {
    File capturedFile = null;
    try {
      capturedFile = getCapturedFile(intentType);
    } catch (IOException e) {
      Log.e(LOG_TAG, "Error occurred while creating the File", e);
      e.printStackTrace();
    }

    // for versions below 6.0 (23) we use the old File creation & permissions model
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      return Uri.fromFile(capturedFile);
    }

    Activity activity = inAppBrowserActivity != null ? inAppBrowserActivity : Shared.activity;
    // for versions 6.0+ (23) we use the FileProvider to avoid runtime permissions
    String packageName = activity.getApplicationContext().getPackageName();
    return FileProvider.getUriForFile(activity.getApplicationContext(), packageName + "." + fileProviderAuthorityExtension, capturedFile);
  }

  private File getCapturedFile(String intentType) throws IOException {
    String prefix = "";
    String suffix = "";
    String dir = "";
    String filename = "";

    if (intentType.equals(MediaStore.ACTION_IMAGE_CAPTURE)) {
      prefix = "image-";
      suffix = ".jpg";
      dir = Environment.DIRECTORY_PICTURES;
    } else if (intentType.equals(MediaStore.ACTION_VIDEO_CAPTURE)) {
      prefix = "video-";
      suffix = ".mp4";
      dir = Environment.DIRECTORY_MOVIES;
    }

    filename = prefix + String.valueOf(System.currentTimeMillis()) + suffix;

    // for versions below 6.0 (23) we use the old File creation & permissions model
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      // only this Directory works on all tested Android versions
      // ctx.getExternalFilesDir(dir) was failing on Android 5.0 (sdk 21)
      File storageDir = Environment.getExternalStoragePublicDirectory(dir);
      return new File(storageDir, filename);
    }

    Activity activity = inAppBrowserActivity != null ? inAppBrowserActivity : Shared.activity;
    File storageDir = activity.getApplicationContext().getExternalFilesDir(null);
    return File.createTempFile(filename, suffix, storageDir);
  }

  private Boolean isArrayEmpty(String[] arr) {
    // when our array returned from getAcceptTypes() has no values set from the webview
    // i.e. <input type="file" />, without any "accept" attr
    // will be an array with one empty string element, afaik
    return arr.length == 0 || (arr.length == 1 && arr[0].length() == 0);
  }

  @Override
  public void onPermissionRequest(final PermissionRequest request) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      Map<String, Object> obj = new HashMap<>();
      if (inAppBrowserActivity != null)
        obj.put("uuid", inAppBrowserActivity.uuid);
      obj.put("origin", request.getOrigin().toString());
      obj.put("resources", Arrays.asList(request.getResources()));
      channel.invokeMethod("onPermissionRequest", obj, new MethodChannel.Result() {
        @Override
        public void success(Object response) {
          if (response != null) {
            Map<String, Object> responseMap = (Map<String, Object>) response;
            Integer action = (Integer) responseMap.get("action");
            List<String> resourceList = (List<String>) responseMap.get("resources");
            if (resourceList == null)
              resourceList = new ArrayList<String>();
            String[] resources = new String[resourceList.size()];
            resources = resourceList.toArray(resources);
            if (action != null) {
              switch (action) {
                case 1:
                  request.grant(resources);
                  return;
                case 0:
                default:
                  request.deny();
                  return;
              }
            }
          }
          request.deny();
        }

        @Override
        public void error(String s, String s1, Object o) {
          Log.e(LOG_TAG, s + ", " + s1);
        }

        @Override
        public void notImplemented() {
          request.deny();
        }
      });
    }
  }
}
