import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/utils/support_checker.dart';
import 'package:flutter_inappwebview_example/widgets/common/support_badge.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';
import 'package:flutter_inappwebview_example/widgets/common/method_result_history.dart';

/// Method entry for a single controller method
class MethodEntry {
  /// The method enum that this entry represents.
  /// The name is derived from methodEnum.name.
  final PlatformInAppWebViewControllerMethod methodEnum;
  final String description;
  final Map<String, dynamic> parameters;
  final List<String> requiredParameters;
  final Future<dynamic> Function(
    InAppWebViewController controller,
    Map<String, dynamic> params,
  )
  execute;

  const MethodEntry({
    required this.methodEnum,
    required this.description,
    this.parameters = const {},
    this.requiredParameters = const [],
    required this.execute,
  });

  /// The display name derived from methodEnum.name
  String get name => methodEnum.name;
}

/// Enum representing the categories of controller methods for the tester widget
enum MethodCategoryType {
  navigation('Navigation & Loading', Icons.navigation),
  pageInfo('Page Info & Content', Icons.info_outline),
  javascript('JavaScript Execution', Icons.code),
  jsHandlers('JavaScript Handlers', Icons.link),
  userScripts('User Scripts', Icons.description),
  scrolling('Scrolling & Layout', Icons.swap_vert),
  zoom('Zoom', Icons.zoom_in),
  settings('Settings & State', Icons.settings),
  screenshotPrint('Screenshot & Print', Icons.camera_alt),
  cacheHistory('Cache & History', Icons.history),
  pauseResume('Pause & Resume', Icons.pause_circle_outline),
  webMessaging('Web Messaging', Icons.message),
  media('Media & Fullscreen', Icons.play_circle_outline),
  cameraMic('Camera & Microphone', Icons.videocam),
  security('Security', Icons.security),
  saveRestore('Save & Restore', Icons.save),
  misc('Misc/Advanced', Icons.more_horiz);

  final String displayName;
  final IconData icon;

  const MethodCategoryType(this.displayName, this.icon);
}

/// A category of methods
class MethodCategory {
  /// The category type enum - name and icon are derived from this
  final MethodCategoryType categoryType;
  final List<MethodEntry> methods;

  const MethodCategory({required this.categoryType, required this.methods});

  /// The display name derived from categoryType.displayName
  String get name => categoryType.displayName;

  /// The icon derived from categoryType.icon
  IconData get icon => categoryType.icon;
}

/// Widget to test WebView controller methods
/// Tests controller methods organized by category
class MethodTesterWidget extends StatefulWidget {
  final InAppWebViewController? controller;

  const MethodTesterWidget({super.key, required this.controller});

  @override
  State<MethodTesterWidget> createState() => _MethodTesterWidgetState();
}

