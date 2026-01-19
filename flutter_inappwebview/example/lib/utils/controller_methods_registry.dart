import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';

/// Extracts the raw value from a parameter, unwrapping ParameterValueHint if necessary
T? extractParam<T>(dynamic value) {
  if (value == null) return null;
  if (value is ParameterValueHint) {
    return value.value as T?;
  }
  if (value is T) return value;
  return null;
}

/// Method entry for a single controller method
class ControllerMethodEntry {
  final String id;
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

  const ControllerMethodEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.methodEnum,
    this.parameters = const {},
    this.requiredParameters = const [],
    required this.execute,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'methodEnum': methodEnum.name,
      'parameters': _serializeParameters(parameters),
      'requiredParameters': requiredParameters,
    };
  }

  static Map<String, dynamic> _serializeParameters(
    Map<String, dynamic> params,
  ) {
    final result = <String, dynamic>{};
    params.forEach((key, value) {
      if (value is ParameterValueHint) {
        result[key] = {
          '_type': 'hint',
          'valueType': value.type.name,
          'value': value.value is Uint8List
              ? base64.encode(value.value as Uint8List)
              : value.value,
        };
      } else if (value is Uint8List) {
        result[key] = {'_type': 'bytes', 'value': base64.encode(value)};
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  /// Creates a copy with updated parameters
  ControllerMethodEntry copyWithParameters(Map<String, dynamic> newParams) {
    return ControllerMethodEntry(
      id: id,
      name: name,
      description: description,
      methodEnum: methodEnum,
      parameters: newParams,
      requiredParameters: requiredParameters,
      execute: execute,
    );
  }
}

/// A category of methods
class ControllerMethodCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<ControllerMethodEntry> methods;

  const ControllerMethodCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.methods,
  });
}

/// Registry of all InAppWebViewController methods organized by category
class ControllerMethodsRegistry {
  static ControllerMethodsRegistry? _instance;

  ControllerMethodsRegistry._();

  static ControllerMethodsRegistry get instance {
    _instance ??= ControllerMethodsRegistry._();
    return _instance!;
  }

  late final List<ControllerMethodCategory> _categories = _buildAllCategories();

  List<ControllerMethodCategory> get categories => _categories;

  /// Get all methods across all categories
  List<ControllerMethodEntry> get allMethods {
    final methods = <ControllerMethodEntry>[];
    for (final category in _categories) {
      methods.addAll(category.methods);
    }
    return methods;
  }

  /// Find a method by its ID
  ControllerMethodEntry? findMethodById(String id) {
    for (final category in _categories) {
      for (final method in category.methods) {
        if (method.id == id) return method;
      }
    }
    return null;
  }

  /// Find a method by its name
  ControllerMethodEntry? findMethodByName(String name) {
    for (final category in _categories) {
      for (final method in category.methods) {
        if (method.name == name) return method;
      }
    }
    return null;
  }

  /// Get methods filtered by search query
  List<ControllerMethodEntry> searchMethods(String query) {
    if (query.isEmpty) return allMethods;
    final lowerQuery = query.toLowerCase();
    return allMethods
        .where(
          (m) =>
              m.name.toLowerCase().contains(lowerQuery) ||
              m.description.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Get categories filtered by search query
  List<ControllerMethodCategory> searchCategories(String query) {
    if (query.isEmpty) return _categories;
    final lowerQuery = query.toLowerCase();
    return _categories
        .map((category) {
          final filteredMethods = category.methods
              .where(
                (m) =>
                    m.name.toLowerCase().contains(lowerQuery) ||
                    m.description.toLowerCase().contains(lowerQuery),
              )
              .toList();
          return ControllerMethodCategory(
            id: category.id,
            name: category.name,
            icon: category.icon,
            methods: filteredMethods,
          );
        })
        .where((category) => category.methods.isNotEmpty)
        .toList();
  }

  List<ControllerMethodCategory> _buildAllCategories() {
    return [
      _buildNavigationCategory(),
      _buildPageInfoCategory(),
      _buildJavaScriptCategory(),
      _buildJavaScriptHandlersCategory(),
      _buildUserScriptsCategory(),
      _buildScrollingCategory(),
      _buildZoomCategory(),
      _buildSettingsCategory(),
      _buildScreenshotPrintCategory(),
      _buildCacheHistoryCategory(),
      _buildPauseResumeCategory(),
      _buildWebMessagingCategory(),
      _buildMediaCategory(),
      _buildCameraMicCategory(),
      _buildSecurityCategory(),
      _buildSaveRestoreCategory(),
      _buildMiscCategory(),
    ];
  }

  // ============================================================
  // NAVIGATION & LOADING CATEGORY
  // ============================================================
  ControllerMethodCategory _buildNavigationCategory() {
    return ControllerMethodCategory(
      id: 'navigation',
      name: 'Navigation & Loading',
      icon: Icons.navigation,
      methods: [
        ControllerMethodEntry(
          id: 'loadUrl',
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
            final body = extractParam<Uint8List>(params['body']);

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
        ControllerMethodEntry(
          id: 'postUrl',
          name: 'postUrl',
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
            Uint8List? postData = extractParam<Uint8List>(params['postData']);
            // Also handle string input by converting to bytes
            if (postData == null) {
              final postDataParam = params['postData'];
              if (postDataParam is String && postDataParam.isNotEmpty) {
                postData = Uint8List.fromList(postDataParam.codeUnits);
              }
            }
            await controller.postUrl(
              url: WebUri(url),
              postData: postData ?? Uint8List(0),
            );
            return 'POST request sent with ${postData?.length ?? 0} bytes';
          },
        ),
        ControllerMethodEntry(
          id: 'loadData',
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
              mimeType: mimeType?.isNotEmpty == true ? mimeType! : 'text/html',
              encoding: encoding?.isNotEmpty == true ? encoding! : 'utf-8',
              baseUrl: baseUrl?.isNotEmpty == true ? WebUri(baseUrl!) : null,
              historyUrl: historyUrl?.isNotEmpty == true
                  ? WebUri(historyUrl!)
                  : null,
            );
            return 'HTML data loaded';
          },
        ),
        ControllerMethodEntry(
          id: 'loadFile',
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
        ControllerMethodEntry(
          id: 'reload',
          name: 'reload',
          description: 'Reloads the current page',
          methodEnum: PlatformInAppWebViewControllerMethod.reload,
          execute: (controller, params) async {
            await controller.reload();
            return 'Page reloaded';
          },
        ),
        ControllerMethodEntry(
          id: 'reloadFromOrigin',
          name: 'reloadFromOrigin',
          description: 'Reloads bypassing cache',
          methodEnum: PlatformInAppWebViewControllerMethod.reloadFromOrigin,
          execute: (controller, params) async {
            await controller.reloadFromOrigin();
            return 'Page reloaded from origin';
          },
        ),
        ControllerMethodEntry(
          id: 'goBack',
          name: 'goBack',
          description: 'Navigates back in history',
          methodEnum: PlatformInAppWebViewControllerMethod.goBack,
          execute: (controller, params) async {
            await controller.goBack();
            return 'Navigated back';
          },
        ),
        ControllerMethodEntry(
          id: 'goForward',
          name: 'goForward',
          description: 'Navigates forward in history',
          methodEnum: PlatformInAppWebViewControllerMethod.goForward,
          execute: (controller, params) async {
            await controller.goForward();
            return 'Navigated forward';
          },
        ),
        ControllerMethodEntry(
          id: 'goBackOrForward',
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
        ControllerMethodEntry(
          id: 'canGoBack',
          name: 'canGoBack',
          description: 'Checks if can go back',
          methodEnum: PlatformInAppWebViewControllerMethod.canGoBack,
          execute: (controller, params) async {
            return await controller.canGoBack();
          },
        ),
        ControllerMethodEntry(
          id: 'canGoForward',
          name: 'canGoForward',
          description: 'Checks if can go forward',
          methodEnum: PlatformInAppWebViewControllerMethod.canGoForward,
          execute: (controller, params) async {
            return await controller.canGoForward();
          },
        ),
        ControllerMethodEntry(
          id: 'canGoBackOrForward',
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
        ControllerMethodEntry(
          id: 'isLoading',
          name: 'isLoading',
          description: 'Checks if page is loading',
          methodEnum: PlatformInAppWebViewControllerMethod.isLoading,
          execute: (controller, params) async {
            return await controller.isLoading();
          },
        ),
        ControllerMethodEntry(
          id: 'stopLoading',
          name: 'stopLoading',
          description: 'Stops page loading',
          methodEnum: PlatformInAppWebViewControllerMethod.stopLoading,
          execute: (controller, params) async {
            await controller.stopLoading();
            return 'Loading stopped';
          },
        ),
      ],
    );
  }

  // ============================================================
  // PAGE INFO CATEGORY
  // ============================================================
  ControllerMethodCategory _buildPageInfoCategory() {
    return ControllerMethodCategory(
      id: 'pageInfo',
      name: 'Page Info & Content',
      icon: Icons.info_outline,
      methods: [
        ControllerMethodEntry(
          id: 'getUrl',
          name: 'getUrl',
          description: 'Gets current page URL',
          methodEnum: PlatformInAppWebViewControllerMethod.getUrl,
          execute: (controller, params) async {
            return (await controller.getUrl())?.toString() ?? 'No URL';
          },
        ),
        ControllerMethodEntry(
          id: 'getTitle',
          name: 'getTitle',
          description: 'Gets current page title',
          methodEnum: PlatformInAppWebViewControllerMethod.getTitle,
          execute: (controller, params) async {
            return await controller.getTitle() ?? 'No title';
          },
        ),
        ControllerMethodEntry(
          id: 'getProgress',
          name: 'getProgress',
          description: 'Gets page load progress',
          methodEnum: PlatformInAppWebViewControllerMethod.getProgress,
          execute: (controller, params) async {
            return await controller.getProgress();
          },
        ),
        ControllerMethodEntry(
          id: 'getHtml',
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
        ControllerMethodEntry(
          id: 'getFavicons',
          name: 'getFavicons',
          description: 'Gets page favicons',
          methodEnum: PlatformInAppWebViewControllerMethod.getFavicons,
          execute: (controller, params) async {
            final favicons = await controller.getFavicons();
            return 'Found ${favicons.length} favicons';
          },
        ),
        ControllerMethodEntry(
          id: 'getOriginalUrl',
          name: 'getOriginalUrl',
          description: 'Gets original URL before redirects',
          methodEnum: PlatformInAppWebViewControllerMethod.getOriginalUrl,
          execute: (controller, params) async {
            return (await controller.getOriginalUrl())?.toString() ?? 'No URL';
          },
        ),
        ControllerMethodEntry(
          id: 'getSelectedText',
          name: 'getSelectedText',
          description: 'Gets selected text',
          methodEnum: PlatformInAppWebViewControllerMethod.getSelectedText,
          execute: (controller, params) async {
            return await controller.getSelectedText() ?? 'No selection';
          },
        ),
        ControllerMethodEntry(
          id: 'getHitTestResult',
          name: 'getHitTestResult',
          description: 'Gets hit test result',
          methodEnum: PlatformInAppWebViewControllerMethod.getHitTestResult,
          execute: (controller, params) async {
            final result = await controller.getHitTestResult();
            return result?.type.toString() ?? 'No hit test result';
          },
        ),
        ControllerMethodEntry(
          id: 'getMetaTags',
          name: 'getMetaTags',
          description: 'Gets meta tags from page',
          methodEnum: PlatformInAppWebViewControllerMethod.getMetaTags,
          execute: (controller, params) async {
            final tags = await controller.getMetaTags();
            return 'Found ${tags.length} meta tags';
          },
        ),
        ControllerMethodEntry(
          id: 'getMetaThemeColor',
          name: 'getMetaThemeColor',
          description: 'Gets meta theme color',
          methodEnum: PlatformInAppWebViewControllerMethod.getMetaThemeColor,
          execute: (controller, params) async {
            final color = await controller.getMetaThemeColor();
            return color?.toString() ?? 'No theme color';
          },
        ),
        ControllerMethodEntry(
          id: 'getCertificate',
          name: 'getCertificate',
          description: 'Gets SSL certificate info and X509 data',
          methodEnum: PlatformInAppWebViewControllerMethod.getCertificate,
          execute: (controller, params) async {
            final cert = await controller.getCertificate();
            if (cert == null) return {'error': 'No certificate available'};
            return cert.toMap();
          },
        ),
        ControllerMethodEntry(
          id: 'getCopyBackForwardList',
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
    );
  }

  // ============================================================
  // JAVASCRIPT CATEGORY
  // ============================================================
  ControllerMethodCategory _buildJavaScriptCategory() {
    return ControllerMethodCategory(
      id: 'javascript',
      name: 'JavaScript Execution',
      icon: Icons.code,
      methods: [
        ControllerMethodEntry(
          id: 'evaluateJavascript',
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
        ControllerMethodEntry(
          id: 'callAsyncJavaScript',
          name: 'callAsyncJavaScript',
          description: 'Calls async JavaScript function',
          methodEnum: PlatformInAppWebViewControllerMethod.callAsyncJavaScript,
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
        ControllerMethodEntry(
          id: 'injectJavascriptFileFromUrl',
          name: 'injectJavascriptFileFromUrl',
          description: 'Injects JS file from URL',
          methodEnum:
              PlatformInAppWebViewControllerMethod.injectJavascriptFileFromUrl,
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
        ControllerMethodEntry(
          id: 'injectCSSCode',
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
        ControllerMethodEntry(
          id: 'injectCSSFileFromUrl',
          name: 'injectCSSFileFromUrl',
          description: 'Injects CSS file from URL',
          methodEnum: PlatformInAppWebViewControllerMethod.injectCSSFileFromUrl,
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
      ],
    );
  }

  // ============================================================
  // JAVASCRIPT HANDLERS CATEGORY
  // ============================================================
  ControllerMethodCategory _buildJavaScriptHandlersCategory() {
    return ControllerMethodCategory(
      id: 'jsHandlers',
      name: 'JavaScript Handlers',
      icon: Icons.link,
      methods: [
        ControllerMethodEntry(
          id: 'addJavaScriptHandler',
          name: 'addJavaScriptHandler',
          description: 'Adds a JavaScript handler',
          methodEnum: PlatformInAppWebViewControllerMethod.addJavaScriptHandler,
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
        ControllerMethodEntry(
          id: 'removeJavaScriptHandler',
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
        ControllerMethodEntry(
          id: 'hasJavaScriptHandler',
          name: 'hasJavaScriptHandler',
          description: 'Checks if handler exists',
          methodEnum: PlatformInAppWebViewControllerMethod.hasJavaScriptHandler,
          parameters: {'handlerName': 'testHandler'},
          requiredParameters: ['handlerName'],
          execute: (controller, params) async {
            return controller.hasJavaScriptHandler(
              handlerName: params['handlerName']?.toString() ?? '',
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // USER SCRIPTS CATEGORY
  // ============================================================
  ControllerMethodCategory _buildUserScriptsCategory() {
    return ControllerMethodCategory(
      id: 'userScripts',
      name: 'User Scripts',
      icon: Icons.description,
      methods: [
        ControllerMethodEntry(
          id: 'addUserScript',
          name: 'addUserScript',
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
            final injectionTime = injectionTimeParam is UserScriptInjectionTime
                ? injectionTimeParam
                : _parseUserScriptInjectionTime(injectionTimeParam?.toString());
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
        ControllerMethodEntry(
          id: 'removeAllUserScripts',
          name: 'removeAllUserScripts',
          description: 'Removes all user scripts',
          methodEnum: PlatformInAppWebViewControllerMethod.removeAllUserScripts,
          execute: (controller, params) async {
            await controller.removeAllUserScripts();
            return 'All user scripts removed';
          },
        ),
      ],
    );
  }

  // ============================================================
  // SCROLLING CATEGORY
  // ============================================================
  ControllerMethodCategory _buildScrollingCategory() {
    return ControllerMethodCategory(
      id: 'scrolling',
      name: 'Scrolling & Layout',
      icon: Icons.swap_vert,
      methods: [
        ControllerMethodEntry(
          id: 'scrollTo',
          name: 'scrollTo',
          description: 'Scrolls to position',
          methodEnum: PlatformInAppWebViewControllerMethod.scrollTo,
          parameters: {'x': 0, 'y': 100, 'animated': true},
          execute: (controller, params) async {
            final x = (params['x'] as num?)?.toInt() ?? 0;
            final y = (params['y'] as num?)?.toInt() ?? 0;
            final animated = params['animated'] as bool? ?? true;
            await controller.scrollTo(x: x, y: y, animated: animated);
            return 'Scrolled to ($x, $y)';
          },
        ),
        ControllerMethodEntry(
          id: 'scrollBy',
          name: 'scrollBy',
          description: 'Scrolls by offset',
          methodEnum: PlatformInAppWebViewControllerMethod.scrollBy,
          parameters: {'x': 0, 'y': 50, 'animated': true},
          execute: (controller, params) async {
            final x = (params['x'] as num?)?.toInt() ?? 0;
            final y = (params['y'] as num?)?.toInt() ?? 0;
            final animated = params['animated'] as bool? ?? true;
            await controller.scrollBy(x: x, y: y, animated: animated);
            return 'Scrolled by ($x, $y)';
          },
        ),
        ControllerMethodEntry(
          id: 'getScrollX',
          name: 'getScrollX',
          description: 'Gets horizontal scroll position',
          methodEnum: PlatformInAppWebViewControllerMethod.getScrollX,
          execute: (controller, params) async {
            return await controller.getScrollX();
          },
        ),
        ControllerMethodEntry(
          id: 'getScrollY',
          name: 'getScrollY',
          description: 'Gets vertical scroll position',
          methodEnum: PlatformInAppWebViewControllerMethod.getScrollY,
          execute: (controller, params) async {
            return await controller.getScrollY();
          },
        ),
        ControllerMethodEntry(
          id: 'getContentHeight',
          name: 'getContentHeight',
          description: 'Gets content height',
          methodEnum: PlatformInAppWebViewControllerMethod.getContentHeight,
          execute: (controller, params) async {
            return await controller.getContentHeight();
          },
        ),
        ControllerMethodEntry(
          id: 'getContentWidth',
          name: 'getContentWidth',
          description: 'Gets content width',
          methodEnum: PlatformInAppWebViewControllerMethod.getContentWidth,
          execute: (controller, params) async {
            return await controller.getContentWidth();
          },
        ),
      ],
    );
  }

  // ============================================================
  // ZOOM CATEGORY
  // ============================================================
  ControllerMethodCategory _buildZoomCategory() {
    return ControllerMethodCategory(
      id: 'zoom',
      name: 'Zoom',
      icon: Icons.zoom_in,
      methods: [
        ControllerMethodEntry(
          id: 'zoomBy',
          name: 'zoomBy',
          description: 'Zooms by factor',
          methodEnum: PlatformInAppWebViewControllerMethod.zoomBy,
          parameters: {'zoomFactor': 1.5, 'animated': true},
          requiredParameters: ['zoomFactor'],
          execute: (controller, params) async {
            final zoomFactor =
                (params['zoomFactor'] as num?)?.toDouble() ?? 1.0;
            final animated = params['animated'] as bool? ?? true;
            await controller.zoomBy(zoomFactor: zoomFactor, animated: animated);
            return 'Zoomed to ${zoomFactor}x';
          },
        ),
        ControllerMethodEntry(
          id: 'zoomIn',
          name: 'zoomIn',
          description: 'Zooms in',
          methodEnum: PlatformInAppWebViewControllerMethod.zoomIn,
          execute: (controller, params) async {
            return await controller.zoomIn();
          },
        ),
        ControllerMethodEntry(
          id: 'zoomOut',
          name: 'zoomOut',
          description: 'Zooms out',
          methodEnum: PlatformInAppWebViewControllerMethod.zoomOut,
          execute: (controller, params) async {
            return await controller.zoomOut();
          },
        ),
        ControllerMethodEntry(
          id: 'getZoomScale',
          name: 'getZoomScale',
          description: 'Gets current zoom scale',
          methodEnum: PlatformInAppWebViewControllerMethod.getZoomScale,
          execute: (controller, params) async {
            return await controller.getZoomScale();
          },
        ),
      ],
    );
  }

  // ============================================================
  // SETTINGS CATEGORY
  // ============================================================
  ControllerMethodCategory _buildSettingsCategory() {
    return ControllerMethodCategory(
      id: 'settings',
      name: 'Settings & State',
      icon: Icons.settings,
      methods: [
        ControllerMethodEntry(
          id: 'getSettings',
          name: 'getSettings',
          description: 'Gets WebView settings',
          methodEnum: PlatformInAppWebViewControllerMethod.getSettings,
          execute: (controller, params) async {
            final settings = await controller.getSettings();
            return 'JS enabled: ${settings?.javaScriptEnabled}';
          },
        ),
        ControllerMethodEntry(
          id: 'requestFocus',
          name: 'requestFocus',
          description: 'Requests focus for WebView',
          methodEnum: PlatformInAppWebViewControllerMethod.requestFocus,
          execute: (controller, params) async {
            return await controller.requestFocus();
          },
        ),
        ControllerMethodEntry(
          id: 'clearFocus',
          name: 'clearFocus',
          description: 'Clears focus from WebView',
          methodEnum: PlatformInAppWebViewControllerMethod.clearFocus,
          execute: (controller, params) async {
            await controller.clearFocus();
            return 'Focus cleared';
          },
        ),
      ],
    );
  }

  // ============================================================
  // SCREENSHOT & PRINT CATEGORY
  // ============================================================
  ControllerMethodCategory _buildScreenshotPrintCategory() {
    return ControllerMethodCategory(
      id: 'screenshotPrint',
      name: 'Screenshot & Print',
      icon: Icons.camera_alt,
      methods: [
        ControllerMethodEntry(
          id: 'takeScreenshot',
          name: 'takeScreenshot',
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
            final snapshotWidth = extractParam<num>(
              params['snapshotWidth'],
            )?.toDouble();

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
        ControllerMethodEntry(
          id: 'printCurrentPage',
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
        ControllerMethodEntry(
          id: 'createPdf',
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
    );
  }

  // ============================================================
  // CACHE & HISTORY CATEGORY
  // ============================================================
  ControllerMethodCategory _buildCacheHistoryCategory() {
    return ControllerMethodCategory(
      id: 'cacheHistory',
      name: 'Cache & History',
      icon: Icons.history,
      methods: [
        ControllerMethodEntry(
          id: 'clearHistory',
          name: 'clearHistory',
          description: 'Clears navigation history',
          methodEnum: PlatformInAppWebViewControllerMethod.clearHistory,
          execute: (controller, params) async {
            await controller.clearHistory();
            return 'History cleared';
          },
        ),
        ControllerMethodEntry(
          id: 'clearFormData',
          name: 'clearFormData',
          description: 'Clears form data',
          methodEnum: PlatformInAppWebViewControllerMethod.clearFormData,
          execute: (controller, params) async {
            await controller.clearFormData();
            return 'Form data cleared';
          },
        ),
        ControllerMethodEntry(
          id: 'clearSslPreferences',
          name: 'clearSslPreferences',
          description: 'Clears SSL preferences',
          methodEnum: PlatformInAppWebViewControllerMethod.clearSslPreferences,
          execute: (controller, params) async {
            await controller.clearSslPreferences();
            return 'SSL preferences cleared';
          },
        ),
      ],
    );
  }

  // ============================================================
  // PAUSE & RESUME CATEGORY
  // ============================================================
  ControllerMethodCategory _buildPauseResumeCategory() {
    return ControllerMethodCategory(
      id: 'pauseResume',
      name: 'Pause & Resume',
      icon: Icons.pause_circle_outline,
      methods: [
        ControllerMethodEntry(
          id: 'pause',
          name: 'pause',
          description: 'Pauses WebView',
          methodEnum: PlatformInAppWebViewControllerMethod.pause,
          execute: (controller, params) async {
            await controller.pause();
            return 'WebView paused';
          },
        ),
        ControllerMethodEntry(
          id: 'resume',
          name: 'resume',
          description: 'Resumes WebView',
          methodEnum: PlatformInAppWebViewControllerMethod.resume,
          execute: (controller, params) async {
            await controller.resume();
            return 'WebView resumed';
          },
        ),
        ControllerMethodEntry(
          id: 'pauseTimers',
          name: 'pauseTimers',
          description: 'Pauses JavaScript timers',
          methodEnum: PlatformInAppWebViewControllerMethod.pauseTimers,
          execute: (controller, params) async {
            await controller.pauseTimers();
            return 'Timers paused';
          },
        ),
        ControllerMethodEntry(
          id: 'resumeTimers',
          name: 'resumeTimers',
          description: 'Resumes JavaScript timers',
          methodEnum: PlatformInAppWebViewControllerMethod.resumeTimers,
          execute: (controller, params) async {
            await controller.resumeTimers();
            return 'Timers resumed';
          },
        ),
      ],
    );
  }

  // ============================================================
  // WEB MESSAGING CATEGORY
  // ============================================================
  ControllerMethodCategory _buildWebMessagingCategory() {
    return ControllerMethodCategory(
      id: 'webMessaging',
      name: 'Web Messaging',
      icon: Icons.message,
      methods: [
        ControllerMethodEntry(
          id: 'createWebMessageChannel',
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
        ControllerMethodEntry(
          id: 'postWebMessage',
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
      ],
    );
  }

  // ============================================================
  // MEDIA CATEGORY
  // ============================================================
  ControllerMethodCategory _buildMediaCategory() {
    return ControllerMethodCategory(
      id: 'media',
      name: 'Media & Fullscreen',
      icon: Icons.play_circle_outline,
      methods: [
        ControllerMethodEntry(
          id: 'isInFullscreen',
          name: 'isInFullscreen',
          description: 'Checks if in fullscreen',
          methodEnum: PlatformInAppWebViewControllerMethod.isInFullscreen,
          execute: (controller, params) async {
            return await controller.isInFullscreen();
          },
        ),
        ControllerMethodEntry(
          id: 'pauseAllMediaPlayback',
          name: 'pauseAllMediaPlayback',
          description: 'Pauses all media',
          methodEnum:
              PlatformInAppWebViewControllerMethod.pauseAllMediaPlayback,
          execute: (controller, params) async {
            await controller.pauseAllMediaPlayback();
            return 'Media paused';
          },
        ),
        ControllerMethodEntry(
          id: 'isPlayingAudio',
          name: 'isPlayingAudio',
          description: 'Checks if playing audio',
          methodEnum: PlatformInAppWebViewControllerMethod.isPlayingAudio,
          execute: (controller, params) async {
            return await controller.isPlayingAudio();
          },
        ),
        ControllerMethodEntry(
          id: 'isMuted',
          name: 'isMuted',
          description: 'Checks if muted',
          methodEnum: PlatformInAppWebViewControllerMethod.isMuted,
          execute: (controller, params) async {
            return await controller.isMuted();
          },
        ),
        ControllerMethodEntry(
          id: 'setMuted',
          name: 'setMuted',
          description: 'Sets mute state',
          methodEnum: PlatformInAppWebViewControllerMethod.setMuted,
          parameters: {'muted': true},
          execute: (controller, params) async {
            await controller.setMuted(muted: params['muted'] as bool? ?? true);
            return 'Muted';
          },
        ),
      ],
    );
  }

  // ============================================================
  // CAMERA & MICROPHONE CATEGORY
  // ============================================================
  ControllerMethodCategory _buildCameraMicCategory() {
    return ControllerMethodCategory(
      id: 'cameraMic',
      name: 'Camera & Microphone',
      icon: Icons.videocam,
      methods: [
        ControllerMethodEntry(
          id: 'getCameraCaptureState',
          name: 'getCameraCaptureState',
          description: 'Gets camera capture state',
          methodEnum:
              PlatformInAppWebViewControllerMethod.getCameraCaptureState,
          execute: (controller, params) async {
            final state = await controller.getCameraCaptureState();
            return state?.toString() ?? 'Unknown state';
          },
        ),
        ControllerMethodEntry(
          id: 'getMicrophoneCaptureState',
          name: 'getMicrophoneCaptureState',
          description: 'Gets microphone capture state',
          methodEnum:
              PlatformInAppWebViewControllerMethod.getMicrophoneCaptureState,
          execute: (controller, params) async {
            final state = await controller.getMicrophoneCaptureState();
            return state?.toString() ?? 'Unknown state';
          },
        ),
      ],
    );
  }

  // ============================================================
  // SECURITY CATEGORY
  // ============================================================
  ControllerMethodCategory _buildSecurityCategory() {
    return ControllerMethodCategory(
      id: 'security',
      name: 'Security',
      icon: Icons.security,
      methods: [
        ControllerMethodEntry(
          id: 'isSecureContext',
          name: 'isSecureContext',
          description: 'Checks if secure context',
          methodEnum: PlatformInAppWebViewControllerMethod.isSecureContext,
          execute: (controller, params) async {
            return await controller.isSecureContext();
          },
        ),
        ControllerMethodEntry(
          id: 'hasOnlySecureContent',
          name: 'hasOnlySecureContent',
          description: 'Checks if only secure content',
          methodEnum: PlatformInAppWebViewControllerMethod.hasOnlySecureContent,
          execute: (controller, params) async {
            return await controller.hasOnlySecureContent();
          },
        ),
      ],
    );
  }

  // ============================================================
  // SAVE & RESTORE CATEGORY
  // ============================================================
  ControllerMethodCategory _buildSaveRestoreCategory() {
    return ControllerMethodCategory(
      id: 'saveRestore',
      name: 'Save & Restore',
      icon: Icons.save,
      methods: [
        ControllerMethodEntry(
          id: 'saveState',
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
        ControllerMethodEntry(
          id: 'createWebArchiveData',
          name: 'createWebArchiveData',
          description: 'Creates web archive data',
          methodEnum: PlatformInAppWebViewControllerMethod.createWebArchiveData,
          execute: (controller, params) async {
            final data = await controller.createWebArchiveData();
            return data != null ? 'Archive: ${data.length} bytes' : 'Failed';
          },
        ),
      ],
    );
  }

  // ============================================================
  // MISC CATEGORY
  // ============================================================
  ControllerMethodCategory _buildMiscCategory() {
    return ControllerMethodCategory(
      id: 'misc',
      name: 'Misc/Advanced',
      icon: Icons.more_horiz,
      methods: [
        ControllerMethodEntry(
          id: 'getViewId',
          name: 'getViewId',
          description: 'Gets the WebView ID',
          methodEnum: PlatformInAppWebViewControllerMethod.getViewId,
          execute: (controller, params) async {
            return controller.getViewId();
          },
        ),
        ControllerMethodEntry(
          id: 'startSafeBrowsing',
          name: 'startSafeBrowsing',
          description: 'Starts Safe Browsing',
          methodEnum: PlatformInAppWebViewControllerMethod.startSafeBrowsing,
          execute: (controller, params) async {
            return await controller.startSafeBrowsing();
          },
        ),
        ControllerMethodEntry(
          id: 'openDevTools',
          name: 'openDevTools',
          description: 'Opens DevTools',
          methodEnum: PlatformInAppWebViewControllerMethod.openDevTools,
          execute: (controller, params) async {
            await controller.openDevTools();
            return 'DevTools opened';
          },
        ),
      ],
    );
  }

  static UserScriptInjectionTime _parseUserScriptInjectionTime(String? value) {
    if (value == null || value.isEmpty) {
      return UserScriptInjectionTime.AT_DOCUMENT_END;
    }
    return UserScriptInjectionTime.values.firstWhere(
      (entry) => entry.name().toLowerCase() == value.toLowerCase(),
      orElse: () => UserScriptInjectionTime.AT_DOCUMENT_END,
    );
  }
}
