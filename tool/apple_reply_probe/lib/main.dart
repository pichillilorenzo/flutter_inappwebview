import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void check(bool condition, String reason) {
  if (!condition) throw StateError(reason);
}

class ProbeView {
  final bool enabled;
  final String owner;
  final int? windowId;
  late final HeadlessInAppWebView view;
  late InAppWebViewController controller;
  final loaded = Completer<void>();
  Completer<ProbeView>? nextPopup;
  bool popupEnabled = false;
  int dartCalls = 0;
  int consoleEvents = 0;
  int scrollEvents = 0;
  int focusEvents = 0;
  Completer<void>? nextLoad;
  final stallStarted = Completer<void>();
  final stallResult = Completer<String>();

  ProbeView(this.enabled, this.owner, {this.windowId}) {
    view = HeadlessInAppWebView(
      windowId: windowId,
      initialSettings: InAppWebViewSettings(
        useScriptMessageHandlerWithReply: enabled,
        javaScriptCanOpenWindowsAutomatically: true,
        supportMultipleWindows: true,
        pluginScriptsForMainFrameOnly: false,
        javaScriptBridgeForMainFrameOnly: false,
      ),
      initialData: windowId == null
          ? InAppWebViewInitialData(
              data: '<!DOCTYPE html><title>Apple reply probe</title>',
              baseUrl: WebUri('https://allowed.test/'),
            )
          : null,
      initialUserScripts: UnmodifiableListView([
        UserScript(
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: true,
          source: r"""
            window.replyFirstCall = (async function() {
              const start = performance.now();
              const apiPresent = !!window.webkit.messageHandlers.callHandlerWithReply;
              try {
                await window.flutter_inappwebview.callHandler('raw', 'null');
                return {durationMs: performance.now() - start, apiPresent, error: null};
              } catch (error) {
                return {durationMs: performance.now() - start, apiPresent, error: String(error)};
              }
            })();
          """,
        ),
      ]),
      onWebViewCreated: (value) {
        controller = value;
        controller.addJavaScriptHandler(
          handlerName: 'raw',
          callback: (JavaScriptHandlerFunctionData data) {
            dartCalls++;
            return JavaScriptHandlerJsonResult(data.args.single as String);
          },
        );
        controller.addJavaScriptHandler(
          handlerName: 'meta',
          callback: (JavaScriptHandlerFunctionData data) {
            dartCalls++;
            return {
              'owner': owner,
              'main': data.isMainFrame,
              'origin': data.origin.toString(),
              'url': data.requestUrl.toString(),
            };
          },
        );
        controller.addJavaScriptHandler(
          handlerName: 'ordered',
          callback: (JavaScriptHandlerFunctionData data) async {
            dartCalls++;
            final index = data.args.single as int;
            await Future<void>.delayed(Duration(milliseconds: 31 - index % 32));
            return {'index': index, 'owner': owner};
          },
        );
        controller.addJavaScriptHandler(
          handlerName: 'fail',
          callback: (JavaScriptHandlerFunctionData data) {
            dartCalls++;
            throw StateError('probe error: עברית \' " \\');
          },
        );
        controller.addJavaScriptHandler(
          handlerName: 'stall',
          callback: (JavaScriptHandlerFunctionData data) async {
            dartCalls++;
            stallStarted.complete();
            return JavaScriptHandlerJsonResult(await stallResult.future);
          },
        );
      },
      onLoadStop: (controller, url) {
        if (!loaded.isCompleted) loaded.complete();
        if (nextLoad != null && !nextLoad!.isCompleted) nextLoad!.complete();
      },
      onConsoleMessage: (controller, message) {
        consoleEvents++;
      },
      onScrollChanged: (controller, x, y) {
        scrollEvents++;
      },
      onWindowFocus: (controller) {
        focusEvents++;
      },
      onCreateWindow: (controller, action) async {
        final child = ProbeView(
          popupEnabled,
          '$owner-popup',
          windowId: action.windowId,
        );
        await child.view.run();
        nextPopup!.complete(child);
        return true;
      },
    );
  }

