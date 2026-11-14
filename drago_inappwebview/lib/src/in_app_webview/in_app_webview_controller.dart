import 'dart:core';

import 'package:flutter/services.dart';
import 'package:drago_inappwebview/platform_interface/platform_interface.dart';

import '../print_job/main.dart';
import '../web_message/main.dart';
import '../web_storage/web_storage.dart';
import 'android/in_app_webview_controller.dart';
import 'apple/in_app_webview_controller.dart';

///{@macro drago_inappwebview.PlatformInAppWebViewController}
///
///{@macro drago_inappwebview.PlatformInAppWebViewController.supported_platforms}
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
    android = AndroidInAppWebViewController(controller: platform);
    ios = IOSInAppWebViewController(controller: platform);
  }

  /// Implementation of [PlatformInAppWebViewController] for the current platform.
  final PlatformInAppWebViewController platform;

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.webStorage}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.webStorage.supported_platforms}
  WebStorage get webStorage =>
      WebStorage.fromPlatform(platform: platform.webStorage);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getUrl}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getUrl.supported_platforms}
  Future<WebUri?> getUrl() => platform.getUrl();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getTitle}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getTitle.supported_platforms}
  Future<String?> getTitle() => platform.getTitle();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getFrameId}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getFrameId.supported_platforms}
  Future<int?> getFrameId() => platform.getFrameId();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getProgress}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getProgress.supported_platforms}
  Future<int?> getProgress() => platform.getProgress();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getHtml}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getHtml.supported_platforms}
  Future<String?> getHtml() => platform.getHtml();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getFavicons}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getFavicons.supported_platforms}
  Future<List<Favicon>> getFavicons() => platform.getFavicons();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getFavicon}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getFavicon.supported_platforms}
  Future<Uint8List?> getFavicon({
    required WebUri url,
    FaviconImageFormat faviconImageFormat = FaviconImageFormat.PNG,
  }) => platform.getFavicon(url: url, faviconImageFormat: faviconImageFormat);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.showSaveAsUI}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.showSaveAsUI.supported_platforms}
  Future<SaveAsUIResult?> showSaveAsUI() => platform.showSaveAsUI();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getMemoryUsageTargetLevel}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getMemoryUsageTargetLevel.supported_platforms}
  Future<MemoryUsageTargetLevel?> getMemoryUsageTargetLevel() =>
      platform.getMemoryUsageTargetLevel();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setMemoryUsageTargetLevel}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setMemoryUsageTargetLevel.supported_platforms}
  Future<void> setMemoryUsageTargetLevel(MemoryUsageTargetLevel level) =>
      platform.setMemoryUsageTargetLevel(level);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.loadUrl}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.loadUrl.supported_platforms}
  Future<void> loadUrl({
    required URLRequest urlRequest,
    @Deprecated('Use allowingReadAccessTo instead')
    Uri? iosAllowingReadAccessTo,
    WebUri? allowingReadAccessTo,
  }) => platform.loadUrl(
    urlRequest: urlRequest,
    iosAllowingReadAccessTo: iosAllowingReadAccessTo,
    allowingReadAccessTo: allowingReadAccessTo,
  );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.postUrl}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.postUrl.supported_platforms}
  Future<void> postUrl({required WebUri url, required Uint8List postData}) =>
      platform.postUrl(url: url, postData: postData);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.loadData}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.loadData.supported_platforms}
  Future<void> loadData({
    required String data,
    String mimeType = "text/html",
    String encoding = "utf8",
    WebUri? baseUrl,
    @Deprecated('Use historyUrl instead') Uri? androidHistoryUrl,
    WebUri? historyUrl,
    @Deprecated('Use allowingReadAccessTo instead')
    Uri? iosAllowingReadAccessTo,
    WebUri? allowingReadAccessTo,
  }) => platform.loadData(
    data: data,
    mimeType: mimeType,
    encoding: encoding,
    baseUrl: baseUrl,
    androidHistoryUrl: androidHistoryUrl,
    historyUrl: historyUrl,
    iosAllowingReadAccessTo: iosAllowingReadAccessTo,
    allowingReadAccessTo: allowingReadAccessTo,
  );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.loadFile}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.loadFile.supported_platforms}
  Future<void> loadFile({required String assetFilePath}) =>
      platform.loadFile(assetFilePath: assetFilePath);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.reload}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.reload.supported_platforms}
  Future<void> reload() => platform.reload();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.goBack}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.goBack.supported_platforms}
  Future<void> goBack() => platform.goBack();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.canGoBack}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.canGoBack.supported_platforms}
  Future<bool> canGoBack() => platform.canGoBack();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.goForward}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.goForward.supported_platforms}
  Future<void> goForward() => platform.goForward();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.canGoForward}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.canGoForward.supported_platforms}
  Future<bool> canGoForward() => platform.canGoForward();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.goBackOrForward}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.goBackOrForward.supported_platforms}
  Future<void> goBackOrForward({required int steps}) =>
      platform.goBackOrForward(steps: steps);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.canGoBackOrForward}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.canGoBackOrForward.supported_platforms}
  Future<bool> canGoBackOrForward({required int steps}) =>
      platform.canGoBackOrForward(steps: steps);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.goTo}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.goTo.supported_platforms}
  Future<void> goTo({required WebHistoryItem historyItem}) =>
      platform.goTo(historyItem: historyItem);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isLoading}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isLoading.supported_platforms}
  Future<bool> isLoading() => platform.isLoading();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.stopLoading}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.stopLoading.supported_platforms}
  Future<void> stopLoading() => platform.stopLoading();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.evaluateJavascript}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.evaluateJavascript.supported_platforms}
  Future<dynamic> evaluateJavascript({
    required String source,
    ContentWorld? contentWorld,
  }) => platform.evaluateJavascript(source: source, contentWorld: contentWorld);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.injectJavascriptFileFromUrl}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.injectJavascriptFileFromUrl.supported_platforms}
  Future<void> injectJavascriptFileFromUrl({
    required WebUri urlFile,
    ScriptHtmlTagAttributes? scriptHtmlTagAttributes,
  }) => platform.injectJavascriptFileFromUrl(
    urlFile: urlFile,
    scriptHtmlTagAttributes: scriptHtmlTagAttributes,
  );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.injectJavascriptFileFromAsset}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.injectJavascriptFileFromAsset.supported_platforms}
  Future<dynamic> injectJavascriptFileFromAsset({
    required String assetFilePath,
  }) => platform.injectJavascriptFileFromAsset(assetFilePath: assetFilePath);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.injectCSSCode}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.injectCSSCode.supported_platforms}
  Future<void> injectCSSCode({required String source}) =>
      platform.injectCSSCode(source: source);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.injectCSSFileFromUrl}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.injectCSSFileFromUrl.supported_platforms}
  Future<void> injectCSSFileFromUrl({
    required WebUri urlFile,
    CSSLinkHtmlTagAttributes? cssLinkHtmlTagAttributes,
  }) => platform.injectCSSFileFromUrl(
    urlFile: urlFile,
    cssLinkHtmlTagAttributes: cssLinkHtmlTagAttributes,
  );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.injectCSSFileFromAsset}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.injectCSSFileFromAsset.supported_platforms}
  Future<void> injectCSSFileFromAsset({required String assetFilePath}) =>
      platform.injectCSSFileFromAsset(assetFilePath: assetFilePath);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.addJavaScriptHandler}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.addJavaScriptHandler.supported_platforms}
  void addJavaScriptHandler({
    required String handlerName,
    required Function callback,
  }) => platform.addJavaScriptHandler(
    handlerName: handlerName,
    callback: callback,
  );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.removeJavaScriptHandler}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.removeJavaScriptHandler.supported_platforms}
  Function? removeJavaScriptHandler({required String handlerName}) =>
      platform.removeJavaScriptHandler(handlerName: handlerName);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.hasJavaScriptHandler}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.hasJavaScriptHandler.supported_platforms}
  bool hasJavaScriptHandler({required String handlerName}) =>
      platform.hasJavaScriptHandler(handlerName: handlerName);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.takeScreenshot}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.takeScreenshot.supported_platforms}
  Future<Uint8List?> takeScreenshot({
    ScreenshotConfiguration? screenshotConfiguration,
  }) =>
      platform.takeScreenshot(screenshotConfiguration: screenshotConfiguration);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setOptions}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setOptions.supported_platforms}
  @Deprecated('Use setSettings instead')
  Future<void> setOptions({required InAppWebViewGroupOptions options}) =>
      platform.setOptions(options: options);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getOptions}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getOptions.supported_platforms}
  @Deprecated('Use getSettings instead')
  Future<InAppWebViewGroupOptions?> getOptions() => platform.getOptions();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setSettings}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setSettings.supported_platforms}
  Future<void> setSettings({required InAppWebViewSettings settings}) =>
      platform.setSettings(settings: settings);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getSettings}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getSettings.supported_platforms}
  Future<InAppWebViewSettings?> getSettings() => platform.getSettings();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getCopyBackForwardList}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getCopyBackForwardList.supported_platforms}
  Future<WebHistory?> getCopyBackForwardList() =>
      platform.getCopyBackForwardList();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearCache}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearCache.supported_platforms}
  @Deprecated("Use InAppWebViewController.clearAllCache instead")
  Future<void> clearCache() => platform.clearCache();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.findAllAsync}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.findAllAsync.supported_platforms}
  @Deprecated("Use FindInteractionController.findAll instead")
  Future<void> findAllAsync({required String find}) =>
      platform.findAllAsync(find: find);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.findNext}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.findNext.supported_platforms}
  @Deprecated("Use FindInteractionController.findNext instead")
  Future<void> findNext({required bool forward}) =>
      platform.findNext(forward: forward);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearMatches}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearMatches.supported_platforms}
  @Deprecated("Use FindInteractionController.clearMatches instead")
  Future<void> clearMatches() => platform.clearMatches();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getTRexRunnerHtml}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getTRexRunnerHtml.supported_platforms}
  @Deprecated("Use tRexRunnerHtml instead")
  Future<String> getTRexRunnerHtml() => platform.getTRexRunnerHtml();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getTRexRunnerCss}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getTRexRunnerCss.supported_platforms}
  @Deprecated("Use tRexRunnerCss instead")
  Future<String> getTRexRunnerCss() => platform.getTRexRunnerCss();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.scrollTo}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.scrollTo.supported_platforms}
  Future<void> scrollTo({
    required int x,
    required int y,
    bool animated = false,
  }) => platform.scrollTo(x: x, y: y, animated: animated);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.scrollBy}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.scrollBy.supported_platforms}
  Future<void> scrollBy({
    required int x,
    required int y,
    bool animated = false,
  }) => platform.scrollBy(x: x, y: y, animated: animated);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.pauseTimers}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.pauseTimers.supported_platforms}
  Future<void> pauseTimers() => platform.pauseTimers();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.resumeTimers}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.resumeTimers.supported_platforms}
  Future<void> resumeTimers() => platform.resumeTimers();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.printCurrentPage}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.printCurrentPage.supported_platforms}
  Future<PrintJobController?> printCurrentPage({
    PrintJobSettings? settings,
  }) async {
    final printJobControllerPlatform = await platform.printCurrentPage(
      settings: settings,
    );
    if (printJobControllerPlatform == null) {
      return null;
    }
    return PrintJobController.fromPlatform(
      platform: printJobControllerPlatform,
    );
  }

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getContentHeight}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getContentHeight.supported_platforms}
  Future<int?> getContentHeight() => platform.getContentHeight();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getContentWidth}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getContentWidth.supported_platforms}
  Future<int?> getContentWidth() => platform.getContentWidth();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.zoomBy}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.zoomBy.supported_platforms}
  Future<void> zoomBy({
    required double zoomFactor,
    @Deprecated('Use animated instead') bool? iosAnimated,
    bool animated = false,
  }) => platform.zoomBy(
    zoomFactor: zoomFactor,
    iosAnimated: iosAnimated,
    animated: animated,
  );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getOriginalUrl}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getOriginalUrl.supported_platforms}
  Future<WebUri?> getOriginalUrl() => platform.getOriginalUrl();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getZoomScale}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getZoomScale.supported_platforms}
  Future<double?> getZoomScale() => platform.getZoomScale();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getScale}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getScale.supported_platforms}
  @Deprecated('Use getZoomScale instead')
  Future<double?> getScale() => platform.getScale();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getSelectedText}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getSelectedText.supported_platforms}
  Future<String?> getSelectedText() => platform.getSelectedText();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getHitTestResult}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getHitTestResult.supported_platforms}
  Future<InAppWebViewHitTestResult?> getHitTestResult() =>
      platform.getHitTestResult();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestFocus}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestFocus.supported_platforms}
  Future<bool?> requestFocus({
    FocusDirection? direction,
    InAppWebViewRect? previouslyFocusedRect,
  }) => platform.requestFocus(
    direction: direction,
    previouslyFocusedRect: previouslyFocusedRect,
  );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearFocus}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearFocus.supported_platforms}
  Future<void> clearFocus() => platform.clearFocus();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setInputMethodEnabled}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setInputMethodEnabled.supported_platforms}
  Future<void> setInputMethodEnabled(bool enabled) =>
      platform.setInputMethodEnabled(enabled);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.showInputMethod}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.showInputMethod.supported_platforms}
  Future<void> showInputMethod() => platform.showInputMethod();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.hideInputMethod}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.hideInputMethod.supported_platforms}
  Future<void> hideInputMethod() => platform.hideInputMethod();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setContextMenu}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setContextMenu.supported_platforms}
  Future<void> setContextMenu(ContextMenu? contextMenu) =>
      platform.setContextMenu(contextMenu);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestFocusNodeHref}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestFocusNodeHref.supported_platforms}
  Future<RequestFocusNodeHrefResult?> requestFocusNodeHref() =>
      platform.requestFocusNodeHref();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestImageRef}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestImageRef.supported_platforms}
  Future<RequestImageRefResult?> requestImageRef() =>
      platform.requestImageRef();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getMetaTags}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getMetaTags.supported_platforms}
  Future<List<MetaTag>> getMetaTags() => platform.getMetaTags();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getMetaThemeColor}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getMetaThemeColor.supported_platforms}
  Future<Color?> getMetaThemeColor() => platform.getMetaThemeColor();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getScrollX}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getScrollX.supported_platforms}
  Future<int?> getScrollX() => platform.getScrollX();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getScrollY}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getScrollY.supported_platforms}
  Future<int?> getScrollY() => platform.getScrollY();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getCertificate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getCertificate.supported_platforms}
  Future<SslCertificate?> getCertificate() => platform.getCertificate();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.addUserScript}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.addUserScript.supported_platforms}
  Future<void> addUserScript({required UserScript userScript}) =>
      platform.addUserScript(userScript: userScript);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.addUserScripts}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.addUserScripts.supported_platforms}
  Future<void> addUserScripts({required List<UserScript> userScripts}) =>
      platform.addUserScripts(userScripts: userScripts);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.removeUserScript}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.removeUserScript.supported_platforms}
  Future<bool> removeUserScript({required UserScript userScript}) =>
      platform.removeUserScript(userScript: userScript);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.removeUserScriptsByGroupName}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.removeUserScriptsByGroupName.supported_platforms}
  Future<void> removeUserScriptsByGroupName({required String groupName}) =>
      platform.removeUserScriptsByGroupName(groupName: groupName);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.removeUserScripts}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.removeUserScripts.supported_platforms}
  Future<void> removeUserScripts({required List<UserScript> userScripts}) =>
      platform.removeUserScripts(userScripts: userScripts);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.removeAllUserScripts}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.removeAllUserScripts.supported_platforms}
  Future<void> removeAllUserScripts() => platform.removeAllUserScripts();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.hasUserScript}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.hasUserScript.supported_platforms}
  bool hasUserScript({required UserScript userScript}) =>
      platform.hasUserScript(userScript: userScript);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.callAsyncJavaScript}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.callAsyncJavaScript.supported_platforms}
  Future<CallAsyncJavaScriptResult?> callAsyncJavaScript({
    required String functionBody,
    Map<String, dynamic> arguments = const <String, dynamic>{},
    ContentWorld? contentWorld,
  }) => platform.callAsyncJavaScript(
    functionBody: functionBody,
    arguments: arguments,
    contentWorld: contentWorld,
  );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.saveWebArchive}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.saveWebArchive.supported_platforms}
  Future<String?> saveWebArchive({
    required String filePath,
    bool autoname = false,
  }) => platform.saveWebArchive(filePath: filePath, autoname: autoname);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isSecureContext}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isSecureContext.supported_platforms}
  Future<bool> isSecureContext() => platform.isSecureContext();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.createWebMessageChannel}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.createWebMessageChannel.supported_platforms}
  Future<WebMessageChannel?> createWebMessageChannel() async {
    final webMessagePlatform = await platform.createWebMessageChannel();
    if (webMessagePlatform == null) {
      return null;
    }
    return WebMessageChannel.fromPlatform(platform: webMessagePlatform);
  }

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.postWebMessage}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.postWebMessage.supported_platforms}
  Future<void> postWebMessage({
    required WebMessage message,
    WebUri? targetOrigin,
  }) => platform.postWebMessage(message: message, targetOrigin: targetOrigin);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.addWebMessageListener}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.addWebMessageListener.supported_platforms}
  Future<void> addWebMessageListener(WebMessageListener webMessageListener) =>
      platform.addWebMessageListener(webMessageListener.platform);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.hasWebMessageListener}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.hasWebMessageListener.supported_platforms}
  bool hasWebMessageListener(WebMessageListener webMessageListener) =>
      platform.hasWebMessageListener(webMessageListener.platform);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.canScrollVertically}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.canScrollVertically.supported_platforms}
  Future<bool> canScrollVertically() => platform.canScrollVertically();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.canScrollHorizontally}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.canScrollHorizontally.supported_platforms}
  Future<bool> canScrollHorizontally() => platform.canScrollHorizontally();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.startSafeBrowsing}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.startSafeBrowsing.supported_platforms}
  Future<bool> startSafeBrowsing() => platform.startSafeBrowsing();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearSslPreferences}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearSslPreferences.supported_platforms}
  Future<void> clearSslPreferences() => platform.clearSslPreferences();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.pause}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.pause.supported_platforms}
  Future<void> pause() => platform.pause();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.resume}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.resume.supported_platforms}
  Future<void> resume() => platform.resume();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.pageDown}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.pageDown.supported_platforms}
  Future<bool> pageDown({required bool bottom}) =>
      platform.pageDown(bottom: bottom);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.pageUp}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.pageUp.supported_platforms}
  Future<bool> pageUp({required bool top}) => platform.pageUp(top: top);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.zoomIn}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.zoomIn.supported_platforms}
  Future<bool> zoomIn() => platform.zoomIn();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.zoomOut}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.zoomOut.supported_platforms}
  Future<bool> zoomOut() => platform.zoomOut();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearHistory}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearHistory.supported_platforms}
  Future<void> clearHistory() => platform.clearHistory();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.reloadFromOrigin}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.reloadFromOrigin.supported_platforms}
  Future<void> reloadFromOrigin() => platform.reloadFromOrigin();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.createPdf}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.createPdf.supported_platforms}
  Future<Uint8List?> createPdf({
    @Deprecated("Use pdfConfiguration instead")
    // ignore: deprecated_member_use_from_same_package
    IOSWKPDFConfiguration? iosWKPdfConfiguration,
    PDFConfiguration? pdfConfiguration,
  }) => platform.createPdf(
    iosWKPdfConfiguration: iosWKPdfConfiguration,
    pdfConfiguration: pdfConfiguration,
  );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.createWebArchiveData}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.createWebArchiveData.supported_platforms}
  Future<Uint8List?> createWebArchiveData() => platform.createWebArchiveData();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.hasOnlySecureContent}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.hasOnlySecureContent.supported_platforms}
  Future<bool> hasOnlySecureContent() => platform.hasOnlySecureContent();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.pauseAllMediaPlayback}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.pauseAllMediaPlayback.supported_platforms}
  Future<void> pauseAllMediaPlayback() => platform.pauseAllMediaPlayback();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setAllMediaPlaybackSuspended}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setAllMediaPlaybackSuspended.supported_platforms}
  Future<void> setAllMediaPlaybackSuspended({required bool suspended}) =>
      platform.setAllMediaPlaybackSuspended(suspended: suspended);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.closeAllMediaPresentations}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.closeAllMediaPresentations.supported_platforms}
  Future<void> closeAllMediaPresentations() =>
      platform.closeAllMediaPresentations();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestMediaPlaybackState}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestMediaPlaybackState.supported_platforms}
  Future<MediaPlaybackState?> requestMediaPlaybackState() =>
      platform.requestMediaPlaybackState();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isInFullscreen}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isInFullscreen.supported_platforms}
  Future<bool> isInFullscreen() => platform.isInFullscreen();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestEnterFullscreen}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestEnterFullscreen.supported_platforms}
  Future<void> requestEnterFullscreen() => platform.requestEnterFullscreen();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestExitFullscreen}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestExitFullscreen.supported_platforms}
  Future<void> requestExitFullscreen() => platform.requestExitFullscreen();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setVisible}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setVisible.supported_platforms}
  Future<void> setVisible({required bool visible}) =>
      platform.setVisible(visible: visible);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setTargetRefreshRate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setTargetRefreshRate.supported_platforms}
  Future<void> setTargetRefreshRate({required int rate}) =>
      platform.setTargetRefreshRate(rate: rate);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getTargetRefreshRate}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getTargetRefreshRate.supported_platforms}
  Future<int> getTargetRefreshRate() => platform.getTargetRefreshRate();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getScreenScale}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getScreenScale.supported_platforms}
  Future<double> getScreenScale() => platform.getScreenScale();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setScreenScale}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setScreenScale.supported_platforms}
  Future<void> setScreenScale({required double scale}) =>
      platform.setScreenScale(scale: scale);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isVisible}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isVisible.supported_platforms}
  Future<bool> isVisible() => platform.isVisible();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestPointerLock}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestPointerLock.supported_platforms}
  Future<bool> requestPointerLock() => platform.requestPointerLock();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestPointerUnlock}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.requestPointerUnlock.supported_platforms}
  Future<bool> requestPointerUnlock() => platform.requestPointerUnlock();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearFormData}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearFormData.supported_platforms}
  Future<void> clearFormData() => platform.clearFormData();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getCameraCaptureState}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getCameraCaptureState.supported_platforms}
  Future<MediaCaptureState?> getCameraCaptureState() =>
      platform.getCameraCaptureState();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setCameraCaptureState}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setCameraCaptureState.supported_platforms}
  Future<void> setCameraCaptureState({required MediaCaptureState state}) =>
      platform.setCameraCaptureState(state: state);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getMicrophoneCaptureState}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getMicrophoneCaptureState.supported_platforms}
  Future<MediaCaptureState?> getMicrophoneCaptureState() =>
      platform.getMicrophoneCaptureState();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setMicrophoneCaptureState}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setMicrophoneCaptureState.supported_platforms}
  Future<void> setMicrophoneCaptureState({required MediaCaptureState state}) =>
      platform.setMicrophoneCaptureState(state: state);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isPlayingAudio}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isPlayingAudio.supported_platforms}
  Future<bool> isPlayingAudio() => platform.isPlayingAudio();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isMuted}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isMuted.supported_platforms}
  Future<bool> isMuted() => platform.isMuted();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setMuted}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setMuted.supported_platforms}
  Future<void> setMuted({required bool muted}) =>
      platform.setMuted(muted: muted);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.terminateWebProcess}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.terminateWebProcess.supported_platforms}
  Future<void> terminateWebProcess() => platform.terminateWebProcess();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.loadSimulatedRequest}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.loadSimulatedRequest.supported_platforms}
  Future<void> loadSimulatedRequest({
    required URLRequest urlRequest,
    required Uint8List data,
    URLResponse? urlResponse,
  }) => platform.loadSimulatedRequest(urlRequest: urlRequest, data: data);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.openDevTools}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.openDevTools.supported_platforms}
  Future<void> openDevTools() => platform.openDevTools();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.callDevToolsProtocolMethod}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.callDevToolsProtocolMethod.supported_platforms}
  Future<dynamic> callDevToolsProtocolMethod({
    required String methodName,
    Map<String, dynamic>? parameters,
  }) => platform.callDevToolsProtocolMethod(
    methodName: methodName,
    parameters: parameters,
  );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.addDevToolsProtocolEventListener}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.addDevToolsProtocolEventListener.supported_platforms}
  Future<void> addDevToolsProtocolEventListener({
    required String eventName,
    required Function(dynamic data) callback,
  }) => platform.addDevToolsProtocolEventListener(
    eventName: eventName,
    callback: callback,
  );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.removeDevToolsProtocolEventListener}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.removeDevToolsProtocolEventListener.supported_platforms}
  Future<void> removeDevToolsProtocolEventListener({
    required String eventName,
  }) => platform.removeDevToolsProtocolEventListener(eventName: eventName);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isInterfaceSupported}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isInterfaceSupported.supported_platforms}
  Future<bool> isInterfaceSupported(WebViewInterface interface) =>
      platform.isInterfaceSupported(interface);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.saveState}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.saveState.supported_platforms}
  Future<Uint8List?> saveState() => platform.saveState();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.restoreState}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.restoreState.supported_platforms}
  Future<bool> restoreState(Uint8List state) => platform.restoreState(state);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getIFrameId}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getIFrameId.supported_platforms}
  Future<String?> getIFrameId() => platform.getIFrameId();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getDefaultUserAgent}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getDefaultUserAgent.supported_platforms}
  static Future<String> getDefaultUserAgent() =>
      PlatformInAppWebViewController.static().getDefaultUserAgent();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearClientCertPreferences}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearClientCertPreferences.supported_platforms}
  static Future<void> clearClientCertPreferences() =>
      PlatformInAppWebViewController.static().clearClientCertPreferences();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getSafeBrowsingPrivacyPolicyUrl}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getSafeBrowsingPrivacyPolicyUrl.supported_platforms}
  static Future<WebUri?> getSafeBrowsingPrivacyPolicyUrl() =>
      PlatformInAppWebViewController.static().getSafeBrowsingPrivacyPolicyUrl();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setSafeBrowsingWhitelist}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setSafeBrowsingWhitelist.supported_platforms}
  @Deprecated("Use setSafeBrowsingAllowlist instead")
  static Future<bool> setSafeBrowsingWhitelist({required List<String> hosts}) =>
      PlatformInAppWebViewController.static().setSafeBrowsingWhitelist(
        hosts: hosts,
      );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setSafeBrowsingAllowlist}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setSafeBrowsingAllowlist.supported_platforms}
  static Future<bool> setSafeBrowsingAllowlist({required List<String> hosts}) =>
      PlatformInAppWebViewController.static().setSafeBrowsingAllowlist(
        hosts: hosts,
      );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getCurrentWebViewPackage}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getCurrentWebViewPackage.supported_platforms}
  static Future<WebViewPackageInfo?> getCurrentWebViewPackage() =>
      PlatformInAppWebViewController.static().getCurrentWebViewPackage();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setWebContentsDebuggingEnabled}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setWebContentsDebuggingEnabled.supported_platforms}
  static Future<void> setWebContentsDebuggingEnabled(bool debuggingEnabled) =>
      PlatformInAppWebViewController.static().setWebContentsDebuggingEnabled(
        debuggingEnabled,
      );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getVariationsHeader}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getVariationsHeader.supported_platforms}
  static Future<String?> getVariationsHeader() =>
      PlatformInAppWebViewController.static().getVariationsHeader();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isMultiProcessEnabled}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isMultiProcessEnabled.supported_platforms}
  static Future<bool> isMultiProcessEnabled() =>
      PlatformInAppWebViewController.static().isMultiProcessEnabled();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.disableWebView}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.disableWebView.supported_platforms}
  static Future<void> disableWebView() =>
      PlatformInAppWebViewController.static().disableWebView();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.handlesURLScheme}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.handlesURLScheme.supported_platforms}
  static Future<bool> handlesURLScheme(String urlScheme) =>
      PlatformInAppWebViewController.static().handlesURLScheme(urlScheme);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.disposeKeepAlive}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.disposeKeepAlive.supported_platforms}
  static Future<void> disposeKeepAlive(InAppWebViewKeepAlive keepAlive) =>
      PlatformInAppWebViewController.static().disposeKeepAlive(keepAlive);

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearAllCache}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.clearAllCache.supported_platforms}
  static Future<void> clearAllCache({bool includeDiskFiles = true}) =>
      PlatformInAppWebViewController.static().clearAllCache(
        includeDiskFiles: includeDiskFiles,
      );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.enableSlowWholeDocumentDraw}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.enableSlowWholeDocumentDraw.supported_platforms}
  static Future<void> enableSlowWholeDocumentDraw() =>
      PlatformInAppWebViewController.static().enableSlowWholeDocumentDraw();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setJavaScriptBridgeName}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.setJavaScriptBridgeName.supported_platforms}
  static Future<void> setJavaScriptBridgeName(String bridgeName) =>
      PlatformInAppWebViewController.static().setJavaScriptBridgeName(
        bridgeName,
      );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getJavaScriptBridgeName}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getJavaScriptBridgeName.supported_platforms}
  static Future<String> getJavaScriptBridgeName() =>
      PlatformInAppWebViewController.static().getJavaScriptBridgeName();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.tRexRunnerHtml}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.tRexRunnerHtml.supported_platforms}
  static Future<String> get tRexRunnerHtml =>
      PlatformInAppWebViewController.static().tRexRunnerHtml;

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.tRexRunnerCss}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.tRexRunnerCss.supported_platforms}
  static Future<String> get tRexRunnerCss =>
      PlatformInAppWebViewController.static().tRexRunnerCss;

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformInAppWebViewController.static().isClassSupported(
        platform: platform,
      );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isPropertySupported}
  static bool isPropertySupported(
    PlatformInAppWebViewControllerProperty property, {
    TargetPlatform? platform,
  }) => PlatformInAppWebViewController.static().isPropertySupported(
    property,
    platform: platform,
  );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.isMethodSupported}
  static bool isMethodSupported(
    PlatformInAppWebViewControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformInAppWebViewController.static().isMethodSupported(
    method,
    platform: platform,
  );

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getViewId}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.getViewId.supported_platforms}
  dynamic getViewId() => platform.getViewId();

  ///{@macro drago_inappwebview.PlatformInAppWebViewController.dispose}
  ///
  ///{@macro drago_inappwebview.PlatformInAppWebViewController.dispose.supported_platforms}
  void dispose({bool isKeepAlive = false}) =>
      platform.dispose(isKeepAlive: isKeepAlive);
}
