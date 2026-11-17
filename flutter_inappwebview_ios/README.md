# flutter\_inappwebview\_ios

The Apple iOS WKWebView implementation of [`flutter_inappwebview`](https://pub.dev/packages/flutter_inappwebview).

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `flutter_inappwebview`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Swift Package Manager only

This package is distributed exclusively as a Swift package: it ships a `Package.swift` and no
podspec. Your app must therefore have Swift Package Manager enabled:

```shell
flutter config --enable-swift-package-manager
```

Apps still building their iOS target with CocoaPods will fail to resolve this plugin.
See [Swift Package Manager for app developers](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers).