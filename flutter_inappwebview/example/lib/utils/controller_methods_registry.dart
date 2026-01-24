import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/widgets/common/parameter_dialog.dart';

List<T> _safeEnumValues<T>(Iterable<T> Function() getter) {
  try {
    return getter().toList();
  } catch (_) {
    return <T>[];
  }
}

/// Extracts the raw value from a parameter, unwrapping ParameterValueHint if necessary
T? extractParam<T>(dynamic value) {
  if (value == null) return null;
  if (value is ParameterValueHint) {
    return value.value as T?;
  }
  if (value is T) return value;
  return null;
}

/// Enum representing the categories of controller methods
enum ControllerMethodCategoryType {
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

  const ControllerMethodCategoryType(this.displayName, this.icon);
}

/// Method entry for a single controller method
class ControllerMethodEntry {
  /// The method enum that this entry represents.
  /// The id and name are derived from methodEnum.name.
  final PlatformInAppWebViewControllerMethod methodEnum;
  final String description;
  final Map<String, dynamic> parameters;
  final List<String> requiredParameters;
  final Future<dynamic> Function(
    InAppWebViewController controller,
    Map<String, dynamic> params,
  )
  execute;

  const ControllerMethodEntry({
    required this.methodEnum,
    required this.description,
    this.parameters = const {},
    this.requiredParameters = const [],
    required this.execute,
  });

  /// The unique identifier derived from methodEnum.name
  String get id => methodEnum.name;

  /// The display name derived from methodEnum.name
  String get name => methodEnum.name;

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
      methodEnum: methodEnum,
      description: description,
      parameters: newParams,
      requiredParameters: requiredParameters,
      execute: execute,
    );
  }
}

/// A category of methods
class ControllerMethodCategory {
  /// The category type enum - id, name and icon are derived from this
  final ControllerMethodCategoryType categoryType;
  final List<ControllerMethodEntry> methods;

  const ControllerMethodCategory({
    required this.categoryType,
    required this.methods,
  });

  /// The unique identifier derived from categoryType.name
  String get id => categoryType.name;

  /// The display name derived from categoryType.displayName
  String get name => categoryType.displayName;

  /// The icon derived from categoryType.icon
  IconData get icon => categoryType.icon;
}