class _MethodTesterWidgetState extends State<MethodTesterWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, List<MethodResultEntry>> _methodHistory = {};
  final Map<String, int> _selectedHistoryIndex = {};
  final Map<String, bool> _executing = {};
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
        categoryType: MethodCategoryType.navigation,
        methods: [
          MethodEntry(
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
            description: 'Loads URL using POST method',
            methodEnum: PlatformInAppWebViewControllerMethod.postUrl,
            parameters: {
              'url': 'https://httpbin.org/post',
              'postData': const ParameterValueHint<Uint8List?>(
                null,
                ParameterValueType.bytes,
              ),
            },
            requiredParameters: ['url', 'postData'],
            execute: (controller, params) async {
              final url = params['url']?.toString() ?? '';
              Uint8List? postData;
              final postDataParam = params['postData'];
              if (postDataParam is Uint8List) {
                postData = postDataParam;
              } else if (postDataParam is String && postDataParam.isNotEmpty) {
                // Convert string to bytes (UTF-8)
                postData = Uint8List.fromList(postDataParam.codeUnits);
              }
              await controller.postUrl(
                url: WebUri(url),
                postData: postData ?? Uint8List(0),
              );
              return 'POST request sent with ${postData?.length ?? 0} bytes';
            },
          ),
          MethodEntry(
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
            description: 'Reloads the current page',
            methodEnum: PlatformInAppWebViewControllerMethod.reload,
            execute: (controller, params) async {
              await controller.reload();
              return 'Page reloaded';
            },
          ),
          MethodEntry(
            description: 'Reloads bypassing cache',
            methodEnum: PlatformInAppWebViewControllerMethod.reloadFromOrigin,
            execute: (controller, params) async {
              await controller.reloadFromOrigin();
              return 'Page reloaded from origin';
            },
          ),
          MethodEntry(
            description: 'Navigates back in history',
            methodEnum: PlatformInAppWebViewControllerMethod.goBack,
            execute: (controller, params) async {
              await controller.goBack();
              return 'Navigated back';
            },
          ),
          MethodEntry(
            description: 'Navigates forward in history',
            methodEnum: PlatformInAppWebViewControllerMethod.goForward,
            execute: (controller, params) async {
              await controller.goForward();
              return 'Navigated forward';
            },
          ),
          MethodEntry(
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
            description: 'Checks if can go back',
            methodEnum: PlatformInAppWebViewControllerMethod.canGoBack,
            execute: (controller, params) async {
              return await controller.canGoBack();
            },
          ),
          MethodEntry(
            description: 'Checks if can go forward',
            methodEnum: PlatformInAppWebViewControllerMethod.canGoForward,
            execute: (controller, params) async {
              return await controller.canGoForward();
            },
          ),
          MethodEntry(
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
            description: 'Checks if page is loading',
            methodEnum: PlatformInAppWebViewControllerMethod.isLoading,
            execute: (controller, params) async {
              return await controller.isLoading();
            },
          ),
          MethodEntry(
            description: 'Stops page loading',
            methodEnum: PlatformInAppWebViewControllerMethod.stopLoading,
            execute: (controller, params) async {
              await controller.stopLoading();
              return 'Loading stopped';
            },
          ),
          MethodEntry(
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
        categoryType: MethodCategoryType.pageInfo,
        methods: [
          MethodEntry(
            description: 'Gets current page URL',
            methodEnum: PlatformInAppWebViewControllerMethod.getUrl,
            execute: (controller, params) async {
              return (await controller.getUrl())?.toString() ?? 'No URL';
            },
          ),
          MethodEntry(
            description: 'Gets current page title',
            methodEnum: PlatformInAppWebViewControllerMethod.getTitle,
            execute: (controller, params) async {
              return await controller.getTitle() ?? 'No title';
            },
          ),
          MethodEntry(
            description: 'Gets page load progress',
            methodEnum: PlatformInAppWebViewControllerMethod.getProgress,
            execute: (controller, params) async {
              return await controller.getProgress();
            },
          ),
          MethodEntry(
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
            description: 'Gets page favicons',
            methodEnum: PlatformInAppWebViewControllerMethod.getFavicons,
            execute: (controller, params) async {
              final favicons = await controller.getFavicons();
              return 'Found ${favicons.length} favicons';
            },
          ),
          MethodEntry(
            description: 'Gets original URL before redirects',
            methodEnum: PlatformInAppWebViewControllerMethod.getOriginalUrl,
            execute: (controller, params) async {
              return (await controller.getOriginalUrl())?.toString() ??
                  'No URL';
            },
          ),
          MethodEntry(
            description: 'Gets selected text',
            methodEnum: PlatformInAppWebViewControllerMethod.getSelectedText,
            execute: (controller, params) async {
              return await controller.getSelectedText() ?? 'No selection';
            },
          ),
          MethodEntry(
            description: 'Gets hit test result',
            methodEnum: PlatformInAppWebViewControllerMethod.getHitTestResult,
            execute: (controller, params) async {
              final result = await controller.getHitTestResult();
              return result?.type.toString() ?? 'No hit test result';
            },
          ),
          MethodEntry(
            description: 'Gets meta tags from page',
            methodEnum: PlatformInAppWebViewControllerMethod.getMetaTags,
            execute: (controller, params) async {
              final tags = await controller.getMetaTags();
              return 'Found ${tags.length} meta tags';
            },
          ),
          MethodEntry(
            description: 'Gets meta theme color',
            methodEnum: PlatformInAppWebViewControllerMethod.getMetaThemeColor,
            execute: (controller, params) async {
              final color = await controller.getMetaThemeColor();
              return color?.toString() ?? 'No theme color';
            },
          ),
          MethodEntry(
            description: 'Gets SSL certificate info and X509 data',
            methodEnum: PlatformInAppWebViewControllerMethod.getCertificate,
            execute: (controller, params) async {
              final cert = await controller.getCertificate();
              if (cert == null) return {'error': 'No certificate available'};
              return cert.toMap();
            },
          ),
          MethodEntry(
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
        categoryType: MethodCategoryType.javascript,
        methods: [
          MethodEntry(
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
        categoryType: MethodCategoryType.jsHandlers,
        methods: [
          MethodEntry(
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
        categoryType: MethodCategoryType.userScripts,
        methods: [
          MethodEntry(
            description: 'Adds a user script',
            methodEnum: PlatformInAppWebViewControllerMethod.addUserScript,
            parameters: {
              'source': 'console.log("User script executed");',
              'injectionTime': EnumParameterValueHint<UserScriptInjectionTime>(
                UserScriptInjectionTime.AT_DOCUMENT_END,
                UserScriptInjectionTime.values.toList(),
                displayName: (e) => e.name(),
              ),
              'groupName': 'testGroup',
            },
            requiredParameters: ['source'],
            execute: (controller, params) async {
              final injectionTimeParam = params['injectionTime'];
              final injectionTime =
                  injectionTimeParam is UserScriptInjectionTime
                  ? injectionTimeParam
                  : _parseUserScriptInjectionTime(
                      injectionTimeParam?.toString(),
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
            description: 'Removes a user script',
            methodEnum: PlatformInAppWebViewControllerMethod.removeUserScript,
            parameters: {
              'source': 'console.log("User script executed");',
              'injectionTime': EnumParameterValueHint<UserScriptInjectionTime>(
                UserScriptInjectionTime.AT_DOCUMENT_END,
                UserScriptInjectionTime.values.toList(),
                displayName: (e) => e.name(),
              ),
              'groupName': 'testGroup',
            },
            requiredParameters: ['source'],
            execute: (controller, params) async {
              final injectionTimeParam = params['injectionTime'];
              final injectionTime =
                  injectionTimeParam is UserScriptInjectionTime
                  ? injectionTimeParam
                  : _parseUserScriptInjectionTime(
                      injectionTimeParam?.toString(),
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
            description: 'Removes all user scripts',
            methodEnum:
                PlatformInAppWebViewControllerMethod.removeAllUserScripts,
            execute: (controller, params) async {
              await controller.removeAllUserScripts();
              return 'All user scripts removed';
            },
          ),
          MethodEntry(
            description: 'Checks if user script exists',
            methodEnum: PlatformInAppWebViewControllerMethod.hasUserScript,
            parameters: {
              'source': 'console.log("test");',
              'injectionTime': EnumParameterValueHint<UserScriptInjectionTime>(
                UserScriptInjectionTime.AT_DOCUMENT_END,
                UserScriptInjectionTime.values.toList(),
                displayName: (e) => e.name(),
              ),
            },
            requiredParameters: ['source'],
            execute: (controller, params) async {
              final injectionTimeParam = params['injectionTime'];
              final injectionTime =
                  injectionTimeParam is UserScriptInjectionTime
                  ? injectionTimeParam
                  : _parseUserScriptInjectionTime(
                      injectionTimeParam?.toString(),
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
        categoryType: MethodCategoryType.scrolling,
        methods: [
          MethodEntry(
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
            description: 'Gets horizontal scroll position',
            methodEnum: PlatformInAppWebViewControllerMethod.getScrollX,
            execute: (controller, params) async {
              return await controller.getScrollX();
            },
          ),
          MethodEntry(
            description: 'Gets vertical scroll position',
            methodEnum: PlatformInAppWebViewControllerMethod.getScrollY,
            execute: (controller, params) async {
              return await controller.getScrollY();
            },
          ),
          MethodEntry(
            description: 'Gets content height',
            methodEnum: PlatformInAppWebViewControllerMethod.getContentHeight,
            execute: (controller, params) async {
              return await controller.getContentHeight();
            },
          ),
          MethodEntry(
            description: 'Gets content width',
            methodEnum: PlatformInAppWebViewControllerMethod.getContentWidth,
            execute: (controller, params) async {
              return await controller.getContentWidth();
            },
          ),
          MethodEntry(
            description: 'Checks if can scroll vertically',
            methodEnum:
                PlatformInAppWebViewControllerMethod.canScrollVertically,
            execute: (controller, params) async {
              return await controller.canScrollVertically();
            },
          ),
          MethodEntry(
            description: 'Checks if can scroll horizontally',
            methodEnum:
                PlatformInAppWebViewControllerMethod.canScrollHorizontally,
            execute: (controller, params) async {
              return await controller.canScrollHorizontally();
            },
          ),
          MethodEntry(
            description: 'Scrolls page down',
            methodEnum: PlatformInAppWebViewControllerMethod.pageDown,
            parameters: {'bottom': false},
            execute: (controller, params) async {
              final bottom = params['bottom'] as bool? ?? false;
              return await controller.pageDown(bottom: bottom);
            },
          ),
          MethodEntry(
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
        categoryType: MethodCategoryType.zoom,
        methods: [
          MethodEntry(
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
            description: 'Zooms in',
            methodEnum: PlatformInAppWebViewControllerMethod.zoomIn,
            execute: (controller, params) async {
              return await controller.zoomIn();
            },
          ),
          MethodEntry(
            description: 'Zooms out',
            methodEnum: PlatformInAppWebViewControllerMethod.zoomOut,
            execute: (controller, params) async {
              return await controller.zoomOut();
            },
          ),
          MethodEntry(
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
        categoryType: MethodCategoryType.settings,
        methods: [
          MethodEntry(
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
            description: 'Gets WebView settings',
            methodEnum: PlatformInAppWebViewControllerMethod.getSettings,
            execute: (controller, params) async {
              final settings = await controller.getSettings();
              return 'JS enabled: ${settings?.javaScriptEnabled}';
            },
          ),
          MethodEntry(
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
            description: 'Requests focus for WebView',
            methodEnum: PlatformInAppWebViewControllerMethod.requestFocus,
            execute: (controller, params) async {
              return await controller.requestFocus();
            },
          ),
          MethodEntry(
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
        categoryType: MethodCategoryType.screenshotPrint,
        methods: [
          MethodEntry(
            description: 'Takes a screenshot',
            methodEnum: PlatformInAppWebViewControllerMethod.takeScreenshot,
            parameters: {
              'compressFormat': EnumParameterValueHint<CompressFormat>(
                CompressFormat.PNG,
                CompressFormat.values.toList(),
                displayName: (e) => e.name(),
              ),
              'quality': 100,
              'snapshotWidth': const ParameterValueHint<double?>(
                null,
                ParameterValueType.number,
              ),
            },
            execute: (controller, params) async {
              final compressFormatParam = params['compressFormat'];
              final compressFormat = compressFormatParam is CompressFormat
                  ? compressFormatParam
                  : CompressFormat.PNG;
              final quality = (params['quality'] as num?)?.toInt() ?? 100;
              final snapshotWidthParam = params['snapshotWidth'];
              final snapshotWidth = snapshotWidthParam is ParameterValueHint
                  ? (snapshotWidthParam.value as num?)?.toDouble()
                  : (snapshotWidthParam as num?)?.toDouble();

              final screenshot = await controller.takeScreenshot(
                screenshotConfiguration: ScreenshotConfiguration(
                  compressFormat: compressFormat,
                  quality: quality,
                  snapshotWidth: snapshotWidth,
                ),
              );
              if (screenshot != null) {
                return 'Screenshot taken: ${screenshot.length} bytes';
              }
              return 'Screenshot failed';
            },
          ),
          MethodEntry(
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
        categoryType: MethodCategoryType.cacheHistory,
        methods: [
          MethodEntry(
            description: 'Clears navigation history',
            methodEnum: PlatformInAppWebViewControllerMethod.clearHistory,
            execute: (controller, params) async {
              await controller.clearHistory();
              return 'History cleared';
            },
          ),
          MethodEntry(
            description: 'Clears form data',
            methodEnum: PlatformInAppWebViewControllerMethod.clearFormData,
            execute: (controller, params) async {
              await controller.clearFormData();
              return 'Form data cleared';
            },
          ),
          MethodEntry(
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
        categoryType: MethodCategoryType.pauseResume,
        methods: [
          MethodEntry(
            description: 'Pauses WebView',
            methodEnum: PlatformInAppWebViewControllerMethod.pause,
            execute: (controller, params) async {
              await controller.pause();
              return 'WebView paused';
            },
          ),
          MethodEntry(
            description: 'Resumes WebView',
            methodEnum: PlatformInAppWebViewControllerMethod.resume,
            execute: (controller, params) async {
              await controller.resume();
              return 'WebView resumed';
            },
          ),
          MethodEntry(
            description: 'Pauses JavaScript timers',
            methodEnum: PlatformInAppWebViewControllerMethod.pauseTimers,
            execute: (controller, params) async {
              await controller.pauseTimers();
              return 'Timers paused';
            },
          ),
          MethodEntry(
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
        categoryType: MethodCategoryType.webMessaging,
        methods: [
          MethodEntry(
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
        categoryType: MethodCategoryType.media,
        methods: [
          MethodEntry(
            description: 'Checks if in fullscreen',
            methodEnum: PlatformInAppWebViewControllerMethod.isInFullscreen,
            execute: (controller, params) async {
              return await controller.isInFullscreen();
            },
          ),
          MethodEntry(
            description: 'Pauses all media',
            methodEnum:
                PlatformInAppWebViewControllerMethod.pauseAllMediaPlayback,
            execute: (controller, params) async {
              await controller.pauseAllMediaPlayback();
              return 'Media paused';
            },
          ),
          MethodEntry(
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
            description: 'Closes media presentations',
            methodEnum:
                PlatformInAppWebViewControllerMethod.closeAllMediaPresentations,
            execute: (controller, params) async {
              await controller.closeAllMediaPresentations();
              return 'Media presentations closed';
            },
          ),
          MethodEntry(
            description: 'Gets media playback state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.requestMediaPlaybackState,
            execute: (controller, params) async {
              final state = await controller.requestMediaPlaybackState();
              return state?.toString() ?? 'Unknown state';
            },
          ),
          MethodEntry(
            description: 'Checks if playing audio',
            methodEnum: PlatformInAppWebViewControllerMethod.isPlayingAudio,
            execute: (controller, params) async {
              return await controller.isPlayingAudio();
            },
          ),
          MethodEntry(
            description: 'Checks if muted',
            methodEnum: PlatformInAppWebViewControllerMethod.isMuted,
            execute: (controller, params) async {
              return await controller.isMuted();
            },
          ),
          MethodEntry(
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
        categoryType: MethodCategoryType.cameraMic,
        methods: [
          MethodEntry(
            description: 'Gets camera capture state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.getCameraCaptureState,
            execute: (controller, params) async {
              final state = await controller.getCameraCaptureState();
              return state?.toString() ?? 'Unknown state';
            },
          ),
          MethodEntry(
            description: 'Sets camera capture state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.setCameraCaptureState,
            parameters: {
              'state': EnumParameterValueHint<MediaCaptureState>(
                MediaCaptureState.ACTIVE,
                MediaCaptureState.values.toList(),
                displayName: (e) => e.name(),
              ),
            },
            requiredParameters: ['state'],
            execute: (controller, params) async {
              final stateParam = params['state'];
              final state = stateParam is MediaCaptureState
                  ? stateParam
                  : _parseMediaCaptureState(stateParam?.toString());
              await controller.setCameraCaptureState(state: state);
              return 'Camera state set';
            },
          ),
          MethodEntry(
            description: 'Gets microphone capture state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.getMicrophoneCaptureState,
            execute: (controller, params) async {
              final state = await controller.getMicrophoneCaptureState();
              return state?.toString() ?? 'Unknown state';
            },
          ),
          MethodEntry(
            description: 'Sets microphone capture state',
            methodEnum:
                PlatformInAppWebViewControllerMethod.setMicrophoneCaptureState,
            parameters: {
              'state': EnumParameterValueHint<MediaCaptureState>(
                MediaCaptureState.ACTIVE,
                MediaCaptureState.values.toList(),
                displayName: (e) => e.name(),
              ),
            },
            requiredParameters: ['state'],
            execute: (controller, params) async {
              final stateParam = params['state'];
              final state = stateParam is MediaCaptureState
                  ? stateParam
                  : _parseMediaCaptureState(stateParam?.toString());
              await controller.setMicrophoneCaptureState(state: state);
              return 'Microphone state set';
            },
          ),
        ],
      ),

      // Security (2 methods)
      MethodCategory(
        categoryType: MethodCategoryType.security,
        methods: [
          MethodEntry(
            description: 'Checks if secure context',
            methodEnum: PlatformInAppWebViewControllerMethod.isSecureContext,
            execute: (controller, params) async {
              return await controller.isSecureContext();
            },
          ),
          MethodEntry(
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
        categoryType: MethodCategoryType.saveRestore,
        methods: [
          MethodEntry(
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
            description: 'Restores WebView state',
            methodEnum: PlatformInAppWebViewControllerMethod.restoreState,
            execute: (controller, params) async {
              // Would need saved state to restore
              return 'No state to restore';
            },
          ),
          MethodEntry(
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
        categoryType: MethodCategoryType.misc,
        methods: [
          MethodEntry(
            description: 'Gets the WebView ID',
            methodEnum: PlatformInAppWebViewControllerMethod.getViewId,
            execute: (controller, params) async {
              return controller.getViewId();
            },
          ),
          MethodEntry(
            description: 'Starts Safe Browsing',
            methodEnum: PlatformInAppWebViewControllerMethod.startSafeBrowsing,
            execute: (controller, params) async {
              return await controller.startSafeBrowsing();
            },
          ),
          MethodEntry(
            description: 'Opens DevTools',
            methodEnum: PlatformInAppWebViewControllerMethod.openDevTools,
            execute: (controller, params) async {
              await controller.openDevTools();
              return 'DevTools opened';
            },
          ),
          MethodEntry(
            description: 'Gets focused node href',
            methodEnum:
                PlatformInAppWebViewControllerMethod.requestFocusNodeHref,
            execute: (controller, params) async {
              final result = await controller.requestFocusNodeHref();
              return result?.url ?? 'No focused node';
            },
          ),
          MethodEntry(
            description: 'Gets focused image URL',
            methodEnum: PlatformInAppWebViewControllerMethod.requestImageRef,
            execute: (controller, params) async {
              final result = await controller.requestImageRef();
              return result?.url ?? 'No image focused';
            },
          ),
          MethodEntry(
            description: 'Checks interface support',
            methodEnum:
                PlatformInAppWebViewControllerMethod.isInterfaceSupported,
            parameters: {'interface': WebViewInterface.ICoreWebView2.name()},
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
            categoryType: category.categoryType,
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
          _addMethodHistoryEntry(
            entry.name,
            _formatResult(result),
            isError: false,
            value: result,
          );
          _executing[entry.name] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _addMethodHistoryEntry(entry.name, e.toString(), isError: true);
          _executing[entry.name] = false;
        });
      }
    }
  }

  void _addMethodHistoryEntry(
    String methodName,
    String message, {
    required bool isError,
    dynamic value,
  }) {
    final current = List<MethodResultEntry>.from(
      _methodHistory[methodName] ?? const [],
    );
    current.insert(
      0,
      MethodResultEntry(
        message: message,
        isError: isError,
        timestamp: DateTime.now(),
        value: value,
      ),
    );
    if (current.length > 3) {
      current.removeRange(3, current.length);
    }
    _methodHistory[methodName] = current;
    _selectedHistoryIndex[methodName] = 0;
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _getFilteredCategories();
    final totalMethods = _categories.fold<int>(
      0,
      (sum, cat) => sum + cat.methods.length,
    );

    return CustomScrollView(
      slivers: [
        // Header with search
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            minHeight: 80,
            maxHeight: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Center(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search $totalMethods methods...',
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
                    fillColor: Colors.white,
                    filled: true,
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),
          ),
        ),

        // Controller status
        if (widget.controller == null)
          SliverToBoxAdapter(
            child: Container(
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
          ),

        // Method categories
        SliverList(
          delegate: SliverChildBuilderDelegate((context, categoryIndex) {
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
          }, childCount: filteredCategories.length),
        ),
      ],
    );
  }

  Widget _buildMethodTile(MethodEntry method) {
    final isExecuting = _executing[method.name] == true;
    final historyEntries = _methodHistory[method.name] ?? const [];
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

          if (historyEntries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: MethodResultHistory(
                entries: historyEntries,
                selectedIndex: _selectedHistoryIndex[method.name],
                onSelected: (index) {
                  setState(() => _selectedHistoryIndex[method.name] = index);
                },
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

    // Try to convert to Map first
    final mapResult = _toMapIfPossible(result);
    if (mapResult != null) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(mapResult);
      } catch (e) {
        return mapResult.toString();
      }
    }

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

  /// Attempts to convert a result to a Map using common toMap/toJson patterns.
  /// Returns null if conversion is not possible.
  Map<String, dynamic>? _toMapIfPossible(dynamic result) {
    if (result == null) return null;
    if (result is Map) return Map<String, dynamic>.from(result);
    try {
      // ignore: avoid_dynamic_calls
      return (result as dynamic).toMap();
    } catch (_) {
      try {
        // ignore: avoid_dynamic_calls
        return (result as dynamic).toJson();
      } catch (_) {
        return null;
      }
    }
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _StickyHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
