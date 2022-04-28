package com.pichillilorenzo.flutter_inappwebview.credential_database;

import android.os.Build;
import android.webkit.WebViewDatabase;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.pichillilorenzo.flutter_inappwebview.InAppWebViewFlutterPlugin;
import com.pichillilorenzo.flutter_inappwebview.types.URLCredential;
import com.pichillilorenzo.flutter_inappwebview.types.URLProtectionSpace;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

@RequiresApi(api = Build.VERSION_CODES.O)
public class CredentialDatabaseHandler implements MethodChannel.MethodCallHandler {

  static final String LOG_TAG = "CredentialDatabaseHandler";

  public MethodChannel channel;
  public static CredentialDatabase credentialDatabase;
  @Nullable
  public InAppWebViewFlutterPlugin plugin;

  public CredentialDatabaseHandler(final InAppWebViewFlutterPlugin plugin) {
    this.plugin = plugin;
    channel = new MethodChannel(plugin.messenger, "com.pichillilorenzo/flutter_inappwebview_credential_database");
    channel.setMethodCallHandler(this);
    credentialDatabase = CredentialDatabase.getInstance(plugin.applicationContext);
  }

  @Override
  public void onMethodCall(MethodCall call, @NonNull MethodChannel.Result result) {
    switch (call.method) {
      case "getAllAuthCredentials":
        {
          List<Map<String, Object>> allCredentials = new ArrayList<>();
          List<URLProtectionSpace> protectionSpaces = credentialDatabase.protectionSpaceDao.getAll();
          for (URLProtectionSpace protectionSpace : protectionSpaces) {
            List<Map<String, Object>> credentials = new ArrayList<>();
            for (URLCredential credential : credentialDatabase.credentialDao.getAllByProtectionSpaceId(protectionSpace.getId())) {
              credentials.add(credential.toMap());
            }
            Map<String, Object> obj = new HashMap<>();
            obj.put("protectionSpace", protectionSpace.toMap());
            obj.put("credentials", credentials);
            allCredentials.add(obj);
          }
          result.success(allCredentials);
        }
        break;
      case "getHttpAuthCredentials":
        {
          String host = (String) call.argument("host");
          String protocol = (String) call.argument("protocol");
          String realm = (String) call.argument("realm");
          Integer port = (Integer) call.argument("port");

          List<Map<String, Object>> credentials = new ArrayList<>();
          for (URLCredential credential : credentialDatabase.getHttpAuthCredentials(host, protocol, realm, port)) {
            credentials.add(credential.toMap());
          }
          result.success(credentials);
        }
        break;
      case "setHttpAuthCredential":
        {
          String host = (String) call.argument("host");
          String protocol = (String) call.argument("protocol");
          String realm = (String) call.argument("realm");
          Integer port = (Integer) call.argument("port");
          String username = (String) call.argument("username");
          String password = (String) call.argument("password");

          credentialDatabase.setHttpAuthCredential(host, protocol, realm, port, username, password);

          result.success(true);
        }
        break;
      case "removeHttpAuthCredential":
        {
          String host = (String) call.argument("host");
          String protocol = (String) call.argument("protocol");
          String realm = (String) call.argument("realm");
          Integer port = (Integer) call.argument("port");
          String username = (String) call.argument("username");
          String password = (String) call.argument("password");

          credentialDatabase.removeHttpAuthCredential(host, protocol, realm, port, username, password);

          result.success(true);
        }
        break;
      case "removeHttpAuthCredentials":
        {
          String host = (String) call.argument("host");
          String protocol = (String) call.argument("protocol");
          String realm = (String) call.argument("realm");
          Integer port = (Integer) call.argument("port");

          credentialDatabase.removeHttpAuthCredentials(host, protocol, realm, port);

          result.success(true);
        }
        break;
      case "clearAllAuthCredentials":
        credentialDatabase.clearAllAuthCredentials();
        if (plugin != null && plugin.applicationContext != null) {
          WebViewDatabase.getInstance(plugin.applicationContext).clearHttpAuthUsernamePassword();
        }
        result.success(true);
        break;
      default:
        result.notImplemented();
    }
  }

  public void dispose() {
    channel.setMethodCallHandler(null);
    plugin = null;
  }

}
