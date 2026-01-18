import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';

/// Method entry for a single controller method
class MethodEntry {
  final String name;
  final String description;
  final PlatformInAppWebViewControllerMethod methodEnum;
  final Map<String, dynamic> parameters;
  final List<String> requiredParameters;
  final Future<dynamic> Function(
    InAppWebViewController controller,
    Map<String, dynamic> params,
  )
  execute;

  const MethodEntry({
    required this.name,
    required this.description,
    required this.methodEnum,
    this.parameters = const {},
    this.requiredParameters = const [],
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
            parameters: {
              'url': 'https://example.com',
              'method': 'GET',
              'headers': <String, dynamic>{},
              'body': const ParameterValueHint<Uint8List?>(
                null,
                ParameterValueType.bytes,
              ),
            },
            requiredParameters: ['url'],
            execute: (controller, params) async {
              final url = params['url']?.toString() ?? '';
              final method = params['method']?.toString();
              final headers = (params['headers'] as Map?)?.map(
                (key, value) => MapEntry(key.toString(), value),
              );
              final body = params['body'] as Uint8List?;

              await controller.loadUrl(
                urlRequest: URLRequest(
                  url: WebUri(url),
                  method: method?.isNotEmpty == true ? method : null,
                  headers: headers?.cast<String, String>(),
                  body: body,
                ),
              );
              return 'URL loaded successfully';
            },
          ),
          MethodEntry(
            name: 'postUrl',
            description: 'Loads URL using POST method',
            methodEnum: PlatformInAppWebViewControllerMethod.postUrl,
            parameters: {
              'url': 'https://httpbin.org/post',
              'postData': Uint8List.fromList('test=data'.codeUnits),
            },
            requiredParameters: ['url', 'postData'],
            execute: (controller, params) async {
              final url = params['url']?.toString() ?? '';
              final postData = params['postData'] as Uint8List?;
              await controller.postUrl(
                url: WebUri(url),
                postData: postData ?? Uint8List(0),
              );
              return 'POST request sent';
            },
          ),
          MethodEntry(
            name: 'loadData',
            description: 'Loads HTML data string',
            methodEnum: PlatformInAppWebViewControllerMethod.loadData,
            parameters: {
              'data': '<html><body><h1>Test HTML</h1></body></html>',
              'mimeType': 'text/html',
              'encoding': 'utf-8',
              'baseUrl': '',
              'historyUrl': '',
            },
            requiredParameters: ['data'],
            execute: (controller, params) async {
              final data = params['data']?.toString() ?? '';
              final mimeType = params['mimeType']?.toString();
              final encoding = params['encoding']?.toString();
              final baseUrl = params['baseUrl']?.toString();
              final historyUrl = params['historyUrl']?.toString();

              await controller.loadData(
                data: data,
                mimeType: mimeType?.isNotEmpty == true
                    ? mimeType!
                    : 'text/html',
                encoding: encoding?.isNotEmpty == true ? encoding! : 'utf-8',
                baseUrl: baseUrl?.isNotEmpty == true ? WebUri(baseUrl!) : null,
                historyUrl: historyUrl?.isNotEmpty == true
                    ? WebUri(historyUrl!)
                    : null,
              );
              return 'HTML data loaded';
            },
          ),
          MethodEntry(
            name: 'loadFile',
            description: 'Loads a file from assets',
            methodEnum: PlatformInAppWebViewControllerMethod.loadFile,
            parameters: {'assetFilePath': 'assets/index.html'},
            requiredParameters: ['assetFilePath'],
            execute: (controller, params) async {
              final path = params['assetFilePath']?.toString() ?? '';
              await controller.loadFile(assetFilePath: path);
              return 'File loaded from assets';
            },
          ),
          MethodEntry(
            name: 'reload',
            description: 'Reloads the current page',
            methodEnum: PlatformInAppWebViewControllerMethod.reload,
            execute: (controller, params) async {
              await controller.reload();
              return 'Page reloaded';
            },
          ),
          MethodEntry(
            name: 'reloadFromOrigin',
            description: 'Reloads bypassing cache',
            methodEnum: PlatformInAppWebViewControllerMethod.reloadFromOrigin,
            execute: (controller, params) async {
              await controller.reloadFromOrigin();
              return 'Page reloaded from origin';
            },
          ),
          MethodEntry(
            name: 'goBack',
            description: 'Navigates back in history',
            methodEnum: PlatformInAppWebViewControllerMethod.goBack,
            execute: (controller, params) async {
              await controller.goBack();
              return 'Navigated back';
            },
          ),
          MethodEntry(
            name: 'goForward',
            description: 'Navigates forward in history',
            methodEnum: PlatformInAppWebViewControllerMethod.goForward,
            execute: (controller, params) async {
              await controller.goForward();
              return 'Navigated forward';
            },
          ),
          MethodEntry(
            name: 'goBackOrForward',
            description: 'Navigates by steps',
            methodEnum: PlatformInAppWebViewControllerMethod.goBackOrForward,
            parameters: {'steps': -1},
            requiredParameters: ['steps'],
            execute: (controller, params) async {
              final steps = (params['steps'] as num?)?.toInt() ?? -1;
              await controller.goBackOrForward(steps: steps);
              return 'Navigated by steps';
            },
          ),
          MethodEntry(
            name: 'goTo',
            description: 'Navigates to history item',
            methodEnum: PlatformInAppWebViewControllerMethod.goTo,
            parameters: {'index': 0},
            requiredParameters: ['index'],
            execute: (controller, params) async {
              final history = await controller.getCopyBackForwardList();
              final index = (params['index'] as num?)?.toInt() ?? 0;
              if (history != null &&
                  history.list != null &&
                  history.list!.isNotEmpty &&
                  index >= 0 &&
                  index < history.list!.length) {
                await controller.goTo(historyItem: history.list![index]);
                return 'Navigated to history item';
              }
              return 'No history items available';
            },
          ),
          MethodEntry(
            name: 'canGoBack',
            description: 'Checks if can go back',
            methodEnum: PlatformInAppWebViewControllerMethod.canGoBack,
            execute: (controller, params) async {
              return await controller.canGoBack();
            },
          ),
          MethodEntry(
            name: 'canGoForward',
            description: 'Checks if can go forward',
            methodEnum: PlatformInAppWebViewControllerMethod.canGoForward,
            execute: (controller, params) async {
              return await controller.canGoForward();
            },
          ),
          MethodEntry(
            name: 'canGoBackOrForward',
            description: 'Checks if can navigate by steps',
            methodEnum: PlatformInAppWebViewControllerMethod.canGoBackOrForward,
            parameters: {'steps': -1},
            requiredParameters: ['steps'],
            execute: (controller, params) async {
              final steps = (params['steps'] as num?)?.toInt() ?? -1;
              return await controller.canGoBackOrForward(steps: steps);
            },
          ),
          MethodEntry(
            name: 'isLoading',
            description: 'Checks if page is loading',
            methodEnum: PlatformInAppWebViewControllerMethod.isLoading,
            execute: (controller, params) async {
              return await controller.isLoading();
            },
          ),
          MethodEntry(
            name: 'stopLoading',
            description: 'Stops page loading',
            methodEnum: PlatformInAppWebViewControllerMethod.stopLoading,
            execute: (controller, params) async {
              await controller.stopLoading();
              return 'Loading stopped';
            },
          ),
          MethodEntry(
            name: 'loadSimulatedRequest',
            description: 'Loads simulated request',
            methodEnum:
                PlatformInAppWebViewControllerMethod.loadSimulatedRequest,
            parameters: {
              'url': 'https://example.com',
              'data': Uint8List.fromList(
                '<html><body>Simulated</body></html>'.codeUnits,
              ),
            },
            requiredParameters: ['url', 'data'],
            execute: (controller, params) async {
              final url = params['url']?.toString() ?? '';
              final data = params['data'] as Uint8List?;
              await controller.loadSimulatedRequest(
                urlRequest: URLRequest(url: WebUri(url)),
                data: data ?? Uint8List(0),
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
            execute: (controller, params) async {
              return (await controller.getUrl())?.toString() ?? 'No URL';
            },
          ),
          MethodEntry(
            name: 'getTitle',
            description: 'Gets current page title',
            methodEnum: PlatformInAppWebViewControllerMethod.getTitle,
            execute: (controller, params) async {
              return await controller.getTitle() ?? 'No title';
            },
          ),
          MethodEntry(
            name: 'getProgress',
            description: 'Gets page load progress',
            methodEnum: PlatformInAppWebViewControllerMethod.getProgress,
            execute: (controller, params) async {
              return await controller.getProgress();
            },
          ),
          MethodEntry(
            name: 'getHtml',
            description: 'Gets page HTML source',
            methodEnum: PlatformInAppWebViewControllerMethod.getHtml,
            execute: (controller, params) async {
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
            execute: (controller, params) async {
              final favicons = await controller.getFavicons();
              return 'Found ${favicons.length} favicons';
            },
          ),
          MethodEntry(
            name: 'getOriginalUrl',
            description: 'Gets original URL before redirects',
            methodEnum: PlatformInAppWebViewControllerMethod.getOriginalUrl,
            execute: (controller, params) async {
              return (await controller.getOriginalUrl())?.toString() ??
                  'No URL';
            },
          ),
          MethodEntry(
            name: 'getSelectedText',
            description: 'Gets selected text',
            methodEnum: PlatformInAppWebViewControllerMethod.getSelectedText,
            execute: (controller, params) async {
              return await controller.getSelectedText() ?? 'No selection';
            },
          ),
          MethodEntry(
            name: 'getHitTestResult',
            description: 'Gets hit test result',
            methodEnum: PlatformInAppWebViewControllerMethod.getHitTestResult,
            execute: (controller, params) async {
              final result = await controller.getHitTestResult();
              return result?.type.toString() ?? 'No hit test result';
            },
          ),
          MethodEntry(
            name: 'getMetaTags',
            description: 'Gets meta tags from page',
            methodEnum: PlatformInAppWebViewControllerMethod.getMetaTags,
            execute: (controller, params) async {
              final tags = await controller.getMetaTags();
              return 'Found ${tags.length} meta tags';
            },
          ),
          MethodEntry(
            name: 'getMetaThemeColor',
            description: 'Gets meta theme color',
            methodEnum: PlatformInAppWebViewControllerMethod.getMetaThemeColor,
            execute: (controller, params) async {
              final color = await controller.getMetaThemeColor();
              return color?.toString() ?? 'No theme color';
            },
          ),
          MethodEntry(
            name: 'getCertificate',
            description: 'Gets SSL certificate',
            methodEnum: PlatformInAppWebViewControllerMethod.getCertificate,
            execute: (controller, params) async {
              final cert = await controller.getCertificate();
              return cert?.issuedTo?.CName ?? 'No certificate';
            },
          ),
          MethodEntry(
            name: 'getCopyBackForwardList',
            description: 'Gets navigation history',
            methodEnum:
                PlatformInAppWebViewControllerMethod.getCopyBackForwardList,
            execute: (controller, params) async {
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
            parameters: {'source': 'document.title'},
            requiredParameters: ['source'],
            execute: (controller, params) async {
              return await controller.evaluateJavascript(
                source: params['source']?.toString() ?? '',
              );
            },
          ),
          MethodEntry(
            name: 'callAsyncJavaScript',
            description: 'Calls async JavaScript function',
            methodEnum:
                PlatformInAppWebViewControllerMethod.callAsyncJavaScript,
            parameters: {
              'functionBody': 'return await Promise.resolve("async result");',
              'arguments': <String, dynamic>{},
            },
            requiredParameters: ['functionBody'],
            execute: (controller, params) async {
              final arguments = params['arguments'] as Map?;
              final result = await controller.callAsyncJavaScript(
                functionBody: params['functionBody']?.toString() ?? '',
                arguments: arguments?.cast<String, dynamic>() ?? const {},
              );
              return result?.value ?? 'No result';
            },
          ),
          MethodEntry(
            name: 'injectJavascriptFileFromUrl',
            description: 'Injects JS file from URL',
            methodEnum: PlatformInAppWebViewControllerMethod
                .injectJavascriptFileFromUrl,
            parameters: {
              'urlFile': 'https://code.jquery.com/jquery-3.7.1.min.js',
            },
            requiredParameters: ['urlFile'],
            execute: (controller, params) async {
              await controller.injectJavascriptFileFromUrl(
                urlFile: WebUri(params['urlFile']?.toString() ?? ''),
              );
              return 'JavaScript file injected';
            },
          ),
          MethodEntry(
            name: 'injectJavascriptFileFromAsset',
            description: 'Injects JS file from assets',
            methodEnum: PlatformInAppWebViewControllerMethod
                .injectJavascriptFileFromAsset,
            parameters: {'assetFilePath': 'assets/js/script.js'},
            requiredParameters: ['assetFilePath'],
            execute: (controller, params) async {
              try {
                await controller.injectJavascriptFileFromAsset(
                  assetFilePath: params['assetFilePath']?.toString() ?? '',
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
            parameters: {
              'source': 'body { background-color: #f0f0f0 !important; }',
            },
            requiredParameters: ['source'],
            execute: (controller, params) async {
              await controller.injectCSSCode(
                source: params['source']?.toString() ?? '',
              );
              return 'CSS code injected';
            },
          ),
          MethodEntry(
            name: 'injectCSSFileFromUrl',
            description: 'Injects CSS file from URL',
            methodEnum:
                PlatformInAppWebViewControllerMethod.injectCSSFileFromUrl,
            parameters: {
              'urlFile':
                  'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css',
            },
            requiredParameters: ['urlFile'],
            execute: (controller, params) async {
              await controller.injectCSSFileFromUrl(
                urlFile: WebUri(params['urlFile']?.toString() ?? ''),
              );
              return 'CSS file injected';
            },
          ),
          MethodEntry(
            name: 'injectCSSFileFromAsset',
            description: 'Injects CSS file from assets',
            methodEnum:
                PlatformInAppWebViewControllerMethod.injectCSSFileFromAsset,
            parameters: {'assetFilePath': 'assets/css/style.css'},
            requiredParameters: ['assetFilePath'],
            execute: (controller, params) async {
              try {
                await controller.injectCSSFileFromAsset(
                  assetFilePath: params['assetFilePath']?.toString() ?? '',
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
            parameters: {'handlerName': 'testHandler'},
            requiredParameters: ['handlerName'],
            execute: (controller, params) async {
              final handlerName = params['handlerName']?.toString() ?? '';
              controller.addJavaScriptHandler(
                handlerName: handlerName,
                callback: (args) {
                  return {'received': args};
                },
              );
              return 'Handler "$handlerName" added';
            },
          ),
          MethodEntry(
            name: 'removeJavaScriptHandler',
            description: 'Removes a JavaScript handler',
            methodEnum:
                PlatformInAppWebViewControllerMethod.removeJavaScriptHandler,
            parameters: {'handlerName': 'testHandler'},
            requiredParameters: ['handlerName'],
            execute: (controller, params) async {
              final removed = controller.removeJavaScriptHandler(
                handlerName: params['handlerName']?.toString() ?? '',
              );
              return removed != null ? 'Handler removed' : 'Handler not found';
            },
          ),
          MethodEntry(
            name: 'hasJavaScriptHandler',
            description: 'Checks if handler exists',
            methodEnum:
                PlatformInAppWebViewControllerMethod.hasJavaScriptHandler,
            parameters: {'handlerName': 'testHandler'},
            requiredParameters: ['handlerName'],
            execute: (controller, params) async {
              return controller.hasJavaScriptHandler(
                handlerName: params['handlerName']?.toString() ?? '',
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
            parameters: {
              'source': 'console.log("User script executed");',
              'injectionTime': 'AT_DOCUMENT_END',
              'groupName': 'testGroup',
            },
            requiredParameters: ['source'],
            execute: (controller, params) async {
              final injectionTime = _parseUserScriptInjectionTime(
                params['injectionTime']?.toString(),
              );
              await controller.addUserScript(
                userScript: UserScript(
                  source: params['source']?.toString() ?? '',
                  injectionTime: injectionTime,
                  groupName: params['groupName']?.toString(),
                ),
              );
              return 'User script added';
            },
          ),
          MethodEntry(
            name: 'removeUserScript',
            description: 'Removes a user script',
            methodEnum: PlatformInAppWebViewControllerMethod.removeUserScript,
            parameters: {
              'source': 'console.log("User script executed");',
              'injectionTime': 'AT_DOCUMENT_END',
              'groupName': 'testGroup',
            },
            requiredParameters: ['source'],
            execute: (controller, params) async {
              final injectionTime = _parseUserScriptInjectionTime(
                params['injectionTime']?.toString(),
              );
              final script = UserScript(
                source: params['source']?.toString() ?? '',
                injectionTime: injectionTime,
                groupName: params['groupName']?.toString(),
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
            parameters: {'groupName': 'testGroup'},
            requiredParameters: ['groupName'],
            execute: (controller, params) async {
              await controller.removeUserScriptsByGroupName(
                groupName: params['groupName']?.toString() ?? '',
              );
              return 'Scripts in group removed';
            },
          ),
          MethodEntry(
            name: 'removeAllUserScripts',
            description: 'Removes all user scripts',
            methodEnum:
                PlatformInAppWebViewControllerMethod.removeAllUserScripts,
            execute: (controller, params) async {
              await controller.removeAllUserScripts();
              return 'All user scripts removed';
            },
          ),
          MethodEntry(
            name: 'hasUserScript',
            description: 'Checks if user script exists',
            methodEnum: PlatformInAppWebViewControllerMethod.hasUserScript,
            parameters: {
              'source': 'console.log("test");',
              'injectionTime': 'AT_DOCUMENT_END',
            },
            requiredParameters: ['source'],
            execute: (controller, params) async {
              final injectionTime = _parseUserScriptInjectionTime(
                params['injectionTime']?.toString(),
              );
              final script = UserScript(
                source: params['source']?.toString() ?? '',
                injectionTime: injectionTime,
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
            parameters: {'x': 0, 'y': 100, 'animated': true},
            execute: (controller, params) async {
              final x = (params['x'] as num?)?.toInt() ?? 0;
              final y = (params['y'] as num?)?.toInt() ?? 0;
              final animated = params['animated'] as bool? ?? true;
              await controller.scrollTo(x: x, y: y, animated: animated);
              return 'Scrolled to (0, 100)';
            },
          ),
          MethodEntry(
            name: 'scrollBy',
            description: 'Scrolls by offset',
            methodEnum: PlatformInAppWebViewControllerMethod.scrollBy,
            parameters: {'x': 0, 'y': 50, 'animated': true},
            execute: (controller, params) async {
              final x = (params['x'] as num?)?.toInt() ?? 0;
              final y = (params['y'] as num?)?.toInt() ?? 0;
              final animated = params['animated'] as bool? ?? true;
              await controller.scrollBy(x: x, y: y, animated: animated);
              return 'Scrolled by (0, 50)';
            },
          ),
          MethodEntry(
            name: 'getScrollX',
            description: 'Gets horizontal scroll position',
            methodEnum: PlatformInAppWebViewControllerMethod.getScrollX,
            execute: (controller, params) async {
              return await controller.getScrollX();
            },
          ),
          MethodEntry(
            name: 'getScrollY',
            description: 'Gets vertical scroll position',
            methodEnum: PlatformInAppWebViewControllerMethod.getScrollY,
            execute: (controller, params) async {
              return await controller.getScrollY();
            },
          ),
          MethodEntry(
            name: 'getContentHeight',
            description: 'Gets content height',
            methodEnum: PlatformInAppWebViewControllerMethod.getContentHeight,
            execute: (controller, params) async {
              return await controller.getContentHeight();
            },
          ),
          MethodEntry(
            name: 'getContentWidth',
            description: 'Gets content width',
            methodEnum: PlatformInAppWebViewControllerMethod.getContentWidth,
            execute: (controller, params) async {
              return await controller.getContentWidth();
            },
          ),
          MethodEntry(
            name: 'canScrollVertically',
            description: 'Checks if can scroll vertically',
            methodEnum:
                PlatformInAppWebViewControllerMethod.canScrollVertically,
            execute: (controller, params) async {
              return await controller.canScrollVertically();
            },
          ),
          MethodEntry(
            name: 'canScrollHorizontally',
            description: 'Checks if can scroll horizontally',
            methodEnum:
                PlatformInAppWebViewControllerMethod.canScrollHorizontally,
            execute: (controller, params) async {
              return await controller.canScrollHorizontally();
            },
          ),
          MethodEntry(
            name: 'pageDown',
            description: 'Scrolls page down',
            methodEnum: PlatformInAppWebViewControllerMethod.pageDown,
            parameters: {'bottom': false},
            execute: (controller, params) async {
              final bottom = params['bottom'] as bool? ?? false;
              return await controller.pageDown(bottom: bottom);
            },
          ),
          MethodEntry(
            name: 'pageUp',
            description: 'Scrolls page up',
            methodEnum: PlatformInAppWebViewControllerMethod.pageUp,
            parameters: {'top': false},
            execute: (controller, params) async {
              final top = params['top'] as bool? ?? false;
              return await controller.pageUp(top: top);
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
            parameters: {'zoomFactor': 1.5, 'animated': true},
            requiredParameters: ['zoomFactor'],
            execute: (controller, params) async {
              final zoomFactor =
                  (params['zoomFactor'] as num?)?.toDouble() ?? 1.0;
              final animated = params['animated'] as bool? ?? true;
              await controller.zoomBy(
                zoomFactor: zoomFactor,
                animated: animated,
              );
              return 'Zoomed to 1.5x';
            },
          ),
          MethodEntry(
            name: 'zoomIn',
            description: 'Zooms in',
            methodEnum: PlatformInAppWebViewControllerMethod.zoomIn,
            execute: (controller, params) async {
              return await controller.zoomIn();
            },
          ),
          MethodEntry(
            name: 'zoomOut',
            description: 'Zooms out',
            methodEnum: PlatformInAppWebViewControllerMethod.zoomOut,
            execute: (controller, params) async {
              return await controller.zoomOut();
            },
          ),
          MethodEntry(
            name: 'getZoomScale',
            description: 'Gets current zoom scale',
            methodEnum: PlatformInAppWebViewControllerMethod.getZoomScale,
            execute: (controller, params) async {
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
            parameters: {'javaScriptEnabled': true, 'supportZoom': true},
            execute: (controller, params) async {
              await controller.setSettings(
                settings: InAppWebViewSettings(
                  javaScriptEnabled: params['javaScriptEnabled'] as bool?,
                  supportZoom: params['supportZoom'] as bool?,
                ),
              );
              return 'Settings updated';
            },
          ),
          MethodEntry(
            name: 'getSettings',
            description: 'Gets WebView settings',
            methodEnum: PlatformInAppWebViewControllerMethod.getSettings,
            execute: (controller, params) async {
              final settings = await controller.getSettings();
              return 'JS enabled: ${settings?.javaScriptEnabled}';
            },
          ),
          MethodEntry(
            name: 'setContextMenu',
            description: 'Sets context menu',
            methodEnum: PlatformInAppWebViewControllerMethod.setContextMenu,
            parameters: {'menuItemTitle': 'Test Item'},
            execute: (controller, params) async {
              await controller.setContextMenu(
                ContextMenu(
                  menuItems: [
                    ContextMenuItem(
                      id: 1,
                      title: params['menuItemTitle']?.toString() ?? 'Item',
                      action: () {},
                    ),
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
            execute: (controller, params) async {
              return await controller.requestFocus();
            },
          ),
          MethodEntry(
            name: 'clearFocus',
            description: 'Clears focus from WebView',
            methodEnum: PlatformInAppWebViewControllerMethod.clearFocus,
            execute: (controller, params) async {
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
            execute: (controller, params) async {
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
            execute: (controller, params) async {
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
            execute: (controller, params) async {
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
            execute: (controller, params) async {
              await controller.clearHistory();
              return 'History cleared';
            },
          ),
          MethodEntry(
            name: 'clearFormData',
            description: 'Clears form data',
            methodEnum: PlatformInAppWebViewControllerMethod.clearFormData,
            execute: (controller, params) async {
              await controller.clearFormData();
              return 'Form data cleared';
            },
          ),
          MethodEntry(
            name: 'clearSslPreferences',
            description: 'Clears SSL preferences',
            methodEnum:
                PlatformInAppWebViewControllerMethod.clearSslPreferences,
            execute: (controller, params) async {
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
            execute: (controller, params) async {
              await controller.pause();
              return 'WebView paused';
            },
          ),
          MethodEntry(
            name: 'resume',
            description: 'Resumes WebView',
            methodEnum: PlatformInAppWebViewControllerMethod.resume,
            execute: (controller, params) async {
              await controller.resume();
              return 'WebView resumed';
            },
          ),
          MethodEntry(
            name: 'pauseTimers',
            description: 'Pauses JavaScript timers',
            methodEnum: PlatformInAppWebViewControllerMethod.pauseTimers,
            execute: (controller, params) async {
              await controller.pauseTimers();
              return 'Timers paused';
            },
          ),
          MethodEntry(
            name: 'resumeTimers',
            description: 'Resumes JavaScript timers',
            methodEnum: PlatformInAppWebViewControllerMethod.resumeTimers,
            execute: (controller, params) async {
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
            execute: (controller, params) async {
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
            parameters: {'message': 'Hello from Flutter', 'targetOrigin': '*'},
            requiredParameters: ['message'],
            execute: (controller, params) async {
              final targetOrigin = params['targetOrigin']?.toString();
              await controller.postWebMessage(
                message: WebMessage(data: params['message']?.toString()),
                targetOrigin: WebUri(
                  targetOrigin?.isNotEmpty == true ? targetOrigin! : '*',
                ),
              );
              return 'Message posted';
            },
          ),
          MethodEntry(
            name: 'addWebMessageListener',
            description: 'Adds a web message listener',
            methodEnum:
                PlatformInAppWebViewControllerMethod.addWebMessageListener,
            parameters: {'jsObjectName': 'testListener'},
            requiredParameters: ['jsObjectName'],
            execute: (controller, params) async {
              await controller.addWebMessageListener(
                WebMessageListener(
                  jsObjectName: params['jsObjectName']?.toString() ?? '',
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
            parameters: {'jsObjectName': 'testListener'},
            requiredParameters: ['jsObjectName'],
            execute: (controller, params) async {
              final listener = WebMessageListener(
                jsObjectName: params['jsObjectName']?.toString() ?? '',
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
            execute: (controller, params) async {
              return await controller.isInFullscreen();
            },
          ),
          MethodEntry(
            name: 'pauseAllMediaPlayback',
            description: 'Pauses all media',
            methodEnum:
                PlatformInAppWebViewControllerMethod.pauseAllMediaPlayback,
            execute: (controller, params) async {
              await controller.pauseAllMediaPlayback();
              return 'Media paused';
            },
          ),
          MethodEntry(
            name: 'setAllMediaPlaybackSuspended',
            description: 'Suspends media playback',
            methodEnum: PlatformInAppWebViewControllerMethod
                .setAllMediaPlaybackSuspended,
            parameters: {'suspended': true},
            execute: (controller, params) async {
              await controller.setAllMediaPlaybackSuspended(
                suspended: params['suspended'] as bool? ?? true,
              );
              return 'Media suspended';
            },
          ),
          MethodEntry(
            name: 'closeAllMediaPresentations',
            description: 'Closes media presentations',
            methodEnum:
                PlatformInAppWebViewControllerMethod.closeAllMediaPresentations,
            execute: (controller, params) async {
              await controller.closeAllMediaPresentations();
              return 'Media presentations closed';
            },
          ),
          MethodEntry(
            name: 'requestMediaPlaybackState',
            description: 'Gets media playback state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.requestMediaPlaybackState,
            execute: (controller, params) async {
              final state = await controller.requestMediaPlaybackState();
              return state?.toString() ?? 'Unknown state';
            },
          ),
          MethodEntry(
            name: 'isPlayingAudio',
            description: 'Checks if playing audio',
            methodEnum: PlatformInAppWebViewControllerMethod.isPlayingAudio,
            execute: (controller, params) async {
              return await controller.isPlayingAudio();
            },
          ),
          MethodEntry(
            name: 'isMuted',
            description: 'Checks if muted',
            methodEnum: PlatformInAppWebViewControllerMethod.isMuted,
            execute: (controller, params) async {
              return await controller.isMuted();
            },
          ),
          MethodEntry(
            name: 'setMuted',
            description: 'Sets mute state',
            methodEnum: PlatformInAppWebViewControllerMethod.setMuted,
            parameters: {'muted': true},
            execute: (controller, params) async {
              await controller.setMuted(
                muted: params['muted'] as bool? ?? true,
              );
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
            execute: (controller, params) async {
              final state = await controller.getCameraCaptureState();
              return state?.toString() ?? 'Unknown state';
            },
          ),
          MethodEntry(
            name: 'setCameraCaptureState',
            description: 'Sets camera capture state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.setCameraCaptureState,
            parameters: {'state': 'ACTIVE'},
            requiredParameters: ['state'],
            execute: (controller, params) async {
              await controller.setCameraCaptureState(
                state: _parseMediaCaptureState(params['state']?.toString()),
              );
              return 'Camera state set';
            },
          ),
          MethodEntry(
            name: 'getMicrophoneCaptureState',
            description: 'Gets microphone capture state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.getMicrophoneCaptureState,
            execute: (controller, params) async {
              final state = await controller.getMicrophoneCaptureState();
              return state?.toString() ?? 'Unknown state';
            },
          ),
          MethodEntry(
            name: 'setMicrophoneCaptureState',
            description: 'Sets microphone capture state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.setMicrophoneCaptureState,
            parameters: {'state': 'ACTIVE'},
            requiredParameters: ['state'],
            execute: (controller, params) async {
              await controller.setMicrophoneCaptureState(
                state: _parseMediaCaptureState(params['state']?.toString()),
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
            execute: (controller, params) async {
              return await controller.isSecureContext();
            },
          ),
          MethodEntry(
            name: 'hasOnlySecureContent',
            description: 'Checks if only secure content',
            methodEnum:
                PlatformInAppWebViewControllerMethod.hasOnlySecureContent,
            execute: (controller, params) async {
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
            execute: (controller, params) async {
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
            execute: (controller, params) async {
              // Would need saved state to restore
              return 'No state to restore';
            },
          ),
          MethodEntry(
            name: 'saveWebArchive',
            description: 'Saves page as web archive',
            methodEnum: PlatformInAppWebViewControllerMethod.saveWebArchive,
            parameters: {'filePath': '/tmp/archive.mht', 'autoname': true},
            requiredParameters: ['filePath'],
            execute: (controller, params) async {
              try {
                final path = await controller.saveWebArchive(
                  filePath: params['filePath']?.toString() ?? '',
                  autoname: params['autoname'] as bool? ?? true,
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
            execute: (controller, params) async {
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
            execute: (controller, params) async {
              return controller.getViewId();
            },
          ),
          MethodEntry(
            name: 'startSafeBrowsing',
            description: 'Starts Safe Browsing',
            methodEnum: PlatformInAppWebViewControllerMethod.startSafeBrowsing,
            execute: (controller, params) async {
              return await controller.startSafeBrowsing();
            },
          ),
          MethodEntry(
            name: 'openDevTools',
            description: 'Opens DevTools',
            methodEnum: PlatformInAppWebViewControllerMethod.openDevTools,
            execute: (controller, params) async {
              await controller.openDevTools();
              return 'DevTools opened';
            },
          ),
          MethodEntry(
            name: 'requestFocusNodeHref',
            description: 'Gets focused node href',
            methodEnum:
                PlatformInAppWebViewControllerMethod.requestFocusNodeHref,
            execute: (controller, params) async {
              final result = await controller.requestFocusNodeHref();
              return result?.url ?? 'No focused node';
            },
          ),
          MethodEntry(
            name: 'requestImageRef',
            description: 'Gets focused image URL',
            methodEnum: PlatformInAppWebViewControllerMethod.requestImageRef,
            execute: (controller, params) async {
              final result = await controller.requestImageRef();
              return result?.url ?? 'No image focused';
            },
          ),
          MethodEntry(
            name: 'isInterfaceSupported',
            description: 'Checks interface support',
            methodEnum:
                PlatformInAppWebViewControllerMethod.isInterfaceSupported,
            parameters: {'interface': 'ICoreWebView2'},
            requiredParameters: ['interface'],
            execute: (controller, params) async {
              return await controller.isInterfaceSupported(
                _parseWebViewInterface(params['interface']?.toString()),
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
      Map<String, dynamic> params = entry.parameters;
      if (entry.parameters.isNotEmpty) {
        final updatedParams = await showParameterDialog(
          context: context,
          title: '${entry.name} parameters',
          parameters: entry.parameters,
          requiredPaths: entry.requiredParameters,
        );

        if (updatedParams == null) {
          if (mounted) {
            setState(() {
              _executing[entry.name] = false;
            });
          }
          return;
        }
        params = updatedParams;
      }

      final result = await entry.execute(widget.controller!, params);
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
    final supportedPlatforms = SupportCheckHelper.supportedPlatformsForMethod(
      method: method.methodEnum,
      checker: InAppWebViewController.isMethodSupported,
    );

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  SupportBadgesRow(
                    supportedPlatforms: supportedPlatforms,
                    compact: true,
                  ),
                ],
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

  UserScriptInjectionTime _parseUserScriptInjectionTime(String? value) {
    if (value == null || value.isEmpty) {
      return UserScriptInjectionTime.AT_DOCUMENT_END;
    }
    return UserScriptInjectionTime.values.firstWhere(
      (entry) => entry.name().toLowerCase() == value.toLowerCase(),
      orElse: () => UserScriptInjectionTime.AT_DOCUMENT_END,
    );
  }

  MediaCaptureState _parseMediaCaptureState(String? value) {
    if (value == null || value.isEmpty) {
      return MediaCaptureState.ACTIVE;
    }
    return MediaCaptureState.values.firstWhere(
      (entry) => entry.name().toLowerCase() == value.toLowerCase(),
      orElse: () => MediaCaptureState.ACTIVE,
    );
  }

  WebViewInterface _parseWebViewInterface(String? value) {
    if (value == null || value.isEmpty) {
      return WebViewInterface.ICoreWebView2;
    }
    return WebViewInterface.values.firstWhere(
      (entry) => entry.name().toLowerCase() == value.toLowerCase(),
      orElse: () => WebViewInterface.ICoreWebView2,
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
