part of 'main.dart';

void onPermissionRequest() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onPermissionRequest,
  );

  skippableTestWidgets('onPermissionRequest', (WidgetTester tester) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<List<PermissionResourceType>> onPermissionRequestCompleter =
        Completer<List<PermissionResourceType>>();
    final expectedValue = [PermissionResourceType.CAMERA];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_PERMISSION_SITE),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) {
              pageLoaded.complete();
            }
          },
          onPermissionRequest: (controller, permissionRequest) async {
            onPermissionRequestCompleter.complete(permissionRequest.resources);
            return PermissionResponse(
              resources: permissionRequest.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await tester.pump();

    await controller.evaluateJavascript(
      source: "document.querySelector('#camera').click();",
    );
    final List<PermissionResourceType> resources =
        await onPermissionRequestCompleter.future;

    expect(listEquals(resources, expectedValue), true);
  }, skip: shouldSkip);

  final shouldSkip2 = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.onPermissionRequestCanceled,
  );

  skippableTestWidgets('onPermissionRequestCanceled', (
    WidgetTester tester,
  ) async {
    final Completer<InAppWebViewController> controllerCompleter =
        Completer<InAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<List<PermissionResourceType>> onPermissionRequestCompleter =
        Completer<List<PermissionResourceType>>();
    final Completer<List<PermissionResourceType>>
    onPermissionRequestCancelCompleter =
        Completer<List<PermissionResourceType>>();
    final expectedValue = [PermissionResourceType.MICROPHONE];

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: TEST_PERMISSION_SITE),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) {
              pageLoaded.complete();
            }
          },
          onPermissionRequest: (controller, permissionRequest) async {
            onPermissionRequestCompleter.complete(permissionRequest.resources);
            await Future.delayed(Duration(seconds: 5));
            return PermissionResponse(
              resources: permissionRequest.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          onPermissionRequestCanceled: (controller, permissionRequest) {
            onPermissionRequestCancelCompleter.complete(
              permissionRequest.resources,
            );
          },
        ),
      ),
    );

    final InAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    await tester.pump();

    await controller.evaluateJavascript(
      source: "document.querySelector('#microphone').click();",
    );

    final List<PermissionResourceType> resources =
        await onPermissionRequestCompleter.future;
    expect(listEquals(resources, expectedValue), true);

    // Reload the webview to cancel the permission request
    controller.reload();

    final List<PermissionResourceType> canceledResources =
        await onPermissionRequestCancelCompleter.future;
    expect(listEquals(canceledResources, expectedValue), true);
  }, skip: shouldSkip2);
}
