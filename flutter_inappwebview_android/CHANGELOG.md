## 1.0.6

- Fixed "getFavicons: _TypeError: type '_Map<String, dynamic>' is not a subtype of type 'Iterable<dynamic>'" [#1897](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1897)
- Fixed "onClosed not considering back navigation or up button / close button in ChromeSafariBrowser when using noHistory: true" [#1882](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1882)

## 1.0.5

- Call `super.dispose();` on `InAppBrowser` and `ChromeSafari` implementations 

## 1.0.4

- Throw platform exception when ProcessGlobalConfig.apply throws an error on the native side to be able to catch it on Flutter side

## 1.0.3

- Updated `ContentBlockerHandler` CSS_DISPLAY_NONE action type and `JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_JS_SOURCE` javascript implementation code

## 1.0.2

- Updated `flutter_inappwebview_platform_interface` version dependency to `1.0.2` 
- Fixed "Crash when starting ChromeSafariBrowser on Android java.lang.NoSuchMethodError: No virtual method isEngagementSignalsApiAvailable" [#1881](https://github.com/pichillilorenzo/flutter_inappwebview/issues/1881)

## 1.0.1

- Updated README

## 1.0.0

Initial release.
