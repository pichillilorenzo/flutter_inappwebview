part of 'main.dart';

void javascriptDialogs() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onJsAlert,
  );

  skippableTestWidgets('javascript dialogs', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<JsAlertRequest> alertCompleter =
        Completer<JsAlertRequest>();
    final Completer<bool> confirmCompleter = Completer<bool>();
    final Completer<String> promptCompleter = Completer<String>();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialFile: "test_assets/in_app_webview_on_js_dialog_test.html",
          initialSettings: InAppWebViewSettings(clearCache: true),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);

            controller.addJavaScriptHandler(
              handlerName: 'confirm',
              callback: (args) {
                confirmCompleter.complete(args[0] as bool);
              },
            );

            controller.addJavaScriptHandler(
              handlerName: 'prompt',
              callback: (args) {
                promptCompleter.complete(args[0] as String);
              },
            );
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
          onJsAlert: (controller, jsAlertRequest) async {
            JsAlertResponseAction action = JsAlertResponseAction.CONFIRM;
            alertCompleter.complete(jsAlertRequest);
            return JsAlertResponse(handledByClient: true, action: action);
          },
          onJsConfirm: (controller, jsConfirmRequest) async {
            JsConfirmResponseAction action = JsConfirmResponseAction.CONFIRM;
            return JsConfirmResponse(handledByClient: true, action: action);
          },
          onJsPrompt: (controller, jsPromptRequest) async {
            JsPromptResponseAction action = JsPromptResponseAction.CONFIRM;
            return JsPromptResponse(
              handledByClient: true,
              action: action,
              value: 'new value',
            );
          },
        ),
      ),
    );

    await pageLoaded.future;

    final JsAlertRequest jsAlertRequest = await alertCompleter.future;
    expect(jsAlertRequest.message, 'alert message');

    final bool onJsConfirmValue = await confirmCompleter.future;
    expect(onJsConfirmValue, true);

    final String onJsPromptValue = await promptCompleter.future;
    expect(onJsPromptValue, 'new value');
  }, skip: shouldSkip);
}
