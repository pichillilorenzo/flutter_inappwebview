part of 'main.dart';

void interceptAjaxRequest() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.shouldInterceptAjaxRequest,
  );

  skippableGroup('intercept ajax request', () {
    skippableTestWidgets('send string data', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer shouldInterceptAjaxPostRequestCompleter =
          Completer<void>();
      final Completer<Map<String, dynamic>> onAjaxReadyStateChangeCompleter =
          Completer<Map<String, dynamic>>();
      final Completer<Map<String, dynamic>> onAjaxProgressCompleter =
          Completer<Map<String, dynamic>>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(
              data:
                  """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewAjaxTest</title>
    </head>
    <body>
        <h1>InAppWebViewAjaxTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var xhttp = new XMLHttpRequest();
            xhttp.open("POST", "http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post");
            xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xhttp.send("firstname=Foo&lastname=Bar");
          });
        </script>
    </body>
</html>
                    """,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
              assert(ajaxRequest.data == "firstname=Foo&lastname=Bar");

              ajaxRequest.responseType = 'json';
              ajaxRequest.data = "firstname=Foo2&lastname=Bar2";
              shouldInterceptAjaxPostRequestCompleter.complete(controller);
              return ajaxRequest;
            },
            onAjaxReadyStateChange: (controller, ajaxRequest) async {
              if (ajaxRequest.readyState == AjaxRequestReadyState.DONE &&
                  ajaxRequest.status == 200) {
                Map<String, dynamic> res = ajaxRequest.response;
                onAjaxReadyStateChangeCompleter.complete(res);
              }
              return AjaxRequestAction.PROCEED;
            },
            onAjaxProgress: (controller, ajaxRequest) async {
              if (ajaxRequest.event!.type == AjaxRequestEventType.LOAD) {
                Map<String, dynamic> res = ajaxRequest.response;
                onAjaxProgressCompleter.complete(res);
              }
              return AjaxRequestAction.PROCEED;
            },
          ),
        ),
      );

      await shouldInterceptAjaxPostRequestCompleter.future;
      final Map<String, dynamic> onAjaxReadyStateChangeValue =
          await onAjaxReadyStateChangeCompleter.future;
      final Map<String, dynamic> onAjaxProgressValue =
          await onAjaxProgressCompleter.future;

      expect(
        mapEquals(onAjaxReadyStateChangeValue, {
          'firstname': 'Foo2',
          'lastname': 'Bar2',
        }),
        true,
      );
      expect(
        mapEquals(onAjaxProgressValue, {
          'firstname': 'Foo2',
          'lastname': 'Bar2',
        }),
        true,
      );
    });

    skippableTestWidgets('send json data', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer shouldInterceptAjaxPostRequestCompleter =
          Completer<void>();
      final Completer<Map<String, dynamic>> onAjaxReadyStateChangeCompleter =
          Completer<Map<String, dynamic>>();
      final Completer<Map<String, dynamic>> onAjaxProgressCompleter =
          Completer<Map<String, dynamic>>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(
              data:
                  """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewAjaxTest</title>
    </head>
    <body>
        <h1>InAppWebViewAjaxTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var jsonData = {
              firstname: 'Foo',
              lastname: 'Bar'
            };
            var xhttp = new XMLHttpRequest();
            xhttp.open("POST", "http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post");
            xhttp.setRequestHeader("Content-type", "application/json");
            xhttp.send(JSON.stringify(jsonData));
          });
        </script>
    </body>
</html>
                    """,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
              String data = ajaxRequest.data;
              assert(
                data.contains('"firstname":"Foo"') &&
                    data.contains('"lastname":"Bar"'),
              );

              ajaxRequest.responseType = 'json';
              ajaxRequest.data = '{"firstname": "Foo2", "lastname": "Bar2"}';
              shouldInterceptAjaxPostRequestCompleter.complete(controller);
              return ajaxRequest;
            },
            onAjaxReadyStateChange: (controller, ajaxRequest) async {
              if (ajaxRequest.readyState == AjaxRequestReadyState.DONE &&
                  ajaxRequest.status == 200) {
                Map<String, dynamic> res = ajaxRequest.response;
                onAjaxReadyStateChangeCompleter.complete(res);
              }
              return AjaxRequestAction.PROCEED;
            },
            onAjaxProgress: (controller, ajaxRequest) async {
              if (ajaxRequest.event!.type == AjaxRequestEventType.LOAD) {
                Map<String, dynamic> res = ajaxRequest.response;
                onAjaxProgressCompleter.complete(res);
              }
              return AjaxRequestAction.PROCEED;
            },
          ),
        ),
      );

      await shouldInterceptAjaxPostRequestCompleter.future;
      final Map<String, dynamic> onAjaxReadyStateChangeValue =
          await onAjaxReadyStateChangeCompleter.future;
      final Map<String, dynamic> onAjaxProgressValue =
          await onAjaxProgressCompleter.future;

      expect(
        mapEquals(onAjaxReadyStateChangeValue, {
          'firstname': 'Foo2',
          'lastname': 'Bar2',
        }),
        true,
      );
      expect(
        mapEquals(onAjaxProgressValue, {
          'firstname': 'Foo2',
          'lastname': 'Bar2',
        }),
        true,
      );
    });

    skippableTestWidgets('send URLSearchParams data', (
      WidgetTester tester,
    ) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer shouldInterceptAjaxPostRequestCompleter =
          Completer<void>();
      final Completer<Map<String, dynamic>> onAjaxReadyStateChangeCompleter =
          Completer<Map<String, dynamic>>();
      final Completer<Map<String, dynamic>> onAjaxProgressCompleter =
          Completer<Map<String, dynamic>>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(
              data:
                  """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewAjaxTest</title>
    </head>
    <body>
        <h1>InAppWebViewAjaxTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var paramsString = "firstname=Foo&lastname=Bar";
            var searchParams = new URLSearchParams(paramsString);
            var xhttp = new XMLHttpRequest();
            xhttp.open("POST", "http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post");
            xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xhttp.send(searchParams);
          });
        </script>
    </body>
</html>
                    """,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
              assert(ajaxRequest.data == "firstname=Foo&lastname=Bar");

              ajaxRequest.responseType = 'json';
              ajaxRequest.data = "firstname=Foo2&lastname=Bar2";
              shouldInterceptAjaxPostRequestCompleter.complete(controller);
              return ajaxRequest;
            },
            onAjaxReadyStateChange: (controller, ajaxRequest) async {
              if (ajaxRequest.readyState == AjaxRequestReadyState.DONE &&
                  ajaxRequest.status == 200) {
                Map<String, dynamic> res = ajaxRequest.response;
                onAjaxReadyStateChangeCompleter.complete(res);
              }
              return AjaxRequestAction.PROCEED;
            },
            onAjaxProgress: (controller, ajaxRequest) async {
              if (ajaxRequest.event!.type == AjaxRequestEventType.LOAD) {
                Map<String, dynamic> res = ajaxRequest.response;
                onAjaxProgressCompleter.complete(res);
              }
              return AjaxRequestAction.PROCEED;
            },
          ),
        ),
      );

      await shouldInterceptAjaxPostRequestCompleter.future;
      final Map<String, dynamic> onAjaxReadyStateChangeValue =
          await onAjaxReadyStateChangeCompleter.future;
      final Map<String, dynamic> onAjaxProgressValue =
          await onAjaxProgressCompleter.future;

      expect(
        mapEquals(onAjaxReadyStateChangeValue, {
          'firstname': 'Foo2',
          'lastname': 'Bar2',
        }),
        true,
      );
      expect(
        mapEquals(onAjaxProgressValue, {
          'firstname': 'Foo2',
          'lastname': 'Bar2',
        }),
        true,
      );
    });

    skippableTestWidgets('send FormData', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer shouldInterceptAjaxPostRequestCompleter =
          Completer<void>();
      final Completer<Map<String, dynamic>> onAjaxReadyStateChangeCompleter =
          Completer<Map<String, dynamic>>();
      final Completer<Map<String, dynamic>> onAjaxProgressCompleter =
          Completer<Map<String, dynamic>>();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: InAppWebView(
            key: GlobalKey(),
            initialData: InAppWebViewInitialData(
              data:
                  """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>InAppWebViewAjaxTest</title>
    </head>
    <body>
        <h1>InAppWebViewAjaxTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var formData = new FormData();
            formData.append('firstname', 'Foo');
            formData.append('lastname', 'Bar');
            var xhttp = new XMLHttpRequest();
            xhttp.open("POST", "http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post");
            xhttp.send(formData);
          });
        </script>
    </body>
</html>
                    """,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);
            },
            shouldInterceptAjaxRequest: (controller, ajaxRequest) async {
              assert(ajaxRequest.data != null);

              var body = ajaxRequest.data.cast<int>();
              var bodyString = String.fromCharCodes(body);
              assert(bodyString.indexOf("WebKitFormBoundary") >= 0);

              ajaxRequest.data = utf8.encode(
                bodyString
                    .replaceFirst("Foo", "Foo2")
                    .replaceFirst("Bar", "Bar2"),
              );
              ajaxRequest.responseType = 'json';
              shouldInterceptAjaxPostRequestCompleter.complete(controller);
              return ajaxRequest;
            },
            onAjaxReadyStateChange: (controller, ajaxRequest) async {
              if (ajaxRequest.readyState == AjaxRequestReadyState.DONE &&
                  ajaxRequest.status == 200) {
                Map<String, dynamic> res = ajaxRequest.response;
                onAjaxReadyStateChangeCompleter.complete(res);
              }
              return AjaxRequestAction.PROCEED;
            },
            onAjaxProgress: (controller, ajaxRequest) async {
              if (ajaxRequest.event!.type == AjaxRequestEventType.LOAD) {
                Map<String, dynamic> res = ajaxRequest.response;
                onAjaxProgressCompleter.complete(res);
              }
              return AjaxRequestAction.PROCEED;
            },
          ),
        ),
      );

      await shouldInterceptAjaxPostRequestCompleter.future;
      final Map<String, dynamic> onAjaxReadyStateChangeValue =
          await onAjaxReadyStateChangeCompleter.future;
      final Map<String, dynamic> onAjaxProgressValue =
          await onAjaxProgressCompleter.future;

      expect(
        mapEquals(onAjaxReadyStateChangeValue, {
          'firstname': 'Foo2',
          'lastname': 'Bar2',
        }),
        true,
      );
      expect(
        mapEquals(onAjaxProgressValue, {
          'firstname': 'Foo2',
          'lastname': 'Bar2',
        }),
        true,
      );
    });
  }, skip: shouldSkip);
}
