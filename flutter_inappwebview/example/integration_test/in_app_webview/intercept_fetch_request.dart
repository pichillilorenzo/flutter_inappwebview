part of 'main.dart';

void interceptFetchRequest() {
  final shouldSkip = !InAppWebView.isPropertySupported(
    PlatformWebViewCreationParamsProperty.shouldInterceptFetchRequest,
  );

  skippableGroup('intercept fetch request', () {
    skippableTestWidgets('send string data', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<Map<String, dynamic>> fetchPostCompleter =
          Completer<Map<String, dynamic>>();
      final Completer<void> shouldInterceptFetchPostRequestCompleter =
          Completer<void>();
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
        <title>InAppWebViewFetchTest</title>
    </head>
    <body>
        <h1>InAppWebViewFetchTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            fetch("http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post", {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: "firstname=Foo&lastname=Bar"
            }).then(function(response) {
                response.json().then(function(value) {
                  window.flutter_inappwebview.callHandler('fetchPost', value);
                }).catch(function(error) {
                  window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
                });
            }).catch(function(error) {
              window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
            });
          });
        </script>
    </body>
</html>
                    """,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);

              controller.addJavaScriptHandler(
                handlerName: "fetchPost",
                callback: (args) {
                  fetchPostCompleter.complete(args[0] as Map<String, dynamic>);
                },
              );
            },
            shouldInterceptFetchRequest: (controller, fetchRequest) async {
              assert(fetchRequest.body == "firstname=Foo&lastname=Bar");

              fetchRequest.body = "firstname=Foo2&lastname=Bar2";
              shouldInterceptFetchPostRequestCompleter.complete();
              return fetchRequest;
            },
          ),
        ),
      );

      await shouldInterceptFetchPostRequestCompleter.future;
      var fetchPostCompleterValue = await fetchPostCompleter.future;

      expect(
        mapEquals(fetchPostCompleterValue, {
          'firstname': 'Foo2',
          'lastname': 'Bar2',
        }),
        true,
      );
    });

    skippableTestWidgets('send json data', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<Map<String, dynamic>> fetchPostCompleter =
          Completer<Map<String, dynamic>>();
      final Completer<void> shouldInterceptFetchPostRequestCompleter =
          Completer<void>();
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
        <title>InAppWebViewFetchTest</title>
    </head>
    <body>
        <h1>InAppWebViewFetchTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var jsonData = {
              firstname: 'Foo',
              lastname: 'Bar'
            };
            fetch("http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post", {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json'
                },
                body: JSON.stringify(jsonData)
            }).then(function(response) {
                response.json().then(function(value) {
                  window.flutter_inappwebview.callHandler('fetchPost', value);
                }).catch(function(error) {
                    window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
                });
            }).catch(function(error) {
                window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
            });
          });
        </script>
    </body>
</html>
                    """,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);

              controller.addJavaScriptHandler(
                handlerName: "fetchPost",
                callback: (args) {
                  fetchPostCompleter.complete(args[0] as Map<String, dynamic>);
                },
              );
            },
            shouldInterceptFetchRequest: (controller, fetchRequest) async {
              String body = fetchRequest.body;
              assert(
                body.contains('"firstname":"Foo"') &&
                    body.contains('"lastname":"Bar"'),
              );

              fetchRequest.body = '{"firstname": "Foo2", "lastname": "Bar2"}';
              shouldInterceptFetchPostRequestCompleter.complete();
              return fetchRequest;
            },
          ),
        ),
      );

      await shouldInterceptFetchPostRequestCompleter.future;
      var fetchPostCompleterValue = await fetchPostCompleter.future;

      expect(
        mapEquals(fetchPostCompleterValue, {
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
      final Completer<Map<String, dynamic>> fetchPostCompleter =
          Completer<Map<String, dynamic>>();
      final Completer<void> shouldInterceptFetchPostRequestCompleter =
          Completer<void>();
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
        <title>InAppWebViewFetchTest</title>
    </head>
    <body>
        <h1>InAppWebViewFetchTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var paramsString = "firstname=Foo&lastname=Bar";
            var searchParams = new URLSearchParams(paramsString);
            fetch("http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post", {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: searchParams
            }).then(function(response) {
                response.json().then(function(value) {
                  window.flutter_inappwebview.callHandler('fetchPost', value);
                }).catch(function(error) {
                    window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
                });
            }).catch(function(error) {
                window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
            });
          });
        </script>
    </body>
</html>
                    """,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);

              controller.addJavaScriptHandler(
                handlerName: "fetchPost",
                callback: (args) {
                  fetchPostCompleter.complete(args[0] as Map<String, dynamic>);
                },
              );
            },
            shouldInterceptFetchRequest: (controller, fetchRequest) async {
              assert(fetchRequest.body == "firstname=Foo&lastname=Bar");

              fetchRequest.body = "firstname=Foo2&lastname=Bar2";
              shouldInterceptFetchPostRequestCompleter.complete();
              return fetchRequest;
            },
          ),
        ),
      );

      await shouldInterceptFetchPostRequestCompleter.future;
      var fetchPostCompleterValue = await fetchPostCompleter.future;

      expect(
        mapEquals(fetchPostCompleterValue, {
          'firstname': 'Foo2',
          'lastname': 'Bar2',
        }),
        true,
      );
    });

    skippableTestWidgets('send FormData', (WidgetTester tester) async {
      final Completer<InAppWebViewController> controllerCompleter =
          Completer<InAppWebViewController>();
      final Completer<Map<String, dynamic>> fetchPostCompleter =
          Completer<Map<String, dynamic>>();
      final Completer<void> shouldInterceptFetchPostRequestCompleter =
          Completer<void>();
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
        <title>InAppWebViewFetchTest</title>
    </head>
    <body>
        <h1>InAppWebViewFetchTest</h1>
        <script>
          window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {
            var formData = new FormData();
            formData.append('firstname', 'Foo');
            formData.append('lastname', 'Bar');
            fetch("http://${environment["NODE_SERVER_IP"]}:8082/test-ajax-post", {
                method: 'POST',
                body: formData
            }).then(function(response) {
                response.json().then(function(value) {
                  window.flutter_inappwebview.callHandler('fetchPost', value);
                }).catch(function(error) {
                    window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
                });
            }).catch(function(error) {
                window.flutter_inappwebview.callHandler('fetchPost', "ERROR: " + error);
            });
          });
        </script>
    </body>
</html>
                    """,
            ),
            onWebViewCreated: (controller) {
              controllerCompleter.complete(controller);

              controller.addJavaScriptHandler(
                handlerName: "fetchPost",
                callback: (args) {
                  fetchPostCompleter.complete(args[0] as Map<String, dynamic>);
                },
              );
            },
            shouldInterceptFetchRequest: (controller, fetchRequest) async {
              assert(fetchRequest.body != null);

              var body = fetchRequest.body.cast<int>();
              var bodyString = String.fromCharCodes(body);
              assert(bodyString.indexOf("WebKitFormBoundary") >= 0);

              fetchRequest.body = utf8.encode(
                bodyString
                    .replaceFirst("Foo", "Foo2")
                    .replaceFirst("Bar", "Bar2"),
              );
              shouldInterceptFetchPostRequestCompleter.complete();
              return fetchRequest;
            },
          ),
        ),
      );

      await shouldInterceptFetchPostRequestCompleter.future;
      var fetchPostCompleterValue = await fetchPostCompleter.future;

      expect(
        mapEquals(fetchPostCompleterValue, {
          'firstname': 'Foo2',
          'lastname': 'Bar2',
        }),
        true,
      );
    });
  }, skip: shouldSkip);
}