/// Registry of all controller methods organized by category
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
            categoryType: category.categoryType,
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
      categoryType: ControllerMethodCategoryType.navigation,
      methods: [
        ControllerMethodEntry(
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
          description: 'Reloads the current page',
          methodEnum: PlatformInAppWebViewControllerMethod.reload,
          execute: (controller, params) async {
            await controller.reload();
            return 'Page reloaded';
          },
        ),
        ControllerMethodEntry(
          description: 'Reloads bypassing cache',
          methodEnum: PlatformInAppWebViewControllerMethod.reloadFromOrigin,
          execute: (controller, params) async {
            await controller.reloadFromOrigin();
            return 'Page reloaded from origin';
          },
        ),
        ControllerMethodEntry(
          description: 'Navigates back in history',
          methodEnum: PlatformInAppWebViewControllerMethod.goBack,
          execute: (controller, params) async {
            await controller.goBack();
            return 'Navigated back';
          },
        ),
        ControllerMethodEntry(
          description: 'Navigates forward in history',
          methodEnum: PlatformInAppWebViewControllerMethod.goForward,
          execute: (controller, params) async {
            await controller.goForward();
            return 'Navigated forward';
          },
        ),
        ControllerMethodEntry(
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
          description: 'Checks if can go back',
          methodEnum: PlatformInAppWebViewControllerMethod.canGoBack,
          execute: (controller, params) async {
            return await controller.canGoBack();
          },
        ),
        ControllerMethodEntry(
          description: 'Checks if can go forward',
          methodEnum: PlatformInAppWebViewControllerMethod.canGoForward,
          execute: (controller, params) async {
            return await controller.canGoForward();
          },
        ),
        ControllerMethodEntry(
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
          description: 'Checks if page is loading',
          methodEnum: PlatformInAppWebViewControllerMethod.isLoading,
          execute: (controller, params) async {
            return await controller.isLoading();
          },
        ),
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.pageInfo,
      methods: [
        ControllerMethodEntry(
          description: 'Gets current page URL',
          methodEnum: PlatformInAppWebViewControllerMethod.getUrl,
          execute: (controller, params) async {
            return (await controller.getUrl())?.toString() ?? 'No URL';
          },
        ),
        ControllerMethodEntry(
          description: 'Gets current page title',
          methodEnum: PlatformInAppWebViewControllerMethod.getTitle,
          execute: (controller, params) async {
            return await controller.getTitle() ?? 'No title';
          },
        ),
        ControllerMethodEntry(
          description: 'Gets page load progress',
          methodEnum: PlatformInAppWebViewControllerMethod.getProgress,
          execute: (controller, params) async {
            return await controller.getProgress();
          },
        ),
        ControllerMethodEntry(
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
          description: 'Gets page favicons',
          methodEnum: PlatformInAppWebViewControllerMethod.getFavicons,
          execute: (controller, params) async {
            final favicons = await controller.getFavicons();
            return 'Found ${favicons.length} favicons';
          },
        ),
        ControllerMethodEntry(
          description: 'Gets original URL before redirects',
          methodEnum: PlatformInAppWebViewControllerMethod.getOriginalUrl,
          execute: (controller, params) async {
            return (await controller.getOriginalUrl())?.toString() ?? 'No URL';
          },
        ),
        ControllerMethodEntry(
          description: 'Gets selected text',
          methodEnum: PlatformInAppWebViewControllerMethod.getSelectedText,
          execute: (controller, params) async {
            return await controller.getSelectedText() ?? 'No selection';
          },
        ),
        ControllerMethodEntry(
          description: 'Gets hit test result',
          methodEnum: PlatformInAppWebViewControllerMethod.getHitTestResult,
          execute: (controller, params) async {
            final result = await controller.getHitTestResult();
            return result?.type.toString() ?? 'No hit test result';
          },
        ),
        ControllerMethodEntry(
          description: 'Gets meta tags from page',
          methodEnum: PlatformInAppWebViewControllerMethod.getMetaTags,
          execute: (controller, params) async {
            final tags = await controller.getMetaTags();
            return 'Found ${tags.length} meta tags';
          },
        ),
        ControllerMethodEntry(
          description: 'Gets meta theme color',
          methodEnum: PlatformInAppWebViewControllerMethod.getMetaThemeColor,
          execute: (controller, params) async {
            final color = await controller.getMetaThemeColor();
            return color?.toString() ?? 'No theme color';
          },
        ),
        ControllerMethodEntry(
          description: 'Gets SSL certificate info and X509 data',
          methodEnum: PlatformInAppWebViewControllerMethod.getCertificate,
          execute: (controller, params) async {
            final cert = await controller.getCertificate();
            if (cert == null) return {'error': 'No certificate available'};
            return cert.toMap();
          },
        ),
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.javascript,
      methods: [
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.jsHandlers,
      methods: [
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.userScripts,
      methods: [
        ControllerMethodEntry(
          description: 'Adds a user script',
          methodEnum: PlatformInAppWebViewControllerMethod.addUserScript,
          parameters: {
            'source': 'console.log("User script executed");',
            'injectionTime':
                EnumParameterValueHint<UserScriptInjectionTime>.fromIterable(
                  UserScriptInjectionTime.AT_DOCUMENT_END,
                  _safeEnumValues(() => UserScriptInjectionTime.values),
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
      categoryType: ControllerMethodCategoryType.scrolling,
      methods: [
        ControllerMethodEntry(
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
          description: 'Gets horizontal scroll position',
          methodEnum: PlatformInAppWebViewControllerMethod.getScrollX,
          execute: (controller, params) async {
            return await controller.getScrollX();
          },
        ),
        ControllerMethodEntry(
          description: 'Gets vertical scroll position',
          methodEnum: PlatformInAppWebViewControllerMethod.getScrollY,
          execute: (controller, params) async {
            return await controller.getScrollY();
          },
        ),
        ControllerMethodEntry(
          description: 'Gets content height',
          methodEnum: PlatformInAppWebViewControllerMethod.getContentHeight,
          execute: (controller, params) async {
            return await controller.getContentHeight();
          },
        ),
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.zoom,
      methods: [
        ControllerMethodEntry(
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
          description: 'Zooms in',
          methodEnum: PlatformInAppWebViewControllerMethod.zoomIn,
          execute: (controller, params) async {
            return await controller.zoomIn();
          },
        ),
        ControllerMethodEntry(
          description: 'Zooms out',
          methodEnum: PlatformInAppWebViewControllerMethod.zoomOut,
          execute: (controller, params) async {
            return await controller.zoomOut();
          },
        ),
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.settings,
      methods: [
        ControllerMethodEntry(
          description: 'Gets WebView settings',
          methodEnum: PlatformInAppWebViewControllerMethod.getSettings,
          execute: (controller, params) async {
            final settings = await controller.getSettings();
            return 'JS enabled: ${settings?.javaScriptEnabled}';
          },
        ),
        ControllerMethodEntry(
          description: 'Requests focus for WebView',
          methodEnum: PlatformInAppWebViewControllerMethod.requestFocus,
          execute: (controller, params) async {
            return await controller.requestFocus();
          },
        ),
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.screenshotPrint,
      methods: [
        ControllerMethodEntry(
          description: 'Takes a screenshot',
          methodEnum: PlatformInAppWebViewControllerMethod.takeScreenshot,
          parameters: {
            'compressFormat':
                EnumParameterValueHint<CompressFormat>.fromIterable(
                  CompressFormat.PNG,
                  _safeEnumValues(() => CompressFormat.values),
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
      categoryType: ControllerMethodCategoryType.cacheHistory,
      methods: [
        ControllerMethodEntry(
          description: 'Clears navigation history',
          methodEnum: PlatformInAppWebViewControllerMethod.clearHistory,
          execute: (controller, params) async {
            await controller.clearHistory();
            return 'History cleared';
          },
        ),
        ControllerMethodEntry(
          description: 'Clears form data',
          methodEnum: PlatformInAppWebViewControllerMethod.clearFormData,
          execute: (controller, params) async {
            await controller.clearFormData();
            return 'Form data cleared';
          },
        ),
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.pauseResume,
      methods: [
        ControllerMethodEntry(
          description: 'Pauses WebView',
          methodEnum: PlatformInAppWebViewControllerMethod.pause,
          execute: (controller, params) async {
            await controller.pause();
            return 'WebView paused';
          },
        ),
        ControllerMethodEntry(
          description: 'Resumes WebView',
          methodEnum: PlatformInAppWebViewControllerMethod.resume,
          execute: (controller, params) async {
            await controller.resume();
            return 'WebView resumed';
          },
        ),
        ControllerMethodEntry(
          description: 'Pauses JavaScript timers',
          methodEnum: PlatformInAppWebViewControllerMethod.pauseTimers,
          execute: (controller, params) async {
            await controller.pauseTimers();
            return 'Timers paused';
          },
        ),
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.webMessaging,
      methods: [
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.media,
      methods: [
        ControllerMethodEntry(
          description: 'Checks if in fullscreen',
          methodEnum: PlatformInAppWebViewControllerMethod.isInFullscreen,
          execute: (controller, params) async {
            return await controller.isInFullscreen();
          },
        ),
        ControllerMethodEntry(
          description: 'Pauses all media',
          methodEnum:
              PlatformInAppWebViewControllerMethod.pauseAllMediaPlayback,
          execute: (controller, params) async {
            await controller.pauseAllMediaPlayback();
            return 'Media paused';
          },
        ),
        ControllerMethodEntry(
          description: 'Checks if playing audio',
          methodEnum: PlatformInAppWebViewControllerMethod.isPlayingAudio,
          execute: (controller, params) async {
            return await controller.isPlayingAudio();
          },
        ),
        ControllerMethodEntry(
          description: 'Checks if muted',
          methodEnum: PlatformInAppWebViewControllerMethod.isMuted,
          execute: (controller, params) async {
            return await controller.isMuted();
          },
        ),
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.cameraMic,
      methods: [
        ControllerMethodEntry(
          description: 'Gets camera capture state',
          methodEnum:
              PlatformInAppWebViewControllerMethod.getCameraCaptureState,
          execute: (controller, params) async {
            final state = await controller.getCameraCaptureState();
            return state?.toString() ?? 'Unknown state';
          },
        ),
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.security,
      methods: [
        ControllerMethodEntry(
          description: 'Checks if secure context',
          methodEnum: PlatformInAppWebViewControllerMethod.isSecureContext,
          execute: (controller, params) async {
            return await controller.isSecureContext();
          },
        ),
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.saveRestore,
      methods: [
        ControllerMethodEntry(
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
      categoryType: ControllerMethodCategoryType.misc,
      methods: [
        ControllerMethodEntry(
          description: 'Gets the WebView ID',
          methodEnum: PlatformInAppWebViewControllerMethod.getViewId,
          execute: (controller, params) async {
            return controller.getViewId();
          },
        ),
        ControllerMethodEntry(
          description: 'Starts Safe Browsing',
          methodEnum: PlatformInAppWebViewControllerMethod.startSafeBrowsing,
          execute: (controller, params) async {
            return await controller.startSafeBrowsing();
          },
        ),
        ControllerMethodEntry(
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
