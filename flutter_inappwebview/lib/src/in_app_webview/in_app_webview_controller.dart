import 'dart:core';

import 'package:flutter/services.dart';

import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../print_job/main.dart';
import '../web_message/main.dart';
import '../web_storage/web_storage.dart';

import 'android/in_app_webview_controller.dart';
import 'apple/in_app_webview_controller.dart';

///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController}
class InAppWebViewController {
  ///Use [InAppWebViewController] instead.
  @Deprecated("Use InAppWebViewController instead")
  late AndroidInAppWebViewController android;

  ///Use [InAppWebViewController] instead.
  @Deprecated("Use InAppWebViewController instead")
  late IOSInAppWebViewController ios;

  /// Constructs a [InAppWebViewController].
  ///
  /// See [InAppWebViewController.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  InAppWebViewController.fromPlatformCreationParams({
    required PlatformInAppWebViewControllerCreationParams params,
  }) : this.fromPlatform(platform: PlatformInAppWebViewController(params));

  /// Constructs a [InAppWebViewController] from a specific platform implementation.
  InAppWebViewController.fromPlatform({required this.platform}) {
    android = AndroidInAppWebViewController(controller: this.platform);
    ios = IOSInAppWebViewController(controller: this.platform);
  }

  /// Implementation of [PlatformInAppWebViewController] for the current platform.
  final PlatformInAppWebViewController platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.webStorage}
  WebStorage get webStorage =>
      WebStorage.fromPlatform(platform: platform.webStorage);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getUrl}
  Future<WebUri?> getUrl() => platform.getUrl();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getTitle}
  Future<String?> getTitle() => platform.getTitle();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getProgress}
  Future<int?> getProgress() => platform.getProgress();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getHtml}
  Future<String?> getHtml() => platform.getHtml();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getFavicons}
  Future<List<Favicon>> getFavicons() => platform.getFavicons();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadUrl}
  Future<void> loadUrl(
          {required URLRequest urlRequest,
          @Deprecated('Use allowingReadAccessTo instead')
          Uri? iosAllowingReadAccessTo,
          WebUri? allowingReadAccessTo}) =>
      platform.loadUrl(
          urlRequest: urlRequest,
          iosAllowingReadAccessTo: iosAllowingReadAccessTo,
          allowingReadAccessTo: allowingReadAccessTo);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.postUrl}
  Future<void> postUrl({required WebUri url, required Uint8List postData}) =>
      platform.postUrl(url: url, postData: postData);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadData}
  Future<void> loadData(
          {required String data,
          String mimeType = "text/html",
          String encoding = "utf8",
          WebUri? baseUrl,
          @Deprecated('Use historyUrl instead') Uri? androidHistoryUrl,
          WebUri? historyUrl,
          @Deprecated('Use allowingReadAccessTo instead')
          Uri? iosAllowingReadAccessTo,
          WebUri? allowingReadAccessTo}) =>
      platform.loadData(
          data: data,
          mimeType: mimeType,
          encoding: encoding,
          baseUrl: baseUrl,
          androidHistoryUrl: androidHistoryUrl,
          historyUrl: historyUrl,
          iosAllowingReadAccessTo: iosAllowingReadAccessTo,
          allowingReadAccessTo: allowingReadAccessTo);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadFile}
  Future<void> loadFile({required String assetFilePath}) =>
      platform.loadFile(assetFilePath: assetFilePath);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.reload}
  Future<void> reload() => platform.reload();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goBack}
  Future<void> goBack() => platform.goBack();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBack}
  Future<bool> canGoBack() => platform.canGoBack();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goForward}
  Future<void> goForward() => platform.goForward();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoForward}
  Future<bool> canGoForward() => platform.canGoForward();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goBackOrForward}
  Future<void> goBackOrForward({required int steps}) =>
      platform.goBackOrForward(steps: steps);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canGoBackOrForward}
  Future<bool> canGoBackOrForward({required int steps}) =>
      platform.canGoBackOrForward(steps: steps);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.goTo}
  Future<void> goTo({required WebHistoryItem historyItem}) =>
      platform.goTo(historyItem: historyItem);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isLoading}
  Future<bool> isLoading() => platform.isLoading();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.stopLoading}
  Future<void> stopLoading() => platform.stopLoading();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.evaluateJavascript}
  Future<dynamic> evaluateJavascript(
          {required String source, ContentWorld? contentWorld}) =>
      platform.evaluateJavascript(source: source, contentWorld: contentWorld);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromUrl}
  Future<void> injectJavascriptFileFromUrl(
          {required WebUri urlFile,
          ScriptHtmlTagAttributes? scriptHtmlTagAttributes}) =>
      platform.injectJavascriptFileFromUrl(
          urlFile: urlFile, scriptHtmlTagAttributes: scriptHtmlTagAttributes);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectJavascriptFileFromAsset}
  Future<dynamic> injectJavascriptFileFromAsset(
          {required String assetFilePath}) =>
      platform.injectJavascriptFileFromAsset(assetFilePath: assetFilePath);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSCode}
  Future<void> injectCSSCode({required String source}) =>
      platform.injectCSSCode(source: source);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromUrl}
  Future<void> injectCSSFileFromUrl(
          {required WebUri urlFile,
          CSSLinkHtmlTagAttributes? cssLinkHtmlTagAttributes}) =>
      platform.injectCSSFileFromUrl(
          urlFile: urlFile, cssLinkHtmlTagAttributes: cssLinkHtmlTagAttributes);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.injectCSSFileFromAsset}
  Future<void> injectCSSFileFromAsset({required String assetFilePath}) =>
      platform.injectCSSFileFromAsset(assetFilePath: assetFilePath);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addJavaScriptHandler}
  void addJavaScriptHandler(
          {required String handlerName, required Function callback}) =>
      platform.addJavaScriptHandler(
          handlerName: handlerName, callback: callback);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeJavaScriptHandler}
  Function? removeJavaScriptHandler({required String handlerName}) =>
      platform.removeJavaScriptHandler(handlerName: handlerName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasJavaScriptHandler}
  bool hasJavaScriptHandler({required String handlerName}) =>
      platform.hasJavaScriptHandler(handlerName: handlerName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.takeScreenshot}
  Future<Uint8List?> takeScreenshot(
          {ScreenshotConfiguration? screenshotConfiguration}) =>
      platform.takeScreenshot(screenshotConfiguration: screenshotConfiguration);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setOptions}
  @Deprecated('Use setSettings instead')
  Future<void> setOptions({required InAppWebViewGroupOptions options}) =>
      platform.setOptions(options: options);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getOptions}
  @Deprecated('Use getSettings instead')
  Future<InAppWebViewGroupOptions?> getOptions() => platform.getOptions();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setSettings}
  Future<void> setSettings({required InAppWebViewSettings settings}) =>
      platform.setSettings(settings: settings);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSettings}
  Future<InAppWebViewSettings?> getSettings() => platform.getSettings();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCopyBackForwardList}
  Future<WebHistory?> getCopyBackForwardList() =>
      platform.getCopyBackForwardList();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearCache}
  @Deprecated("Use InAppWebViewController.clearAllCache instead")
  Future<void> clearCache() => platform.clearCache();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.findAllAsync}
  @Deprecated("Use FindInteractionController.findAll instead")
  Future<void> findAllAsync({required String find}) =>
      platform.findAllAsync(find: find);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.findNext}
  @Deprecated("Use FindInteractionController.findNext instead")
  Future<void> findNext({required bool forward}) =>
      platform.findNext(forward: forward);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearMatches}
  @Deprecated("Use FindInteractionController.clearMatches instead")
  Future<void> clearMatches() => platform.clearMatches();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getTRexRunnerHtml}
  @Deprecated("Use tRexRunnerHtml instead")
  Future<String> getTRexRunnerHtml() => platform.getTRexRunnerHtml();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getTRexRunnerCss}
  @Deprecated("Use tRexRunnerCss instead")
  Future<String> getTRexRunnerCss() => platform.getTRexRunnerCss();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.scrollTo}
  Future<void> scrollTo(
          {required int x, required int y, bool animated = false}) =>
      platform.scrollTo(x: x, y: y, animated: animated);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.scrollBy}
  Future<void> scrollBy(
          {required int x, required int y, bool animated = false}) =>
      platform.scrollBy(x: x, y: y, animated: animated);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pauseTimers}
  Future<void> pauseTimers() => platform.pauseTimers();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.resumeTimers}
  Future<void> resumeTimers() => platform.resumeTimers();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.printCurrentPage}
  Future<PrintJobController?> printCurrentPage(
      {PrintJobSettings? settings}) async {
    final printJobControllerPlatform =
        await platform.printCurrentPage(settings: settings);
    if (printJobControllerPlatform == null) {
      return null;
    }
    return PrintJobController.fromPlatform(
        platform: printJobControllerPlatform);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getContentHeight}
  Future<int?> getContentHeight() => platform.getContentHeight();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getContentWidth}
  Future<int?> getContentWidth() => platform.getContentWidth();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomBy}
  Future<void> zoomBy(
          {required double zoomFactor,
          @Deprecated('Use animated instead') bool? iosAnimated,
          bool animated = false}) =>
      platform.zoomBy(
          zoomFactor: zoomFactor, iosAnimated: iosAnimated, animated: animated);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getOriginalUrl}
  Future<WebUri?> getOriginalUrl() => platform.getOriginalUrl();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getZoomScale}
  Future<double?> getZoomScale() => platform.getZoomScale();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScale}
  @Deprecated('Use getZoomScale instead')
  Future<double?> getScale() => platform.getScale();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSelectedText}
  Future<String?> getSelectedText() => platform.getSelectedText();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getHitTestResult}
  Future<InAppWebViewHitTestResult?> getHitTestResult() =>
      platform.getHitTestResult();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocus}
  Future<bool?> requestFocus(
          {FocusDirection? direction,
          InAppWebViewRect? previouslyFocusedRect}) =>
      platform.requestFocus(
          direction: direction, previouslyFocusedRect: previouslyFocusedRect);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearFocus}
  Future<void> clearFocus() => platform.clearFocus();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setInputMethodEnabled}
  Future<void> setInputMethodEnabled(bool enabled) =>
      platform.setInputMethodEnabled(enabled);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.showInputMethod}
  Future<void> showInputMethod() => platform.showInputMethod();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hideInputMethod}
  Future<void> hideInputMethod() => platform.hideInputMethod();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setContextMenu}
  Future<void> setContextMenu(ContextMenu? contextMenu) =>
      platform.setContextMenu(contextMenu);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestFocusNodeHref}
  Future<RequestFocusNodeHrefResult?> requestFocusNodeHref() =>
      platform.requestFocusNodeHref();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestImageRef}
  Future<RequestImageRefResult?> requestImageRef() =>
      platform.requestImageRef();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaTags}
  Future<List<MetaTag>> getMetaTags() => platform.getMetaTags();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMetaThemeColor}
  Future<Color?> getMetaThemeColor() => platform.getMetaThemeColor();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollX}
  Future<int?> getScrollX() => platform.getScrollX();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getScrollY}
  Future<int?> getScrollY() => platform.getScrollY();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCertificate}
  Future<SslCertificate?> getCertificate() => platform.getCertificate();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScript}
  Future<void> addUserScript({required UserScript userScript}) =>
      platform.addUserScript(userScript: userScript);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addUserScripts}
  Future<void> addUserScripts({required List<UserScript> userScripts}) =>
      platform.addUserScripts(userScripts: userScripts);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScript}
  Future<bool> removeUserScript({required UserScript userScript}) =>
      platform.removeUserScript(userScript: userScript);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScriptsByGroupName}
  Future<void> removeUserScriptsByGroupName({required String groupName}) =>
      platform.removeUserScriptsByGroupName(groupName: groupName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeUserScripts}
  Future<void> removeUserScripts({required List<UserScript> userScripts}) =>
      platform.removeUserScripts(userScripts: userScripts);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeAllUserScripts}
  Future<void> removeAllUserScripts() => platform.removeAllUserScripts();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasUserScript}
  bool hasUserScript({required UserScript userScript}) =>
      platform.hasUserScript(userScript: userScript);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.callAsyncJavaScript}
  Future<CallAsyncJavaScriptResult?> callAsyncJavaScript(
          {required String functionBody,
          Map<String, dynamic> arguments = const <String, dynamic>{},
          ContentWorld? contentWorld}) =>
      platform.callAsyncJavaScript(
          functionBody: functionBody,
          arguments: arguments,
          contentWorld: contentWorld);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.saveWebArchive}
  Future<String?> saveWebArchive(
          {required String filePath, bool autoname = false}) =>
      platform.saveWebArchive(filePath: filePath, autoname: autoname);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isSecureContext}
  Future<bool> isSecureContext() => platform.isSecureContext();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createWebMessageChannel}
  Future<WebMessageChannel?> createWebMessageChannel() async {
    final webMessagePlatform = await platform.createWebMessageChannel();
    if (webMessagePlatform == null) {
      return null;
    }
    return WebMessageChannel.fromPlatform(platform: webMessagePlatform);
  }

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.postWebMessage}
  Future<void> postWebMessage(
          {required WebMessage message, WebUri? targetOrigin}) =>
      platform.postWebMessage(message: message, targetOrigin: targetOrigin);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addWebMessageListener}
  Future<void> addWebMessageListener(WebMessageListener webMessageListener) =>
      platform.addWebMessageListener(webMessageListener.platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasWebMessageListener}
  bool hasWebMessageListener(WebMessageListener webMessageListener) =>
      platform.hasWebMessageListener(webMessageListener.platform);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollVertically}
  Future<bool> canScrollVertically() => platform.canScrollVertically();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.canScrollHorizontally}
  Future<bool> canScrollHorizontally() => platform.canScrollHorizontally();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.startSafeBrowsing}
  Future<bool> startSafeBrowsing() => platform.startSafeBrowsing();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearSslPreferences}
  Future<void> clearSslPreferences() => platform.clearSslPreferences();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pause}
  Future<void> pause() => platform.pause();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.resume}
  Future<void> resume() => platform.resume();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pageDown}
  Future<bool> pageDown({required bool bottom}) =>
      platform.pageDown(bottom: bottom);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pageUp}
  Future<bool> pageUp({required bool top}) => platform.pageUp(top: top);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomIn}
  Future<bool> zoomIn() => platform.zoomIn();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.zoomOut}
  Future<bool> zoomOut() => platform.zoomOut();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearHistory}
  Future<void> clearHistory() => platform.clearHistory();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.reloadFromOrigin}
  Future<void> reloadFromOrigin() => platform.reloadFromOrigin();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createPdf}
  Future<Uint8List?> createPdf(
          {@Deprecated("Use pdfConfiguration instead")
          // ignore: deprecated_member_use_from_same_package
          IOSWKPDFConfiguration? iosWKPdfConfiguration,
          PDFConfiguration? pdfConfiguration}) =>
      platform.createPdf(
          iosWKPdfConfiguration: iosWKPdfConfiguration,
          pdfConfiguration: pdfConfiguration);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.createWebArchiveData}
  Future<Uint8List?> createWebArchiveData() => platform.createWebArchiveData();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.hasOnlySecureContent}
  Future<bool> hasOnlySecureContent() => platform.hasOnlySecureContent();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.pauseAllMediaPlayback}
  Future<void> pauseAllMediaPlayback() => platform.pauseAllMediaPlayback();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setAllMediaPlaybackSuspended}
  Future<void> setAllMediaPlaybackSuspended({required bool suspended}) =>
      platform.setAllMediaPlaybackSuspended(suspended: suspended);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.closeAllMediaPresentations}
  Future<void> closeAllMediaPresentations() =>
      platform.closeAllMediaPresentations();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.requestMediaPlaybackState}
  Future<MediaPlaybackState?> requestMediaPlaybackState() =>
      platform.requestMediaPlaybackState();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isInFullscreen}
  Future<bool> isInFullscreen() => platform.isInFullscreen();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearFormData}
  Future<void> clearFormData() => platform.clearFormData();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCameraCaptureState}
  Future<MediaCaptureState?> getCameraCaptureState() =>
      platform.getCameraCaptureState();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setCameraCaptureState}
  Future<void> setCameraCaptureState({required MediaCaptureState state}) =>
      platform.setCameraCaptureState(state: state);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getMicrophoneCaptureState}
  Future<MediaCaptureState?> getMicrophoneCaptureState() =>
      platform.getMicrophoneCaptureState();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setMicrophoneCaptureState}
  Future<void> setMicrophoneCaptureState({required MediaCaptureState state}) =>
      platform.setMicrophoneCaptureState(state: state);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.loadSimulatedRequest}
  Future<void> loadSimulatedRequest(
          {required URLRequest urlRequest,
          required Uint8List data,
          URLResponse? urlResponse}) =>
      platform.loadSimulatedRequest(urlRequest: urlRequest, data: data);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.openDevTools}
  Future<void> openDevTools() => platform.openDevTools();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.callDevToolsProtocolMethod}
  Future<dynamic> callDevToolsProtocolMethod(
          {required String methodName, Map<String, dynamic>? parameters}) =>
      platform.callDevToolsProtocolMethod(
          methodName: methodName, parameters: parameters);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.addDevToolsProtocolEventListener}
  Future<void> addDevToolsProtocolEventListener(
          {required String eventName,
          required Function(dynamic data) callback}) =>
      platform.addDevToolsProtocolEventListener(
          eventName: eventName, callback: callback);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.removeDevToolsProtocolEventListener}
  Future<void> removeDevToolsProtocolEventListener(
          {required String eventName}) =>
      platform.removeDevToolsProtocolEventListener(eventName: eventName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isInterfaceSupported}
  Future<bool> isInterfaceSupported(WebViewInterface interface) =>
      platform.isInterfaceSupported(interface);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.saveState}
  Future<Uint8List?> saveState() => platform.saveState();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.restoreState}
  Future<bool> restoreState(Uint8List state) => platform.restoreState(state);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getIFrameId}
  Future<String?> getIFrameId() => platform.getIFrameId();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getDefaultUserAgent}
  static Future<String> getDefaultUserAgent() =>
      PlatformInAppWebViewController.static().getDefaultUserAgent();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearClientCertPreferences}
  static Future<void> clearClientCertPreferences() =>
      PlatformInAppWebViewController.static().clearClientCertPreferences();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getSafeBrowsingPrivacyPolicyUrl}
  static Future<WebUri?> getSafeBrowsingPrivacyPolicyUrl() =>
      PlatformInAppWebViewController.static().getSafeBrowsingPrivacyPolicyUrl();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setSafeBrowsingWhitelist}
  @Deprecated("Use setSafeBrowsingAllowlist instead")
  static Future<bool> setSafeBrowsingWhitelist({required List<String> hosts}) =>
      PlatformInAppWebViewController.static()
          .setSafeBrowsingWhitelist(hosts: hosts);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setSafeBrowsingAllowlist}
  static Future<bool> setSafeBrowsingAllowlist({required List<String> hosts}) =>
      PlatformInAppWebViewController.static()
          .setSafeBrowsingAllowlist(hosts: hosts);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getCurrentWebViewPackage}
  static Future<WebViewPackageInfo?> getCurrentWebViewPackage() =>
      PlatformInAppWebViewController.static().getCurrentWebViewPackage();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setWebContentsDebuggingEnabled}
  static Future<void> setWebContentsDebuggingEnabled(bool debuggingEnabled) =>
      PlatformInAppWebViewController.static()
          .setWebContentsDebuggingEnabled(debuggingEnabled);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getVariationsHeader}
  static Future<String?> getVariationsHeader() =>
      PlatformInAppWebViewController.static().getVariationsHeader();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.isMultiProcessEnabled}
  static Future<bool> isMultiProcessEnabled() =>
      PlatformInAppWebViewController.static().isMultiProcessEnabled();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.disableWebView}
  static Future<void> disableWebView() =>
      PlatformInAppWebViewController.static().disableWebView();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.handlesURLScheme}
  static Future<bool> handlesURLScheme(String urlScheme) =>
      PlatformInAppWebViewController.static().handlesURLScheme(urlScheme);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.disposeKeepAlive}
  static Future<void> disposeKeepAlive(InAppWebViewKeepAlive keepAlive) =>
      PlatformInAppWebViewController.static().disposeKeepAlive(keepAlive);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.clearAllCache}
  static Future<void> clearAllCache({bool includeDiskFiles = true}) =>
      PlatformInAppWebViewController.static()
          .clearAllCache(includeDiskFiles: includeDiskFiles);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.enableSlowWholeDocumentDraw}
  static Future<void> enableSlowWholeDocumentDraw() =>
      PlatformInAppWebViewController.static().enableSlowWholeDocumentDraw();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.setJavaScriptBridgeName}
  static Future<void> setJavaScriptBridgeName(String bridgeName) =>
      PlatformInAppWebViewController.static()
          .setJavaScriptBridgeName(bridgeName);

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getJavaScriptBridgeName}
  static Future<String> getJavaScriptBridgeName() =>
      PlatformInAppWebViewController.static().getJavaScriptBridgeName();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerHtml}
  static Future<String> get tRexRunnerHtml =>
      PlatformInAppWebViewController.static().tRexRunnerHtml;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.tRexRunnerCss}
  static Future<String> get tRexRunnerCss =>
      PlatformInAppWebViewController.static().tRexRunnerCss;

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.getViewId}
  dynamic getViewId() => platform.getViewId();

  ///{@macro flutter_inappwebview_platform_interface.PlatformInAppWebViewController.dispose}
  void dispose({bool isKeepAlive = false}) =>
      platform.dispose(isKeepAlive: isKeepAlive);
}