  Future<void> start() async {
    await view.run();
    await loaded.future.timeout(const Duration(seconds: 30));
    await js(
      "await window.flutter_inappwebview.callHandler('raw', 'null'); return true;",
    );
  }

  Future<dynamic> js(
    String source, {
    Map<String, dynamic> args = const {},
    ContentWorld? world,
  }) async {
    final result = await controller
        .callAsyncJavaScript(
          functionBody: source,
          arguments: args,
          contentWorld: world,
        )
        .timeout(const Duration(seconds: 30));
    check(
      result != null && result.error == null,
      '$owner: JS failed: ${result?.error}',
    );
    return result!.value;
  }

  Future<bool> hasReplyAPI() async =>
      await js(
        "return !!window.webkit.messageHandlers.callHandlerWithReply;",
      ) ==
      true;

  Future<void> instrument() async {
    // Count actual legacy callback registrations without touching native APIs.
    // This proves that opt-in parity did not silently pass using only fallback.
    await js(r'''
      window.legacyRegistrations = 0;
      window.flutter_inappwebview = new Proxy(window.flutter_inappwebview, {
        set(target, key, value) {
          if (/^\d+$/.test(String(key))) window.legacyRegistrations++;
          target[key] = value; return true;
        }
      });
      return true;
    ''');
  }

  Future<ProbeView> openPopup(bool optIn) async {
    popupEnabled = optIn;
    nextPopup = Completer<ProbeView>();
    await controller.evaluateJavascript(
      source:
          "window.open('about:blank', 'reply-probe-${DateTime.now().microsecondsSinceEpoch}'); null;",
    );
    final popup = await nextPopup!.future.timeout(const Duration(seconds: 30));
    await popup.loaded.future.timeout(const Duration(seconds: 30));
    await popup.js(
      "await window.flutter_inappwebview.callHandler('raw', 'null'); return true;",
    );
    return popup;
  }
}

