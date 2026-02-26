import 'dart:async';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../web_storage_manager.dart';

///Class that is used to manage the JavaScript storage APIs provided by the WebView.
///It manages the Application Cache API, the Web SQL Database API and the HTML5 Web Storage API.
///
///Use [WebStorageManager] instead.
@Deprecated("Use WebStorageManager instead")
class AndroidWebStorageManager {
  ///Gets the origins currently using either the Application Cache or Web SQL Database APIs.
  Future<List<AndroidWebStorageOrigin>> getOrigins() async {
    List<AndroidWebStorageOrigin> originsList = [];

    List<WebStorageOrigin> origins = await WebStorageManager.instance()
        .getOrigins();

    for (var origin in origins) {
      originsList.add(
        AndroidWebStorageOrigin(
          origin: origin.origin,
          quota: origin.quota,
          usage: origin.usage,
        ),
      );
    }

    return originsList;
  }

  ///Clears all storage currently being used by the JavaScript storage APIs.
  ///This includes the Application Cache, Web SQL Database and the HTML5 Web Storage APIs.
  Future<void> deleteAllData() async {
    await WebStorageManager.instance().deleteAllData();
  }

  ///Clears the storage currently being used by both the Application Cache and Web SQL Database APIs by the given [origin].
  ///The origin is specified using its string representation.
  Future<void> deleteOrigin({required String origin}) async {
    await WebStorageManager.instance().deleteOrigin(origin: origin);
  }

  ///Gets the storage quota for the Web SQL Database API for the given [origin].
  ///The quota is given in bytes and the origin is specified using its string representation.
  ///Note that a quota is not enforced on a per-origin basis for the Application Cache API.
  Future<int> getQuotaForOrigin({required String origin}) async {
    return await WebStorageManager.instance().getQuotaForOrigin(origin: origin);
  }

  ///Gets the amount of storage currently being used by both the Application Cache and Web SQL Database APIs by the given [origin].
  ///The amount is given in bytes and the origin is specified using its string representation.
  Future<int> getUsageForOrigin({required String origin}) async {
    return await WebStorageManager.instance().getUsageForOrigin(origin: origin);
  }
}
