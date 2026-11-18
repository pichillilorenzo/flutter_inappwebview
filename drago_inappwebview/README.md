# drago_inappwebview

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

A Flutter plugin to add an inline webview, use a headless webview, and open an in-app browser window.

This is a fork of [pichillilorenzo/flutter_inappwebview](https://github.com/pichillilorenzo/flutter_inappwebview) (Apache-2.0), shipped as a **single package**: the upstream federated packages (platform interface, Android, iOS, macOS, Windows, Linux, Web) are merged into `drago_inappwebview`. There is nothing else to depend on.

Supported platforms: Android, iOS, macOS, Windows, Linux, Web.

## Installation

```yaml
dependencies:
  drago_inappwebview:
    git:
      url: https://github.com/selvam920/drago_inappwebview
      path: drago_inappwebview
```

```dart
import 'package:drago_inappwebview/drago_inappwebview.dart';
```

### Web

Add the support script to `web/index.html`:

```html
<script src="assets/packages/drago_inappwebview/platforms/web/assets/web/web_support.js" defer></script>
```

## Differences from upstream

- JavaScript bridge: `window.drago_inappwebview.callHandler(...)` (instead of `window.flutter_inappwebview`).
- Ready event: `dragoInAppWebViewPlatformReady` (instead of `flutterInAppWebViewPlatformReady`).

```js
window.addEventListener('dragoInAppWebViewPlatformReady', function () {
  window.drago_inappwebview.callHandler('handlerName', 1, 2).then(console.log);
});
```

- Android `useHybridComposition` defaults to `false`.

See [CHANGELOG.md](CHANGELOG.md) for everything else.

## API docs (upstream)

The API is the same as upstream apart from the names above:

- [inappwebview.dev/docs](https://inappwebview.dev/docs/intro)
- [Upstream repository](https://github.com/pichillilorenzo/flutter_inappwebview)

## License

Apache-2.0, see [LICENSE](LICENSE). Original work by Lorenzo Pichilli and the flutter_inappwebview contributors.
