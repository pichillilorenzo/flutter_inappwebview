import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util.dart';

void main() {
  skippableGroup('Support methods', () {
    skippableTest('WebMessageChannel support methods are callable', () {
      expect(
        () =>
            WebMessageChannel.isClassSupported(platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => WebMessageChannel.isMethodSupported(
          PlatformWebMessageChannelMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => WebMessageChannel.isPropertySupported(
          PlatformWebMessageChannelCreationParamsProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('WebMessageListener support methods are callable', () {
      expect(
        () => WebMessageListener.isClassSupported(
            platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => WebMessageListener.isMethodSupported(
          PlatformWebMessageListenerMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => WebMessageListener.isPropertySupported(
          PlatformWebMessageListenerCreationParamsProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('WebViewEnvironment support methods are callable', () {
      expect(
        () => WebViewEnvironment.isClassSupported(
            platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => WebViewEnvironment.isMethodSupported(
          PlatformWebViewEnvironmentMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => WebViewEnvironment.isPropertySupported(
          PlatformWebViewEnvironmentCreationParamsProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('HeadlessInAppWebView support methods are callable', () {
      expect(
        () => HeadlessInAppWebView.isClassSupported(
            platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => HeadlessInAppWebView.isMethodSupported(
          PlatformHeadlessInAppWebViewMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => HeadlessInAppWebView.isPropertySupported(
          PlatformHeadlessInAppWebViewCreationParamsProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('WebStorage support methods are callable', () {
      expect(
        () => WebStorage.isClassSupported(platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => WebStorage.isMethodSupported(
          PlatformWebStorageMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => WebStorage.isPropertySupported(
          PlatformWebStorageCreationParamsProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => WebStorage.isPropertySupported(
          PlatformWebStorageProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('LocalStorage support methods are callable', () {
      expect(
        () => LocalStorage.isClassSupported(platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => LocalStorage.isMethodSupported(
          PlatformLocalStorageMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => LocalStorage.isPropertySupported(
          PlatformStorageCreationParamsProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('SessionStorage support methods are callable', () {
      expect(
        () => SessionStorage.isClassSupported(platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => SessionStorage.isMethodSupported(
          PlatformSessionStorageMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => SessionStorage.isPropertySupported(
          PlatformStorageCreationParamsProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('WebStorageManager support methods are callable', () {
      expect(
        () =>
            WebStorageManager.isClassSupported(platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => WebStorageManager.isMethodSupported(
          PlatformWebStorageManagerMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('PullToRefreshController support methods are callable', () {
      expect(
        () => PullToRefreshController.isClassSupported(
            platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => PullToRefreshController.isMethodSupported(
          PlatformPullToRefreshControllerMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => PullToRefreshController.isPropertySupported(
          PlatformPullToRefreshControllerCreationParamsProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('InAppWebView support methods are callable', () {
      expect(
        () => InAppWebView.isClassSupported(platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => InAppWebView.isPropertySupported(
          PlatformInAppWebViewWidgetCreationParamsProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('InAppWebViewSettings support methods are callable', () {
      expect(
        () => InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('InAppWebViewController support methods are callable', () {
      expect(
        () => InAppWebViewController.isClassSupported(
            platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => InAppWebViewController.isMethodSupported(
          PlatformInAppWebViewControllerMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => InAppWebViewController.isPropertySupported(
          PlatformInAppWebViewControllerProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('InAppBrowser support methods are callable', () {
      expect(
        () => InAppBrowser.isClassSupported(platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => InAppBrowser.isMethodSupported(
          PlatformInAppBrowserMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => InAppBrowser.isPropertySupported(
          PlatformInAppBrowserProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('ChromeSafariBrowser support methods are callable', () {
      expect(
        () => ChromeSafariBrowser.isClassSupported(
            platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => ChromeSafariBrowser.isMethodSupported(
          PlatformChromeSafariBrowserMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('WebAuthenticationSession support methods are callable', () {
      expect(
        () => WebAuthenticationSession.isClassSupported(
            platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => WebAuthenticationSession.isMethodSupported(
          PlatformWebAuthenticationSessionMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => WebAuthenticationSession.isPropertySupported(
          PlatformWebAuthenticationSessionProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('CookieManager support methods are callable', () {
      expect(
        () => CookieManager.isClassSupported(platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => CookieManager.isMethodSupported(
          PlatformCookieManagerMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => CookieManager.isPropertySupported(
          PlatformCookieManagerCreationParamsProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('ProcessGlobalConfig support methods are callable', () {
      expect(
        () => ProcessGlobalConfig.isClassSupported(
            platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => ProcessGlobalConfig.isMethodSupported(
          PlatformProcessGlobalConfigMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('ServiceWorkerController support methods are callable', () {
      expect(
        () => ServiceWorkerController.isClassSupported(
            platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => ServiceWorkerController.isMethodSupported(
          PlatformServiceWorkerControllerMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('ProxyController support methods are callable', () {
      expect(
        () => ProxyController.isClassSupported(platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => ProxyController.isMethodSupported(
          PlatformProxyControllerMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('PrintJobController support methods are callable', () {
      expect(
        () => PrintJobController.isClassSupported(
            platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => PrintJobController.isMethodSupported(
          PlatformPrintJobControllerMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => PrintJobController.isPropertySupported(
          PlatformPrintJobControllerCreationParamsProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => PrintJobController.isPropertySupported(
          PlatformPrintJobControllerProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('TracingController support methods are callable', () {
      expect(
        () =>
            TracingController.isClassSupported(platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => TracingController.isMethodSupported(
          PlatformTracingControllerMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('FindInteractionController support methods are callable', () {
      expect(
        () => FindInteractionController.isClassSupported(
            platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => FindInteractionController.isMethodSupported(
          PlatformFindInteractionControllerMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
      expect(
        () => FindInteractionController.isPropertySupported(
          PlatformFindInteractionControllerCreationParamsProperty.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });

    skippableTest('HttpAuthCredentialDatabase support methods are callable',
        () {
      expect(
        () => HttpAuthCredentialDatabase.isClassSupported(
            platform: defaultTargetPlatform),
        returnsNormally,
      );
      expect(
        () => HttpAuthCredentialDatabase.isMethodSupported(
          PlatformHttpAuthCredentialDatabaseMethod.values.first,
          platform: defaultTargetPlatform,
        ),
        returnsNormally,
      );
    });
  });
}