Future<void> parity(ProbeView view, Map<String, dynamic> fixtures) async {
  await view.instrument();
  final report = await view.js(
    r'''
    const bridge = window.flutter_inappwebview;
    for (const raw of valid) {
      const actual = await bridge.callHandler('raw', raw);
      if (JSON.stringify(actual) !== JSON.stringify(JSON.parse(raw))) throw new Error('JSON parity');
      if (actual && Object.prototype.hasOwnProperty.call(JSON.parse(raw), '__proto__') &&
          (!Object.prototype.hasOwnProperty.call(actual, '__proto__') || actual.inherited !== undefined)) throw new Error('prototype mutation');
    }
    for (const raw of invalid) {
      let rejected = false;
      try { await bridge.callHandler('raw', raw); } catch (_) { rejected = true; }
      if (!rejected) throw new Error('malformed JSON accepted');
    }
    let failure = '';
    try { await bridge.callHandler('fail'); } catch (error) { failure = error.message; }
    if (!failure.includes('probe error')) throw new Error('Dart error missing');
    const values = await Promise.all(Array.from({length: 128}, (_, i) => bridge.callHandler('ordered', i)));
    values.forEach((value, i) => { if (value.index !== i || value.owner !== owner) throw new Error('reply correlation'); });
    const oneWay = bridge._callHandlerOneWay('onConsoleMessage', {level:'log', message:'one-way probe'});
    if (oneWay !== undefined) throw new Error('one-way allocated a Promise');
    return {legacyRegistrations: window.legacyRegistrations, count: values.length};
  ''',
    args: {
      'valid': fixtures['valid'],
      'invalid': fixtures['invalid'],
      'owner': view.owner,
    },
  );
  check((report as Map)['count'] == 128, '128 real concurrent replies');
  check(
    view.enabled
        ? report['legacyRegistrations'] == 0
        : (report['legacyRegistrations'] as num) > 128,
    '${view.owner}: selected transport',
  );

  final frame = await view.js(r'''
    const frame = document.createElement('iframe');
    frame.srcdoc = '<!DOCTYPE html><title>frame</title>';
    const loaded = new Promise(resolve => frame.onload = resolve);
    document.body.appendChild(frame); await loaded;
    await new Promise(r => setTimeout(r, 20));
    window.probeFrame = frame;
    return await frame.contentWindow.flutter_inappwebview.callHandler('meta');
  ''');
  check(
    (frame as Map)['main'] == false && frame['owner'] == view.owner,
    'iframe uses native frame metadata and its owner',
  );
  if (view.enabled) {
    final named = await view.js(
      "await new Promise(r => setTimeout(r, 20)); return await window.flutter_inappwebview.callHandler('meta');",
      world: ContentWorld.world(name: 'reply-probe'),
    );
    check(
      (named as Map)['owner'] == view.owner,
      'reply reaches named content world',
    );
    var settings = (await view.controller.getSettings())!;
    settings.javaScriptHandlersForMainFrameOnly = true;
    await view.controller.setSettings(settings: settings);
    check(
      await view.js(r'''
      try { await window.probeFrame.contentWindow.flutter_inappwebview.callHandler('meta'); return false; }
      catch (error) { return error.message.includes('main frame'); }
    ''') ==
          true,
      'native main-frame rejection settles',
    );
    settings.javaScriptHandlersForMainFrameOnly = false;
    settings.javaScriptHandlersOriginAllowList = {};
    await view.controller.setSettings(settings: settings);
    check(
      await view.js(r'''
      try { await window.flutter_inappwebview.callHandler('meta'); return false; }
      catch (error) { return error.message.includes('origin'); }
    ''') ==
          true,
      'native origin rejection settles',
    );
    settings.javaScriptHandlersOriginAllowList = null;
    await view.controller.setSettings(settings: settings);
  }
  final settings = (await view.controller.getSettings())!;
  settings.useScriptMessageHandlerWithReply = !view.enabled;
  await view.controller.setSettings(settings: settings);
  check(
    (await view.controller.getSettings())!.useScriptMessageHandlerWithReply ==
        view.enabled,
    'setSettings preserves creation-owned policy',
  );
}

