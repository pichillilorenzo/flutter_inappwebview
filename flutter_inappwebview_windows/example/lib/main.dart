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
	);

	String currentUrl = '';
	double progress = 0.0;
	String lastWebMessage = 'No messages yet';
	String findStatus = 'No find results yet';
	bool canPostWebMessage = false;
	bool canAddWebMessageListener = false;

	@override
	void initState() {
		super.initState();
		findInteractionController = WindowsFindInteractionController(
			WindowsFindInteractionControllerCreationParams(
				onFindResultReceived:
						(
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
		super.dispose();
	}

	InAppWebViewInitialData _buildInitialData() {
		final html = '''
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<style>
		body { font-family: Arial, sans-serif; padding: 16px; }
		.box { padding: 12px; border: 1px solid #ccc; margin-top: 12px; }
		.label { font-weight: bold; }
	</style>
</head>
<body>
	<h2>Windows InAppWebView Demo</h2>
	<p>Try FindInteractionController by searching for the word “Flutter”.</p>
	<p>Flutter makes it easy to build apps with Flutter on Windows. Flutter is fast.</p>

	<div class="box">
		<div class="label">WebMessage JS → Flutter</div>
		<input id="jsMessageInput" placeholder="Message to Flutter" value="Hello from JS" />
		<button onclick="sendToFlutter()">Send to Flutter</button>
	</div>

	<div class="box">
		<div class="label">WebMessage Flutter → JS</div>
		<div id="flutterMessage">No message received yet</div>
	</div>

	<script>
		function sendToFlutter() {
			const value = document.getElementById('jsMessageInput').value || 'Hello from JS';
			if (window.flutterMessageListener && window.flutterMessageListener.postMessage) {
				window.flutterMessageListener.postMessage(value);
			} else if (window.chrome && window.chrome.webview) {
				window.chrome.webview.postMessage(value);
			} else {
				console.log('No message bridge available');
			}
		}

		function handleMessage(data) {
			const target = document.getElementById('flutterMessage');
			target.textContent = 'From Flutter: ' + data;
		}

		window.addEventListener('message', (event) => {
			handleMessage(event.data);
		});

		if (window.chrome && window.chrome.webview) {
			window.chrome.webview.addEventListener('message', (event) => {
				handleMessage(event.data);
			});
		}
	</script>
</body>
</html>
''';

		return InAppWebViewInitialData(data: html, baseUrl: WebUri('https://local'));
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
												initialData: _buildInitialData(),
												initialSettings: settings,
												findInteractionController: findInteractionController,
												onWebViewCreated: (controller) async {
													webViewController = controller;
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
													if (canAddListener) {
														await controller.addWebMessageListener(
															PlatformWebMessageListener(
																PlatformWebMessageListenerCreationParams(
																	jsObjectName: 'flutterMessageListener',
																	onPostMessage: (message, sourceOrigin,
																			isMainFrame, reply) {
																		setState(() {
																			lastWebMessage =
																					message?.data?.toString() ??
																					'Empty message received';
																		});
																	},
																),
															),
														);
													}
												},
												onLoadStart: (controller, url) {
													setState(() {
														currentUrl = url.toString();
														urlController.text = currentUrl;
													});
												},
												onLoadStop: (controller, url) {
													setState(() {
														currentUrl = url.toString();
														urlController.text = currentUrl;
													});
												},
												onProgressChanged: (controller, progressValue) {
													setState(() {
														progress = progressValue / 100.0;
													});
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
									const SizedBox(height: 8),
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
