import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_inappwebview_windows/flutter_inappwebview_windows.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WindowsInAppWebViewPlatform.registerWith();

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey webViewKey = GlobalKey();

  WindowsInAppWebViewController? webViewController;
  late WindowsFindInteractionController findInteractionController;

  final TextEditingController urlController = TextEditingController(
    text: 'https://flutter.dev',
  );
  final TextEditingController webMessageController = TextEditingController(
    text: 'Hello from Flutter',
  );
  final TextEditingController findController = TextEditingController(
    text: 'Flutter',
  );

  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    javaScriptEnabled: true,
    isFindInteractionEnabled: true,
  );

  String currentUrl = '';
  double progress = 0.0;
  String lastWebMessage = 'No messages yet';
  String findStatus = 'No find results yet';
  bool canPostWebMessage = false;
  bool canAddWebMessageListener = false;

  // WebNotification state
  String notificationStatus = 'No notifications yet';
  WindowsWebNotificationController? activeNotificationController;

  // Print/PDF state
  String printStatus = 'Ready';
  bool isPrinting = false;

  @override
  void initState() {
    super.initState();
    findInteractionController = WindowsFindInteractionController(
      WindowsFindInteractionControllerCreationParams(
        onFindResultReceived: (
          controller,
          activeMatchOrdinal,
          numberOfMatches,
          isDoneCounting,
        ) {
          setState(() {
            findStatus =
                'Match $activeMatchOrdinal of $numberOfMatches (done: $isDoneCounting)';
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    urlController.dispose();
    webMessageController.dispose();
    findController.dispose();
    findInteractionController.dispose();
    activeNotificationController?.dispose();
    super.dispose();
  }

  Future<void> _sendWebMessage() async {
    if (!canPostWebMessage) {
      setState(() {
        lastWebMessage = 'postWebMessage is not supported on Windows yet.';
      });
      return;
    }
    final message = webMessageController.text.trim();
    if (message.isEmpty) {
      return;
    }
    try {
      await webViewController?.postWebMessage(
        message: WebMessage(data: message),
        targetOrigin: WebUri('*'),
      );
    } catch (e) {
      setState(() {
        lastWebMessage = 'Error sending message: $e';
      });
    }
  }

  Future<void> _findAll() async {
    final query = findController.text.trim();
    await findInteractionController.setSearchText(query);
    await findInteractionController.findAll(find: query);
  }

  Future<void> _findNext({required bool forward}) async {
    await findInteractionController.findNext(forward: forward);
  }

  Future<void> _clearFind() async {
    await findInteractionController.clearMatches();
    setState(() {
      findStatus = 'Matches cleared';
    });
  }

  Future<void> _printPage({bool showUI = false}) async {
    if (isPrinting) return;

    setState(() {
      isPrinting = true;
      printStatus = showUI ? 'Opening print dialog...' : 'Printing...';
    });

    try {
      final settings = PrintJobSettings(
        showUI: showUI,
        printDialogKind: PrintJobDialogKind.BROWSER,
        colorMode: PrintJobColorMode.MONOCHROME,
        copies: 1,
        duplexMode: PrintJobDuplexMode.NONE,
        orientation: PrintJobOrientation.PORTRAIT,
        pagesPerSide: 1,
        pageHeight: 1,
        pageRanges: '1',
        handledByClient: !showUI,
        shouldPrintBackgrounds: true,
        shouldPrintHeaderAndFooter: true,
        headerTitle: 'Flutter InAppWebView Windows Example',
        footerUri: 'https://flutter.dev',
      );

      debugPrint('Starting print job with settings: $settings');
      final printJobController = await webViewController?.printCurrentPage(
        settings: settings,
      );

      printJobController?.onComplete = (completed, error) async {
        if (error != null) {
          debugPrint('Print job error: $error');
          setState(() {
            printStatus = 'Print job error: $error';
          });
        } else if (completed) {
          debugPrint('Print job completed successfully');
          setState(() {
            printStatus = 'Print job completed successfully';
          });
        } else {
          debugPrint('Print job was not completed');
          setState(() {
            printStatus = 'Print job was not completed';
          });
        }
        printJobController.dispose();
      };

      debugPrint('Print job controller: $printJobController');
      debugPrint('Print job ID: ${printJobController?.id}');

      // Get print job info
      final info = await printJobController?.getInfo();
      debugPrint('Print job info: $info');
      debugPrint('  State: ${info?.state}');
      debugPrint('  Copies: ${info?.copies}');
      debugPrint('  Number of Pages: ${info?.numberOfPages}');

      setState(() {
        if (showUI) {
          printStatus = 'Print dialog opened';
        } else {
          printStatus =
              'Print job created: ${printJobController?.id ?? "unknown"}';
        }
      });
    } catch (e) {
      debugPrint('Print error: $e');
      setState(() {
        printStatus = 'Print error: $e';
      });
    } finally {
      setState(() {
        isPrinting = false;
      });
    }
  }

  Future<void> _createPdf() async {
    if (isPrinting) return;

    setState(() {
      isPrinting = true;
      printStatus = 'Creating PDF...';
    });

    try {
      final pdfSettings = PrintJobSettings(
        colorMode: PrintJobColorMode.COLOR,
        orientation: PrintJobOrientation.PORTRAIT,
        shouldPrintBackgrounds: true,
      );

      final pdfConfig = PDFConfiguration(
        settings: pdfSettings,
      );

      final pdfData = await webViewController?.createPdf(
        pdfConfiguration: pdfConfig,
      );

      if (pdfData != null) {
        debugPrint('PDF created successfully! Size: ${pdfData.length} bytes');
        setState(() {
          printStatus = 'PDF created: ${pdfData.length} bytes';
        });

        // You could save the PDF to a file here:
        // final file = File('output.pdf');
        // await file.writeAsBytes(pdfData);
      } else {
        debugPrint('PDF creation returned null');
        setState(() {
          printStatus = 'PDF creation failed (null data)';
        });
      }
    } catch (e) {
      debugPrint('PDF creation error: $e');
      setState(() {
        printStatus = 'PDF error: $e';
      });
    } finally {
      setState(() {
        isPrinting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Windows InAppWebView Demo')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'URL',
              ),
              controller: urlController,
              keyboardType: TextInputType.url,
              onSubmitted: (value) {
                var url = WebUri(value);
                if (url.scheme.isEmpty) {
                  url = WebUri('https://www.google.com/search?q=$value');
                }
                webViewController?.loadUrl(urlRequest: URLRequest(url: url));
              },
            ),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: WindowsInAppWebViewWidget(
                      WindowsInAppWebViewWidgetCreationParams(
                        key: webViewKey,
                        initialSettings: settings,
                        findInteractionController: findInteractionController,
                        onWebViewCreated: (controller) async {
                          webViewController = controller;
                          controller.loadUrl(
                            urlRequest: URLRequest(
                              url: WebUri('https://flutter.dev'),
                            ),
                          );
                          final canPost = controller.isMethodSupported(
                            PlatformInAppWebViewControllerMethod.postWebMessage,
                          );
                          final canAddListener = controller.isMethodSupported(
                            PlatformInAppWebViewControllerMethod
                                .addWebMessageListener,
                          );
                          setState(() {
                            canPostWebMessage = canPost;
                            canAddWebMessageListener = canAddListener;
                          });
                        },
                        onLoadStart: (controller, url) {
                          debugPrint('Page started loading: $url');
                          setState(() {
                            currentUrl = url.toString();
                            urlController.text = currentUrl;
                          });
                        },
                        onLoadStop: (controller, url) async {
                          debugPrint('Page finished loading: $url');
                          setState(() {
                            currentUrl = url.toString();
                            urlController.text = currentUrl;
                          });

                          // Inject JavaScript to test Web Notifications API
                          await controller.evaluateJavascript(source: '''
                            (function() {
                              // Check if notifications are supported
                              if (!('Notification' in window)) {
                                console.log('Notifications not supported');
                                return;
                              }
                              
                              console.log('Current Notification permission: ' + Notification.permission);
                              
                              // Request notification permission and create a test notification
                              Notification.requestPermission().then(function(permission) {
                                console.log('Notification permission result: ' + permission);
                                if (permission === 'granted') {
                                  // Create a notification
                                  var notification = new Notification('Test Notification from WebView', {
                                    body: 'This notification was triggered from JavaScript!',
                                    icon: 'https://flutter.dev/favicon.ico',
                                    tag: 'test-notification-1'
                                  });
                                  
                                  notification.onclick = function() {
                                    console.log('Notification clicked!');
                                  };
                                  
                                  notification.onclose = function() {
                                    console.log('Notification closed!');
                                  };
                                  
                                  console.log('Notification created successfully');
                                }
                              });
                            })();
                          ''');
                          debugPrint('Notification JavaScript injected');

                          debugPrint('Test print page silently');
                          _printPage(showUI: false);
                        },
                        onPermissionRequest: (controller, permissionRequest) {
                          debugPrint(
                            'Permission requested for ${permissionRequest.resources}',
                          );
                          return PermissionResponse(
                            resources: permissionRequest.resources,
                            action: PermissionResponseAction.GRANT,
                          );
                        },
                        onNotificationReceived: (controller, request) async {
                          final notification =
                              request.notificationController?.notification;
                          // final senderOrigin = request.senderOrigin;
                          // debugPrint('=== onNotificationReceived ===');
                          // debugPrint('Sender Origin: $senderOrigin');
                          // debugPrint(
                          //     'Notification ID: ${request.notificationController?.id}');
                          // debugPrint('Title: ${notification?.title}');
                          // debugPrint('Body: ${notification?.body}');
                          // debugPrint('Tag: ${notification?.tag}');
                          // debugPrint('Icon URI: ${notification?.iconUri}');
                          // debugPrint('Badge URI: ${notification?.badgeUri}');
                          // debugPrint(
                          //     'Body Image URI: ${notification?.bodyImageUri}');
                          // debugPrint('Language: ${notification?.language}');
                          // debugPrint('Direction: ${notification?.direction}');
                          // debugPrint('Is Silent: ${notification?.isSilent}');
                          // debugPrint(
                          //     'Requires Interaction: ${notification?.requiresInteraction}');
                          // debugPrint(
                          //     'Should Renotify: ${notification?.shouldRenotify}');
                          // debugPrint('Timestamp: ${notification?.timestamp}');
                          // debugPrint(
                          //     'Vibration Pattern: ${notification?.vibrationPattern}');
                          // debugPrint('==============================');

                          setState(() {
                            notificationStatus =
                                'Received: ${notification?.title ?? "Unknown"}';
                            activeNotificationController =
                                request.notificationController
                                    as WindowsWebNotificationController?;
                          });

                          // Set up the onClose handler
                          request.notificationController?.onClose = () async {
                            debugPrint(
                                'Notification close requested from web code');
                            setState(() {
                              notificationStatus =
                                  'Notification closed by web code';
                              activeNotificationController = null;
                            });
                          };

                          // Return a response indicating we'll handle it
                          // (handled: true means we take control, handled: false lets the browser handle it)
                          return NotificationReceivedResponse(handled: true);
                        },
                        onEnterFullscreen: (controller) {
                          debugPrint('Entered fullscreen');
                        },
                        onExitFullscreen: (controller) {
                          debugPrint('Exited fullscreen');
                        },
                        onDOMContentLoaded: (controller, url) => {
                          debugPrint('DOM fully loaded: $url'),
                        },
                        onContentLoading: (controller, url) => {
                          debugPrint('Content loading: $url'),
                        },
                        onProgressChanged: (controller, progressValue) {
                          debugPrint('Progress changed: $progressValue');
                          setState(() {
                            progress = progressValue / 100.0;
                          });
                        },
                        onConsoleMessage: (controller, consoleMessage) {
                          debugPrint(
                            'Console message: [${consoleMessage.messageLevel}] ${consoleMessage.message}',
                          );
                        },
                      ),
                    ).build(context),
                  ),
                  progress < 1.0
                      ? LinearProgressIndicator(value: progress)
                      : Container(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'WebMessage',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    canPostWebMessage && canAddWebMessageListener
                        ? 'WebMessage supported'
                        : 'WebMessage not supported on Windows yet',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: webMessageController,
                          decoration: const InputDecoration(
                            labelText: 'Message to JS',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: canPostWebMessage ? _sendWebMessage : null,
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                  Text('Last message from JS: $lastWebMessage'),
                  const SizedBox(height: 12),
                  const Text(
                    'FindInteractionController',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: findController,
                          decoration: const InputDecoration(
                            labelText: 'Find text',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _findAll,
                        child: const Text('Find All'),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => _findNext(forward: true),
                        child: const Text('Next'),
                      ),
                      ElevatedButton(
                        onPressed: () => _findNext(forward: false),
                        child: const Text('Previous'),
                      ),
                      ElevatedButton(
                        onPressed: _clearFind,
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  Text('Find status: $findStatus'),
                  const SizedBox(height: 12),
                  const Text(
                    'WebNotification',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Status: $notificationStatus'),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: activeNotificationController != null
                            ? () async {
                                debugPrint(
                                    'Reporting notification as shown...');
                                await activeNotificationController
                                    ?.reportShown();
                                debugPrint('Notification reported as shown');
                                setState(() {
                                  notificationStatus = 'Notification shown';
                                });
                              }
                            : null,
                        child: const Text('Report Shown'),
                      ),
                      ElevatedButton(
                        onPressed: activeNotificationController != null
                            ? () async {
                                debugPrint(
                                    'Reporting notification as clicked...');
                                await activeNotificationController
                                    ?.reportClicked();
                                debugPrint('Notification reported as clicked');
                                setState(() {
                                  notificationStatus = 'Notification clicked';
                                });
                              }
                            : null,
                        child: const Text('Report Clicked'),
                      ),
                      ElevatedButton(
                        onPressed: activeNotificationController != null
                            ? () async {
                                debugPrint(
                                    'Reporting notification as closed...');
                                await activeNotificationController
                                    ?.reportClosed();
                                debugPrint('Notification reported as closed');
                                setState(() {
                                  notificationStatus = 'Notification closed';
                                });
                              }
                            : null,
                        child: const Text('Report Closed'),
                      ),
                      ElevatedButton(
                        onPressed: activeNotificationController != null
                            ? () {
                                debugPrint(
                                    'Disposing notification controller...');
                                activeNotificationController?.dispose();
                                debugPrint('Notification controller disposed');
                                setState(() {
                                  notificationStatus = 'Controller disposed';
                                  activeNotificationController = null;
                                });
                              }
                            : null,
                        child: const Text('Dispose'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Print / PDF',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Status: $printStatus'),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed:
                            isPrinting ? null : () => _printPage(showUI: false),
                        child: const Text('Print (Silent)'),
                      ),
                      ElevatedButton(
                        onPressed:
                            isPrinting ? null : () => _printPage(showUI: true),
                        child: const Text('Print (UI)'),
                      ),
                      ElevatedButton(
                        onPressed: isPrinting ? null : _createPdf,
                        child: const Text('Create PDF'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  child: const Icon(Icons.arrow_back),
                  onPressed: () {
                    webViewController?.goBack();
                  },
                ),
                ElevatedButton(
                  child: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    webViewController?.goForward();
                  },
                ),
                ElevatedButton(
                  child: const Icon(Icons.refresh),
                  onPressed: () {
                    webViewController?.reload();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
