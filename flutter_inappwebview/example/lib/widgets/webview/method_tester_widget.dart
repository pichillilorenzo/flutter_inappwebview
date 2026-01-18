import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Method entry for a single controller method
class MethodEntry {
  final String name;
  final String description;
  final PlatformInAppWebViewControllerMethod methodEnum;
  final Future<dynamic> Function(InAppWebViewController controller) execute;

  const MethodEntry({
    required this.name,
    required this.description,
    required this.methodEnum,
    required this.execute,
  });
}

/// A category of methods
class MethodCategory {
  final String name;
  final IconData icon;
  final List<MethodEntry> methods;

  const MethodCategory({
    required this.name,
    required this.icon,
    required this.methods,
  });
}

/// Widget to test InAppWebViewController methods
/// Tests all 88 InAppWebViewController methods organized by category
class MethodTesterWidget extends StatefulWidget {
  final InAppWebViewController? controller;

  const MethodTesterWidget({super.key, required this.controller});

  @override
  State<MethodTesterWidget> createState() => _MethodTesterWidgetState();
}

class _MethodTesterWidgetState extends State<MethodTesterWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, dynamic> _results = {};
  final Map<String, bool> _executing = {};
  final Map<String, String> _errors = {};
  final Set<int> _expandedCategories = {
    0,
  }; // First category expanded by default

  // All method categories
  late final List<MethodCategory> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _buildMethodCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MethodCategory> _buildMethodCategories() {
    return [
      // Navigation & Loading (16 methods)
      MethodCategory(
        name: 'Navigation & Loading',
        icon: Icons.navigation,
        methods: [
          MethodEntry(
            name: 'loadUrl',
            description: 'Loads the given URL',
            methodEnum: PlatformInAppWebViewControllerMethod.loadUrl,
            execute: (controller) async {
              await controller.loadUrl(
                urlRequest: URLRequest(url: WebUri('https://example.com')),
              );
              return 'URL loaded successfully';
            },
          ),
          MethodEntry(
            name: 'postUrl',
            description: 'Loads URL using POST method',
            methodEnum: PlatformInAppWebViewControllerMethod.postUrl,
            execute: (controller) async {
              await controller.postUrl(
                url: WebUri('https://httpbin.org/post'),
                postData: Uint8List.fromList('test=data'.codeUnits),
              );
              return 'POST request sent';
            },
          ),
          MethodEntry(
            name: 'loadData',
            description: 'Loads HTML data string',
            methodEnum: PlatformInAppWebViewControllerMethod.loadData,
            execute: (controller) async {
              await controller.loadData(
                data: '<html><body><h1>Test HTML</h1></body></html>',
                mimeType: 'text/html',
                encoding: 'utf-8',
              );
              return 'HTML data loaded';
            },
          ),
          MethodEntry(
            name: 'loadFile',
            description: 'Loads a file from assets',
            methodEnum: PlatformInAppWebViewControllerMethod.loadFile,
            execute: (controller) async {
              await controller.loadFile(assetFilePath: 'assets/index.html');
              return 'File loaded from assets';
            },
          ),
          MethodEntry(
            name: 'reload',
            description: 'Reloads the current page',
            methodEnum: PlatformInAppWebViewControllerMethod.reload,
            execute: (controller) async {
              await controller.reload();
              return 'Page reloaded';
            },
          ),
          MethodEntry(
            name: 'reloadFromOrigin',
            description: 'Reloads bypassing cache',
            methodEnum: PlatformInAppWebViewControllerMethod.reloadFromOrigin,
            execute: (controller) async {
              await controller.reloadFromOrigin();
              return 'Page reloaded from origin';
            },
          ),
          MethodEntry(
            name: 'goBack',
            description: 'Navigates back in history',
            methodEnum: PlatformInAppWebViewControllerMethod.goBack,
            execute: (controller) async {
              await controller.goBack();
              return 'Navigated back';
            },
          ),
          MethodEntry(
            name: 'goForward',
            description: 'Navigates forward in history',
            methodEnum: PlatformInAppWebViewControllerMethod.goForward,
            execute: (controller) async {
              await controller.goForward();
              return 'Navigated forward';
            },
          ),
          MethodEntry(
            name: 'goBackOrForward',
            description: 'Navigates by steps',
            methodEnum: PlatformInAppWebViewControllerMethod.goBackOrForward,
            execute: (controller) async {
              await controller.goBackOrForward(steps: -1);
              return 'Navigated by steps';
            },
          ),
          MethodEntry(
            name: 'goTo',
            description: 'Navigates to history item',
            methodEnum: PlatformInAppWebViewControllerMethod.goTo,
            execute: (controller) async {
              final history = await controller.getCopyBackForwardList();
              if (history != null &&
                  history.list != null &&
                  history.list!.isNotEmpty) {
                await controller.goTo(historyItem: history.list!.first);
                return 'Navigated to history item';
              }
              return 'No history items available';
            },
          ),
          MethodEntry(
            name: 'canGoBack',
            description: 'Checks if can go back',
            methodEnum: PlatformInAppWebViewControllerMethod.canGoBack,
            execute: (controller) async {
              return await controller.canGoBack();
            },
          ),
          MethodEntry(
            name: 'canGoForward',
            description: 'Checks if can go forward',
            methodEnum: PlatformInAppWebViewControllerMethod.canGoForward,
            execute: (controller) async {
              return await controller.canGoForward();
            },
          ),
          MethodEntry(
            name: 'canGoBackOrForward',
            description: 'Checks if can navigate by steps',
            methodEnum: PlatformInAppWebViewControllerMethod.canGoBackOrForward,
            execute: (controller) async {
              return await controller.canGoBackOrForward(steps: -1);
            },
          ),
          MethodEntry(
            name: 'isLoading',
            description: 'Checks if page is loading',
            methodEnum: PlatformInAppWebViewControllerMethod.isLoading,
            execute: (controller) async {
              return await controller.isLoading();
            },
          ),
          MethodEntry(
            name: 'stopLoading',
            description: 'Stops page loading',
            methodEnum: PlatformInAppWebViewControllerMethod.stopLoading,
            execute: (controller) async {
              await controller.stopLoading();
              return 'Loading stopped';
            },
          ),
          MethodEntry(
            name: 'loadSimulatedRequest',
            description: 'Loads simulated request',
            methodEnum:
                PlatformInAppWebViewControllerMethod.loadSimulatedRequest,
            execute: (controller) async {
              await controller.loadSimulatedRequest(
                urlRequest: URLRequest(url: WebUri('https://example.com')),
                data: Uint8List.fromList(
                  '<html><body>Simulated</body></html>'.codeUnits,
                ),
              );
              return 'Simulated request loaded';
            },
          ),
        ],
      ),

      // Page Info & Content (12 methods)
      MethodCategory(
        name: 'Page Info & Content',
        icon: Icons.info_outline,
        methods: [
          MethodEntry(
            name: 'getUrl',
            description: 'Gets current page URL',
            methodEnum: PlatformInAppWebViewControllerMethod.getUrl,
            execute: (controller) async {
              return (await controller.getUrl())?.toString() ?? 'No URL';
            },
          ),
          MethodEntry(
            name: 'getTitle',
            description: 'Gets current page title',
            methodEnum: PlatformInAppWebViewControllerMethod.getTitle,
            execute: (controller) async {
              return await controller.getTitle() ?? 'No title';
            },
          ),
          MethodEntry(
            name: 'getProgress',
            description: 'Gets page load progress',
            methodEnum: PlatformInAppWebViewControllerMethod.getProgress,
            execute: (controller) async {
              return await controller.getProgress();
            },
          ),
          MethodEntry(
            name: 'getHtml',
            description: 'Gets page HTML source',
            methodEnum: PlatformInAppWebViewControllerMethod.getHtml,
            execute: (controller) async {
              final html = await controller.getHtml();
              if (html != null && html.length > 500) {
                return '${html.substring(0, 500)}...';
              }
              return html ?? 'No HTML';
            },
          ),
          MethodEntry(
            name: 'getFavicons',
            description: 'Gets page favicons',
            methodEnum: PlatformInAppWebViewControllerMethod.getFavicons,
            execute: (controller) async {
              final favicons = await controller.getFavicons();
              return 'Found ${favicons.length} favicons';
            },
          ),
          MethodEntry(
            name: 'getOriginalUrl',
            description: 'Gets original URL before redirects',
            methodEnum: PlatformInAppWebViewControllerMethod.getOriginalUrl,
            execute: (controller) async {
              return (await controller.getOriginalUrl())?.toString() ??
                  'No URL';
            },
          ),
          MethodEntry(
            name: 'getSelectedText',
            description: 'Gets selected text',
            methodEnum: PlatformInAppWebViewControllerMethod.getSelectedText,
            execute: (controller) async {
              return await controller.getSelectedText() ?? 'No selection';
            },
          ),
          MethodEntry(
            name: 'getHitTestResult',
            description: 'Gets hit test result',
            methodEnum: PlatformInAppWebViewControllerMethod.getHitTestResult,
            execute: (controller) async {
              final result = await controller.getHitTestResult();
              return result?.type.toString() ?? 'No hit test result';
            },
          ),
          MethodEntry(
            name: 'getMetaTags',
            description: 'Gets meta tags from page',
            methodEnum: PlatformInAppWebViewControllerMethod.getMetaTags,
            execute: (controller) async {
              final tags = await controller.getMetaTags();
              return 'Found ${tags.length} meta tags';
            },
          ),
          MethodEntry(
            name: 'getMetaThemeColor',
            description: 'Gets meta theme color',
            methodEnum: PlatformInAppWebViewControllerMethod.getMetaThemeColor,
            execute: (controller) async {
              final color = await controller.getMetaThemeColor();
              return color?.toString() ?? 'No theme color';
            },
          ),
          MethodEntry(
            name: 'getCertificate',
            description: 'Gets SSL certificate',
            methodEnum: PlatformInAppWebViewControllerMethod.getCertificate,
            execute: (controller) async {
              final cert = await controller.getCertificate();
              return cert?.issuedTo?.CName ?? 'No certificate';
            },
          ),
          MethodEntry(
            name: 'getCopyBackForwardList',
            description: 'Gets navigation history',
            methodEnum:
                PlatformInAppWebViewControllerMethod.getCopyBackForwardList,
            execute: (controller) async {
              final history = await controller.getCopyBackForwardList();
              return 'History: ${history?.list?.length ?? 0} items, current: ${history?.currentIndex}';
            },
          ),
        ],
      ),

      // JavaScript Execution (7 methods)
      MethodCategory(
        name: 'JavaScript Execution',
        icon: Icons.code,
        methods: [
          MethodEntry(
            name: 'evaluateJavascript',
            description: 'Executes JavaScript code',
            methodEnum: PlatformInAppWebViewControllerMethod.evaluateJavascript,
            execute: (controller) async {
              return await controller.evaluateJavascript(
                source: 'document.title',
              );
            },
          ),
          MethodEntry(
            name: 'callAsyncJavaScript',
            description: 'Calls async JavaScript function',
            methodEnum:
                PlatformInAppWebViewControllerMethod.callAsyncJavaScript,
            execute: (controller) async {
              final result = await controller.callAsyncJavaScript(
                functionBody: 'return await Promise.resolve("async result");',
              );
              return result?.value ?? 'No result';
            },
          ),
          MethodEntry(
            name: 'injectJavascriptFileFromUrl',
            description: 'Injects JS file from URL',
            methodEnum: PlatformInAppWebViewControllerMethod
                .injectJavascriptFileFromUrl,
            execute: (controller) async {
              await controller.injectJavascriptFileFromUrl(
                urlFile: WebUri('https://code.jquery.com/jquery-3.7.1.min.js'),
              );
              return 'JavaScript file injected';
            },
          ),
          MethodEntry(
            name: 'injectJavascriptFileFromAsset',
            description: 'Injects JS file from assets',
            methodEnum: PlatformInAppWebViewControllerMethod
                .injectJavascriptFileFromAsset,
            execute: (controller) async {
              try {
                await controller.injectJavascriptFileFromAsset(
                  assetFilePath: 'assets/js/script.js',
                );
                return 'JavaScript asset injected';
              } catch (e) {
                return 'Asset not found or injection failed';
              }
            },
          ),
          MethodEntry(
            name: 'injectCSSCode',
            description: 'Injects CSS code',
            methodEnum: PlatformInAppWebViewControllerMethod.injectCSSCode,
            execute: (controller) async {
              await controller.injectCSSCode(
                source: 'body { background-color: #f0f0f0 !important; }',
              );
              return 'CSS code injected';
            },
          ),
          MethodEntry(
            name: 'injectCSSFileFromUrl',
            description: 'Injects CSS file from URL',
            methodEnum:
                PlatformInAppWebViewControllerMethod.injectCSSFileFromUrl,
            execute: (controller) async {
              await controller.injectCSSFileFromUrl(
                urlFile: WebUri(
                  'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css',
                ),
              );
              return 'CSS file injected';
            },
          ),
          MethodEntry(
            name: 'injectCSSFileFromAsset',
            description: 'Injects CSS file from assets',
            methodEnum:
                PlatformInAppWebViewControllerMethod.injectCSSFileFromAsset,
            execute: (controller) async {
              try {
                await controller.injectCSSFileFromAsset(
                  assetFilePath: 'assets/css/style.css',
                );
                return 'CSS asset injected';
              } catch (e) {
                return 'Asset not found or injection failed';
              }
            },
          ),
        ],
      ),

      // JavaScript Handlers (3 methods)
      MethodCategory(
        name: 'JavaScript Handlers',
        icon: Icons.link,
        methods: [
          MethodEntry(
            name: 'addJavaScriptHandler',
            description: 'Adds a JavaScript handler',
            methodEnum:
                PlatformInAppWebViewControllerMethod.addJavaScriptHandler,
            execute: (controller) async {
              controller.addJavaScriptHandler(
                handlerName: 'testHandler',
                callback: (args) {
                  return {'received': args};
                },
              );
              return 'Handler "testHandler" added';
            },
          ),
          MethodEntry(
            name: 'removeJavaScriptHandler',
            description: 'Removes a JavaScript handler',
            methodEnum:
                PlatformInAppWebViewControllerMethod.removeJavaScriptHandler,
            execute: (controller) async {
              final removed = controller.removeJavaScriptHandler(
                handlerName: 'testHandler',
              );
              return removed != null ? 'Handler removed' : 'Handler not found';
            },
          ),
          MethodEntry(
            name: 'hasJavaScriptHandler',
            description: 'Checks if handler exists',
            methodEnum:
                PlatformInAppWebViewControllerMethod.hasJavaScriptHandler,
            execute: (controller) async {
              return controller.hasJavaScriptHandler(
                handlerName: 'testHandler',
              );
            },
          ),
        ],
      ),

      // User Scripts (5 methods)
      MethodCategory(
        name: 'User Scripts',
        icon: Icons.description,
        methods: [
          MethodEntry(
            name: 'addUserScript',
            description: 'Adds a user script',
            methodEnum: PlatformInAppWebViewControllerMethod.addUserScript,
            execute: (controller) async {
              await controller.addUserScript(
                userScript: UserScript(
                  source: 'console.log("User script executed");',
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                  groupName: 'testGroup',
                ),
              );
              return 'User script added';
            },
          ),
          MethodEntry(
            name: 'removeUserScript',
            description: 'Removes a user script',
            methodEnum: PlatformInAppWebViewControllerMethod.removeUserScript,
            execute: (controller) async {
              final script = UserScript(
                source: 'console.log("User script executed");',
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
                groupName: 'testGroup',
              );
              final removed = await controller.removeUserScript(
                userScript: script,
              );
              return removed ? 'Script removed' : 'Script not found';
            },
          ),
          MethodEntry(
            name: 'removeUserScriptsByGroupName',
            description: 'Removes scripts by group name',
            methodEnum: PlatformInAppWebViewControllerMethod
                .removeUserScriptsByGroupName,
            execute: (controller) async {
              await controller.removeUserScriptsByGroupName(
                groupName: 'testGroup',
              );
              return 'Scripts in group removed';
            },
          ),
          MethodEntry(
            name: 'removeAllUserScripts',
            description: 'Removes all user scripts',
            methodEnum:
                PlatformInAppWebViewControllerMethod.removeAllUserScripts,
            execute: (controller) async {
              await controller.removeAllUserScripts();
              return 'All user scripts removed';
            },
          ),
          MethodEntry(
            name: 'hasUserScript',
            description: 'Checks if user script exists',
            methodEnum: PlatformInAppWebViewControllerMethod.hasUserScript,
            execute: (controller) async {
              final script = UserScript(
                source: 'console.log("test");',
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
              );
              return controller.hasUserScript(userScript: script);
            },
          ),
        ],
      ),

      // Scrolling & Layout (10 methods)
      MethodCategory(
        name: 'Scrolling & Layout',
        icon: Icons.swap_vert,
        methods: [
          MethodEntry(
            name: 'scrollTo',
            description: 'Scrolls to position',
            methodEnum: PlatformInAppWebViewControllerMethod.scrollTo,
            execute: (controller) async {
              await controller.scrollTo(x: 0, y: 100, animated: true);
              return 'Scrolled to (0, 100)';
            },
          ),
          MethodEntry(
            name: 'scrollBy',
            description: 'Scrolls by offset',
            methodEnum: PlatformInAppWebViewControllerMethod.scrollBy,
            execute: (controller) async {
              await controller.scrollBy(x: 0, y: 50, animated: true);
              return 'Scrolled by (0, 50)';
            },
          ),
          MethodEntry(
            name: 'getScrollX',
            description: 'Gets horizontal scroll position',
            methodEnum: PlatformInAppWebViewControllerMethod.getScrollX,
            execute: (controller) async {
              return await controller.getScrollX();
            },
          ),
          MethodEntry(
            name: 'getScrollY',
            description: 'Gets vertical scroll position',
            methodEnum: PlatformInAppWebViewControllerMethod.getScrollY,
            execute: (controller) async {
              return await controller.getScrollY();
            },
          ),
          MethodEntry(
            name: 'getContentHeight',
            description: 'Gets content height',
            methodEnum: PlatformInAppWebViewControllerMethod.getContentHeight,
            execute: (controller) async {
              return await controller.getContentHeight();
            },
          ),
          MethodEntry(
            name: 'getContentWidth',
            description: 'Gets content width',
            methodEnum: PlatformInAppWebViewControllerMethod.getContentWidth,
            execute: (controller) async {
              return await controller.getContentWidth();
            },
          ),
          MethodEntry(
            name: 'canScrollVertically',
            description: 'Checks if can scroll vertically',
            methodEnum:
                PlatformInAppWebViewControllerMethod.canScrollVertically,
            execute: (controller) async {
              return await controller.canScrollVertically();
            },
          ),
          MethodEntry(
            name: 'canScrollHorizontally',
            description: 'Checks if can scroll horizontally',
            methodEnum:
                PlatformInAppWebViewControllerMethod.canScrollHorizontally,
            execute: (controller) async {
              return await controller.canScrollHorizontally();
            },
          ),
          MethodEntry(
            name: 'pageDown',
            description: 'Scrolls page down',
            methodEnum: PlatformInAppWebViewControllerMethod.pageDown,
            execute: (controller) async {
              return await controller.pageDown(bottom: false);
            },
          ),
          MethodEntry(
            name: 'pageUp',
            description: 'Scrolls page up',
            methodEnum: PlatformInAppWebViewControllerMethod.pageUp,
            execute: (controller) async {
              return await controller.pageUp(top: false);
            },
          ),
        ],
      ),

      // Zoom (4 methods)
      MethodCategory(
        name: 'Zoom',
        icon: Icons.zoom_in,
        methods: [
          MethodEntry(
            name: 'zoomBy',
            description: 'Zooms by factor',
            methodEnum: PlatformInAppWebViewControllerMethod.zoomBy,
            execute: (controller) async {
              await controller.zoomBy(zoomFactor: 1.5, animated: true);
              return 'Zoomed to 1.5x';
            },
          ),
          MethodEntry(
            name: 'zoomIn',
            description: 'Zooms in',
            methodEnum: PlatformInAppWebViewControllerMethod.zoomIn,
            execute: (controller) async {
              return await controller.zoomIn();
            },
          ),
          MethodEntry(
            name: 'zoomOut',
            description: 'Zooms out',
            methodEnum: PlatformInAppWebViewControllerMethod.zoomOut,
            execute: (controller) async {
              return await controller.zoomOut();
            },
          ),
          MethodEntry(
            name: 'getZoomScale',
            description: 'Gets current zoom scale',
            methodEnum: PlatformInAppWebViewControllerMethod.getZoomScale,
            execute: (controller) async {
              return await controller.getZoomScale();
            },
          ),
        ],
      ),

      // Settings & State (5 methods)
      MethodCategory(
        name: 'Settings & State',
        icon: Icons.settings,
        methods: [
          MethodEntry(
            name: 'setSettings',
            description: 'Sets WebView settings',
            methodEnum: PlatformInAppWebViewControllerMethod.setSettings,
            execute: (controller) async {
              await controller.setSettings(
                settings: InAppWebViewSettings(javaScriptEnabled: true),
              );
              return 'Settings updated';
            },
          ),
          MethodEntry(
            name: 'getSettings',
            description: 'Gets WebView settings',
            methodEnum: PlatformInAppWebViewControllerMethod.getSettings,
            execute: (controller) async {
              final settings = await controller.getSettings();
              return 'JS enabled: ${settings?.javaScriptEnabled}';
            },
          ),
          MethodEntry(
            name: 'setContextMenu',
            description: 'Sets context menu',
            methodEnum: PlatformInAppWebViewControllerMethod.setContextMenu,
            execute: (controller) async {
              await controller.setContextMenu(
                ContextMenu(
                  menuItems: [
                    ContextMenuItem(id: 1, title: 'Test Item', action: () {}),
                  ],
                ),
              );
              return 'Context menu set';
            },
          ),
          MethodEntry(
            name: 'requestFocus',
            description: 'Requests focus for WebView',
            methodEnum: PlatformInAppWebViewControllerMethod.requestFocus,
            execute: (controller) async {
              return await controller.requestFocus();
            },
          ),
          MethodEntry(
            name: 'clearFocus',
            description: 'Clears focus from WebView',
            methodEnum: PlatformInAppWebViewControllerMethod.clearFocus,
            execute: (controller) async {
              await controller.clearFocus();
              return 'Focus cleared';
            },
          ),
        ],
      ),

      // Screenshot & Print (3 methods)
      MethodCategory(
        name: 'Screenshot & Print',
        icon: Icons.camera_alt,
        methods: [
          MethodEntry(
            name: 'takeScreenshot',
            description: 'Takes a screenshot',
            methodEnum: PlatformInAppWebViewControllerMethod.takeScreenshot,
            execute: (controller) async {
              final screenshot = await controller.takeScreenshot();
              if (screenshot != null) {
                return 'Screenshot taken: ${screenshot.length} bytes';
              }
              return 'Screenshot failed';
            },
          ),
          MethodEntry(
            name: 'printCurrentPage',
            description: 'Prints current page',
            methodEnum: PlatformInAppWebViewControllerMethod.printCurrentPage,
            execute: (controller) async {
              final printJob = await controller.printCurrentPage();
              return printJob != null
                  ? 'Print dialog opened'
                  : 'Print not available';
            },
          ),
          MethodEntry(
            name: 'createPdf',
            description: 'Creates PDF from page',
            methodEnum: PlatformInAppWebViewControllerMethod.createPdf,
            execute: (controller) async {
              final pdf = await controller.createPdf();
              if (pdf != null) {
                return 'PDF created: ${pdf.length} bytes';
              }
              return 'PDF creation failed';
            },
          ),
        ],
      ),

      // Cache & History (3 methods)
      MethodCategory(
        name: 'Cache & History',
        icon: Icons.history,
        methods: [
          MethodEntry(
            name: 'clearHistory',
            description: 'Clears navigation history',
            methodEnum: PlatformInAppWebViewControllerMethod.clearHistory,
            execute: (controller) async {
              await controller.clearHistory();
              return 'History cleared';
            },
          ),
          MethodEntry(
            name: 'clearFormData',
            description: 'Clears form data',
            methodEnum: PlatformInAppWebViewControllerMethod.clearFormData,
            execute: (controller) async {
              await controller.clearFormData();
              return 'Form data cleared';
            },
          ),
          MethodEntry(
            name: 'clearSslPreferences',
            description: 'Clears SSL preferences',
            methodEnum:
                PlatformInAppWebViewControllerMethod.clearSslPreferences,
            execute: (controller) async {
              await controller.clearSslPreferences();
              return 'SSL preferences cleared';
            },
          ),
        ],
      ),

      // Pause & Resume (4 methods)
      MethodCategory(
        name: 'Pause & Resume',
        icon: Icons.pause_circle_outline,
        methods: [
          MethodEntry(
            name: 'pause',
            description: 'Pauses WebView',
            methodEnum: PlatformInAppWebViewControllerMethod.pause,
            execute: (controller) async {
              await controller.pause();
              return 'WebView paused';
            },
          ),
          MethodEntry(
            name: 'resume',
            description: 'Resumes WebView',
            methodEnum: PlatformInAppWebViewControllerMethod.resume,
            execute: (controller) async {
              await controller.resume();
              return 'WebView resumed';
            },
          ),
          MethodEntry(
            name: 'pauseTimers',
            description: 'Pauses JavaScript timers',
            methodEnum: PlatformInAppWebViewControllerMethod.pauseTimers,
            execute: (controller) async {
              await controller.pauseTimers();
              return 'Timers paused';
            },
          ),
          MethodEntry(
            name: 'resumeTimers',
            description: 'Resumes JavaScript timers',
            methodEnum: PlatformInAppWebViewControllerMethod.resumeTimers,
            execute: (controller) async {
              await controller.resumeTimers();
              return 'Timers resumed';
            },
          ),
        ],
      ),

      // Web Messaging (4 methods)
      MethodCategory(
        name: 'Web Messaging',
        icon: Icons.message,
        methods: [
          MethodEntry(
            name: 'createWebMessageChannel',
            description: 'Creates a web message channel',
            methodEnum:
                PlatformInAppWebViewControllerMethod.createWebMessageChannel,
            execute: (controller) async {
              final channel = await controller.createWebMessageChannel();
              return channel != null
                  ? 'Channel created'
                  : 'Channel creation failed';
            },
          ),
          MethodEntry(
            name: 'postWebMessage',
            description: 'Posts a web message',
            methodEnum: PlatformInAppWebViewControllerMethod.postWebMessage,
            execute: (controller) async {
              await controller.postWebMessage(
                message: WebMessage(data: 'Hello from Flutter'),
                targetOrigin: WebUri('*'),
              );
              return 'Message posted';
            },
          ),
          MethodEntry(
            name: 'addWebMessageListener',
            description: 'Adds a web message listener',
            methodEnum:
                PlatformInAppWebViewControllerMethod.addWebMessageListener,
            execute: (controller) async {
              await controller.addWebMessageListener(
                WebMessageListener(
                  jsObjectName: 'testListener',
                  onPostMessage:
                      (message, sourceOrigin, isMainFrame, replyProxy) {
                        // Handle message
                      },
                ),
              );
              return 'Listener added';
            },
          ),
          MethodEntry(
            name: 'hasWebMessageListener',
            description: 'Checks if listener exists',
            methodEnum:
                PlatformInAppWebViewControllerMethod.hasWebMessageListener,
            execute: (controller) async {
              final listener = WebMessageListener(
                jsObjectName: 'testListener',
                onPostMessage:
                    (message, sourceOrigin, isMainFrame, replyProxy) {},
              );
              return controller.hasWebMessageListener(listener);
            },
          ),
        ],
      ),

      // Media & Fullscreen (8 methods)
      MethodCategory(
        name: 'Media & Fullscreen',
        icon: Icons.play_circle_outline,
        methods: [
          MethodEntry(
            name: 'isInFullscreen',
            description: 'Checks if in fullscreen',
            methodEnum: PlatformInAppWebViewControllerMethod.isInFullscreen,
            execute: (controller) async {
              return await controller.isInFullscreen();
            },
          ),
          MethodEntry(
            name: 'pauseAllMediaPlayback',
            description: 'Pauses all media',
            methodEnum:
                PlatformInAppWebViewControllerMethod.pauseAllMediaPlayback,
            execute: (controller) async {
              await controller.pauseAllMediaPlayback();
              return 'Media paused';
            },
          ),
          MethodEntry(
            name: 'setAllMediaPlaybackSuspended',
            description: 'Suspends media playback',
            methodEnum: PlatformInAppWebViewControllerMethod
                .setAllMediaPlaybackSuspended,
            execute: (controller) async {
              await controller.setAllMediaPlaybackSuspended(suspended: true);
              return 'Media suspended';
            },
          ),
          MethodEntry(
            name: 'closeAllMediaPresentations',
            description: 'Closes media presentations',
            methodEnum:
                PlatformInAppWebViewControllerMethod.closeAllMediaPresentations,
            execute: (controller) async {
              await controller.closeAllMediaPresentations();
              return 'Media presentations closed';
            },
          ),
          MethodEntry(
            name: 'requestMediaPlaybackState',
            description: 'Gets media playback state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.requestMediaPlaybackState,
            execute: (controller) async {
              final state = await controller.requestMediaPlaybackState();
              return state?.toString() ?? 'Unknown state';
            },
          ),
          MethodEntry(
            name: 'isPlayingAudio',
            description: 'Checks if playing audio',
            methodEnum: PlatformInAppWebViewControllerMethod.isPlayingAudio,
            execute: (controller) async {
              return await controller.isPlayingAudio();
            },
          ),
          MethodEntry(
            name: 'isMuted',
            description: 'Checks if muted',
            methodEnum: PlatformInAppWebViewControllerMethod.isMuted,
            execute: (controller) async {
              return await controller.isMuted();
            },
          ),
          MethodEntry(
            name: 'setMuted',
            description: 'Sets mute state',
            methodEnum: PlatformInAppWebViewControllerMethod.setMuted,
            execute: (controller) async {
              await controller.setMuted(muted: true);
              return 'Muted';
            },
          ),
        ],
      ),

      // Camera & Microphone (4 methods)
      MethodCategory(
        name: 'Camera & Microphone',
        icon: Icons.videocam,
        methods: [
          MethodEntry(
            name: 'getCameraCaptureState',
            description: 'Gets camera capture state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.getCameraCaptureState,
            execute: (controller) async {
              final state = await controller.getCameraCaptureState();
              return state?.toString() ?? 'Unknown state';
            },
          ),
          MethodEntry(
            name: 'setCameraCaptureState',
            description: 'Sets camera capture state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.setCameraCaptureState,
            execute: (controller) async {
              await controller.setCameraCaptureState(
                state: MediaCaptureState.ACTIVE,
              );
              return 'Camera state set';
            },
          ),
          MethodEntry(
            name: 'getMicrophoneCaptureState',
            description: 'Gets microphone capture state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.getMicrophoneCaptureState,
            execute: (controller) async {
              final state = await controller.getMicrophoneCaptureState();
              return state?.toString() ?? 'Unknown state';
            },
          ),
          MethodEntry(
            name: 'setMicrophoneCaptureState',
            description: 'Sets microphone capture state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.setMicrophoneCaptureState,
            execute: (controller) async {
              await controller.setMicrophoneCaptureState(
                state: MediaCaptureState.ACTIVE,
              );
              return 'Microphone state set';
            },
          ),
        ],
      ),

      // Security (2 methods)
      MethodCategory(
        name: 'Security',
        icon: Icons.security,
        methods: [
          MethodEntry(
            name: 'isSecureContext',
            description: 'Checks if secure context',
            methodEnum: PlatformInAppWebViewControllerMethod.isSecureContext,
            execute: (controller) async {
              return await controller.isSecureContext();
            },
          ),
          MethodEntry(
            name: 'hasOnlySecureContent',
            description: 'Checks if only secure content',
            methodEnum:
                PlatformInAppWebViewControllerMethod.hasOnlySecureContent,
            execute: (controller) async {
              return await controller.hasOnlySecureContent();
            },
          ),
        ],
      ),

      // Save & Restore (4 methods)
      MethodCategory(
        name: 'Save & Restore',
        icon: Icons.save,
        methods: [
          MethodEntry(
            name: 'saveState',
            description: 'Saves WebView state',
            methodEnum: PlatformInAppWebViewControllerMethod.saveState,
            execute: (controller) async {
              final state = await controller.saveState();
              return state != null
                  ? 'State saved: ${state.length} bytes'
                  : 'Save failed';
            },
          ),
          MethodEntry(
            name: 'restoreState',
            description: 'Restores WebView state',
            methodEnum: PlatformInAppWebViewControllerMethod.restoreState,
            execute: (controller) async {
              // Would need saved state to restore
              return 'No state to restore';
            },
          ),
          MethodEntry(
            name: 'saveWebArchive',
            description: 'Saves page as web archive',
            methodEnum: PlatformInAppWebViewControllerMethod.saveWebArchive,
            execute: (controller) async {
              try {
                final path = await controller.saveWebArchive(
                  filePath: '/tmp/archive.mht',
                  autoname: true,
                );
                return path ?? 'Archive save failed';
              } catch (e) {
                return 'Error: $e';
              }
            },
          ),
          MethodEntry(
            name: 'createWebArchiveData',
            description: 'Creates web archive data',
            methodEnum:
                PlatformInAppWebViewControllerMethod.createWebArchiveData,
            execute: (controller) async {
              final data = await controller.createWebArchiveData();
              return data != null ? 'Archive: ${data.length} bytes' : 'Failed';
            },
          ),
        ],
      ),

      // Misc/Advanced (6 methods)
      MethodCategory(
        name: 'Misc/Advanced',
        icon: Icons.more_horiz,
        methods: [
          MethodEntry(
            name: 'getViewId',
            description: 'Gets the WebView ID',
            methodEnum: PlatformInAppWebViewControllerMethod.getViewId,
            execute: (controller) async {
              return controller.getViewId();
            },
          ),
          MethodEntry(
            name: 'startSafeBrowsing',
            description: 'Starts Safe Browsing',
            methodEnum: PlatformInAppWebViewControllerMethod.startSafeBrowsing,
            execute: (controller) async {
              return await controller.startSafeBrowsing();
            },
          ),
          MethodEntry(
            name: 'openDevTools',
            description: 'Opens DevTools',
            methodEnum: PlatformInAppWebViewControllerMethod.openDevTools,
            execute: (controller) async {
              await controller.openDevTools();
              return 'DevTools opened';
            },
          ),
          MethodEntry(
            name: 'requestFocusNodeHref',
            description: 'Gets focused node href',
            methodEnum:
                PlatformInAppWebViewControllerMethod.requestFocusNodeHref,
            execute: (controller) async {
              final result = await controller.requestFocusNodeHref();
              return result?.url ?? 'No focused node';
            },
          ),
          MethodEntry(
            name: 'requestImageRef',
            description: 'Gets focused image URL',
            methodEnum: PlatformInAppWebViewControllerMethod.requestImageRef,
            execute: (controller) async {
              final result = await controller.requestImageRef();
              return result?.url ?? 'No image focused';
            },
          ),
          MethodEntry(
            name: 'isInterfaceSupported',
            description: 'Checks interface support',
            methodEnum:
                PlatformInAppWebViewControllerMethod.isInterfaceSupported,
            execute: (controller) async {
              return await controller.isInterfaceSupported(
                WebViewInterface.ICoreWebView2,
              );
            },
          ),
        ],
      ),
    ];
  }

  List<MethodCategory> _getFilteredCategories() {
    if (_searchQuery.isEmpty) {
      return _categories;
    }

    final query = _searchQuery.toLowerCase();
    return _categories
        .map((category) {
          final filteredMethods = category.methods
              .where(
                (method) =>
                    method.name.toLowerCase().contains(query) ||
                    method.description.toLowerCase().contains(query),
              )
              .toList();
          return MethodCategory(
            name: category.name,
            icon: category.icon,
            methods: filteredMethods,
          );
        })
        .where((category) => category.methods.isNotEmpty)
        .toList();
  }

  Future<void> _executeMethod(MethodEntry entry) async {
    if (widget.controller == null) return;

    setState(() {
      _executing[entry.name] = true;
      _errors.remove(entry.name);
      _results.remove(entry.name);
    });

    try {
      final result = await entry.execute(widget.controller!);
      if (mounted) {
        setState(() {
          _results[entry.name] = result;
          _executing[entry.name] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errors[entry.name] = e.toString();
          _executing[entry.name] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _getFilteredCategories();
    final totalMethods = _categories.fold<int>(
      0,
      (sum, cat) => sum + cat.methods.length,
    );

    return Column(
      children: [
        // Header with search
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.developer_mode, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Method Tester ($totalMethods methods)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search methods...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ],
          ),
        ),

        // Controller status
        if (widget.controller == null)
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade50,
            child: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'WebView controller not available. Create a WebView first.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),

        // Method categories
        Expanded(
          child: ListView.builder(
            itemCount: filteredCategories.length,
            itemBuilder: (context, categoryIndex) {
              final category = filteredCategories[categoryIndex];
              final originalIndex = _categories.indexOf(category);
              final isExpanded =
                  _searchQuery.isNotEmpty ||
                  _expandedCategories.contains(originalIndex);

              return ExpansionTile(
                key: Key(category.name),
                initiallyExpanded: isExpanded,
                leading: Icon(category.icon, size: 24),
                title: Text(
                  '${category.name} (${category.methods.length})',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onExpansionChanged: (expanded) {
                  setState(() {
                    if (expanded) {
                      _expandedCategories.add(originalIndex);
                    } else {
                      _expandedCategories.remove(originalIndex);
                    }
                  });
                },
                children: category.methods
                    .map((method) => _buildMethodTile(method))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMethodTile(MethodEntry method) {
    final isExecuting = _executing[method.name] == true;
    final hasResult = _results.containsKey(method.name);
    final hasError = _errors.containsKey(method.name);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Method header
          ListTile(
            dense: true,
            title: Text(
              method.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                method.description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
            trailing: SizedBox(
              width: 80,
              height: 32,
              child: ElevatedButton(
                onPressed: widget.controller == null || isExecuting
                    ? null
                    : () => _executeMethod(method),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(fontSize: 11),
                ),
                child: isExecuting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Execute'),
              ),
            ),
          ),

          // Result or error display
          if (hasResult || hasError)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasError ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: hasError ? Colors.red.shade200 : Colors.green.shade200,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    hasError ? Icons.error_outline : Icons.check_circle,
                    size: 16,
                    color: hasError ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasError
                          ? _errors[method.name]!
                          : _formatResult(_results[method.name]),
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: hasError
                            ? Colors.red.shade800
                            : Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatResult(dynamic result) {
    if (result == null) return 'null';
    if (result is String) return result;
    if (result is Map || result is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(result);
      } catch (e) {
        return result.toString();
      }
    }
    return result.toString();
  }
}