Future<void> waitForEvent(bool Function() received, String reason) async {
  final elapsed = Stopwatch()..start();
  while (!received()) {
    check(elapsed.elapsed < const Duration(seconds: 5), reason);
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

Future<void> verifySurvivor(ProbeView view) async {
  final beforeConsole = view.consoleEvents;
  final beforeScroll = view.scrollEvents;
  final beforeFocus = view.focusEvents;
  final value = await view.js(r"""
    const bridge = window.flutter_inappwebview;
    bridge._callHandlerOneWay('onConsoleMessage', {level:'warn', message:'surviving owner'});
    bridge._callHandlerOneWay('onScrollChanged', {x:17, y:23});
    bridge._callHandlerOneWay('onWindowFocus');
    return await bridge.callHandler('meta');
  """);
  check(
    (value as Map)['owner'] == view.owner,
    'survivor uses its own Dart owner',
  );
  await Future.wait([
    waitForEvent(
      () => view.consoleEvents > beforeConsole,
      'console callback did not reach the surviving owner',
    ),
    waitForEvent(
      () => view.scrollEvents > beforeScroll,
      'scroll callback did not reach the surviving owner',
    ),
    waitForEvent(
      () => view.focusEvents > beforeFocus,
      'focus callback did not reach the surviving owner',
    ),
  ]);
  view.nextLoad = Completer<void>();
  await view.controller.loadData(
    data: '<!DOCTYPE html><title>surviving document</title>',
    baseUrl: WebUri('https://allowed.test/survivor'),
  );
  await view.nextLoad!.future.timeout(const Duration(seconds: 30));
  final afterNavigation = await view.js(
    "return await window.flutter_inappwebview.callHandler('meta');",
  );
  check(
    (afterNavigation as Map)['owner'] == view.owner,
    'survivor navigation retains bootstrap and native routing',
  );
  if (view.enabled) {
    final named = await view.js(
      "return await window.flutter_inappwebview.callHandler('meta');",
      world: ContentWorld.world(name: 'surviving-owner-world'),
    );
    check(
      (named as Map)['owner'] == view.owner,
      'named-world reply uses the surviving native owner',
    );
  }
}

Future<List<Map<String, dynamic>>> sharedOwnership() async {
  final cases = <Map<String, dynamic>>[];
  for (final flags in [
    [false, false],
    [true, false],
    [false, true],
    [true, true],
  ]) {
    for (final parentFirst in [true, false]) {
      final parent = ProbeView(
        flags[0],
        'owner-${flags[0]}-${flags[1]}-$parentFirst',
      );
      await parent.start();
      final child = await parent.openPopup(flags[1]);
      final survivor = parentFirst ? child : parent;
      final closing = parentFirst ? parent : child;
      await survivor.js(
        "window.survivingReply = window.flutter_inappwebview.callHandler('stall'); return true;",
      );
      await survivor.stallStarted.future.timeout(const Duration(seconds: 30));
      await closing.view.dispose();
      survivor.stallResult.complete('{"survived":true}');
      final pendingResult = await survivor.js(
        'return await window.survivingReply;',
      );
      check(
        (pendingResult as Map)['survived'] == true,
        'disposing a sibling must not cancel the surviving owner reply',
      );
      check(
        await survivor.hasReplyAPI() == survivor.enabled,
        'shared API lifetime follows remaining opt-in owner',
      );
      await verifySurvivor(survivor);
      await survivor.view.dispose();
      cases.add({
        'parentOptIn': flags[0],
        'popupOptIn': flags[1],
        'closeOrder': parentFirst ? 'parent-first' : 'popup-first',
        'pendingReplySurvived': true,
        'consoleScrollFocusCallbacksReceived': true,
        'survivorNavigated': true,
        'namedWorldReply': survivor.enabled ? 'passed' : 'not-applicable',
      });
    }
  }
  return cases;
}

Future<Map<String, dynamic>> measure(
  ProbeView view,
  int bytes,
  int concurrency,
) async {
  final raw = jsonEncode({'text': 'x' * bytes});
  final count = bytes >= 1048576 ? 20 : 100;
  view.dartCalls = 0;
  final result = await view.js(
    r'''
    const bridge = window.flutter_inappwebview;
    for (let i = 0; i < 5; i++) await bridge.callHandler('raw', raw);
    window.legacyRegistrations = 0;
    const samples = [];
    const wallStart = performance.now();
    for (let offset = 0; offset < count; offset += concurrency) {
      await Promise.all(Array.from({length: Math.min(concurrency, count - offset)}, async () => {
        const start = performance.now();
        const result = await bridge.callHandler('raw', raw);
        if (result.text.length !== bytes) throw new Error('benchmark payload mismatch');
        samples.push(performance.now() - start);
      }));
    }
    const wallMs = performance.now() - wallStart;
    samples.sort((a,b) => a-b);
    return {wallMs, medianMs: samples[Math.floor(samples.length/2)], p95Ms: samples[Math.floor(samples.length*0.95)],
      legacyRegistrations: window.legacyRegistrations, samples: samples.length};
  ''',
    args: {
      'raw': raw,
      'count': count,
      'concurrency': concurrency,
      'bytes': bytes,
    },
  );
  check(view.dartCalls == count + 5, 'benchmark RPCs execute exactly once');
  return {
    'mode': view.enabled ? 'reply' : 'legacy',
    'payloadBytes': utf8.encode(raw).length,
    'concurrency': concurrency,
    'dartCallsIncludingWarmup': view.dartCalls,
    ...Map<String, dynamic>.from(result as Map),
  };
}

Future<void> runProbe() async {
  PlatformInAppWebViewController.debugLoggingSettings.enabled = false;
  final fixtures =
      jsonDecode(
            await rootBundle.loadString(
              'assets/javascript_handler_json_cases.json',
            ),
          )
          as Map<String, dynamic>;
  (fixtures['valid'] as List).add(
    jsonEncode({'text': 'עברית 😀\u2028\u2029' * 50000}),
  );
  final legacy = ProbeView(false, 'legacy');
  final modern = ProbeView(true, 'modern');
  await legacy.start();
  check(!await legacy.hasReplyAPI(), 'default OFF registers no reply handler');
  await modern.start();
  check(await modern.hasReplyAPI(), 'opt-in registers native reply handler');
  check(
    !await legacy.hasReplyAPI(),
    'independent controllers do not share opt-in',
  );
  final startupRecords = [
    {
      'mode': 'legacy',
      'firstCall': await legacy.js('return await window.replyFirstCall;'),
    },
    {
      'mode': 'reply',
      'firstCall': await modern.js('return await window.replyFirstCall;'),
    },
  ];
  await parity(legacy, fixtures);
  await parity(modern, fixtures);
  for (final parent in [legacy, modern]) {
    final child = await parent.openPopup(!parent.enabled);
    check(
      await parent.hasReplyAPI(),
      'shared controller exposes API while an owner opts in',
    );
    await child.instrument();
    final result = await child.js(
      "return await window.flutter_inappwebview.callHandler('meta');",
    );
    check(
      (result as Map)['owner'] == child.owner,
      'popup calls its own Dart owner',
    );
    final registrations = await child.js('return window.legacyRegistrations;');
    check(
      child.enabled ? registrations == 0 : registrations == 1,
      'popup opt-in is independent of parent',
    );
    await child.view.dispose();
    check(
      await parent.hasReplyAPI() == parent.enabled,
      'last owner disposal removes API from existing documents',
    );
    await parent.js(
      "return await window.flutter_inappwebview.callHandler('meta');",
    );
  }
  final sharedOwnershipCases = await sharedOwnership();
  final records = <Map<String, dynamic>>[];
  for (final bytes in [64, 65536, 1048576]) {
    for (final concurrency in [1, 16]) {
      for (final view in [legacy, modern]) {
        records.add(await measure(view, bytes, concurrency));
      }
    }
  }
  await modern.js(
    "window.pending = window.flutter_inappwebview.callHandler('stall').catch(() => null); return true;",
  );
  await modern.stallStarted.future.timeout(const Duration(seconds: 30));
  await modern.view.dispose();
  modern.stallResult.complete('{"late":true}');
  await Future<void>.delayed(const Duration(milliseconds: 50));
  await legacy.view.dispose();
  // These are live WebKit + Flutter round trips in one build/runtime. Native
  // allocations/CPU and hardware-device acceptance require separate profiling.
  stdout.writeln(
    'APPLE_REPLY_RESULT:${jsonEncode({
      'kind': 'live macOS WKWebView + Flutter; release build',
      'os': Platform.operatingSystemVersion,
      'dart': Platform.version,
      'nativeMainThreadCpuMs': null,
      'nativeAllocations': null,
      'physicalDeviceAcceptance': false,
      'probeDeadlineMs': 1000,
      'startupScope': 'first application call includes remaining bootstrap policy wait; policy-only native latency is not isolated',
      'startupRecords': startupRecords,
      'compatibility': {'rawJsonAndErrorParity': true, 'concurrentReplies': 128, 'sharedOwnershipCases': sharedOwnershipCases},
      'records': records,
    })}',
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      home: Scaffold(body: Center(child: Text('Apple reply experiment probe'))),
    ),
  );
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await runProbe().timeout(const Duration(minutes: 5));
      exit(0);
    } catch (error, stack) {
      stderr.writeln('APPLE_REPLY_FAILURE: $error\n$stack');
      exit(1);
    }
  });
}
