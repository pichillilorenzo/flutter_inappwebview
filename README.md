# Flutter InAppWebView Plugin [![Share on Twitter](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Flutter%20InAppBrowser%20plugin!&url=https://github.com/pichillilorenzo/flutter_inappwebview&hashtags=flutter,flutterio,dart,dartlang,webview) [![Share on Facebook](https://img.shields.io/badge/share-facebook-blue.svg?longCache=true&style=flat&colorB=%234267b2)](https://www.facebook.com/sharer/sharer.php?u=https%3A//github.com/pichillilorenzo/flutter_inappwebview)
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-10-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

[![Pub](https://img.shields.io/pub/v/flutter_inappwebview.svg)](https://pub.dartlang.org/packages/flutter_inappwebview)
[![pub points](https://badges.bar/flutter_inappwebview/pub%20points)](https://pub.dev/packages/flutter_inappwebview/score)
[![popularity](https://badges.bar/flutter_inappwebview/popularity)](https://pub.dev/packages/flutter_inappwebview/score)
[![likes](https://badges.bar/flutter_inappwebview/likes)](https://pub.dev/packages/flutter_inappwebview/score)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter-inappwebview)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](/LICENSE)

[![Donate to this project](https://img.shields.io/badge/support-donate-yellow.svg)](https://inappwebview.dev/donate/)
[![GitHub contributors](https://img.shields.io/github/contributors/pichillilorenzo/flutter_inappwebview)](https://github.com/pichillilorenzo/flutter_inappwebview/graphs/contributors)
[![GitHub forks](https://img.shields.io/github/forks/pichillilorenzo/flutter_inappwebview?style=social)](https://github.com/pichillilorenzo/flutter_inappwebview)
[![GitHub stars](https://img.shields.io/github/stars/pichillilorenzo/flutter_inappwebview?style=social)](https://github.com/pichillilorenzo/flutter_inappwebview)


![InAppWebView-logo](https://user-images.githubusercontent.com/5956938/110180687-8751f480-7e0a-11eb-89cc-d62f85c148cb.png)

A Flutter plugin that allows you to add an inline webview, to use an headless webview, and to open an in-app browser window.

## Articles/Resources

- [Official documentation: inappwebview.dev/docs](https://inappwebview.dev/docs/)
- Read the online [API Reference](https://pub.dartlang.org/documentation/flutter_inappwebview/latest/) to get the **full API documentation**.
- [Official blog: inappwebview.dev/blog](https://inappwebview.dev/blog/)
- Find open source projects on the [Official Showcase page: inappwebview.dev/showcase](https://inappwebview.dev/showcase/)
- Check the [example/integration_test/webview_flutter_test.dart](https://github.com/pichillilorenzo/flutter_inappwebview/blob/master/example/integration_test/webview_flutter_test.dart) file for other code examples
- [Flutter Browser App](https://github.com/pichillilorenzo/flutter_browser_app): A Full-Featured Mobile Browser App (such as the Google Chrome mobile browser) created using Flutter and the features offered by the flutter_inappwebview plugin

## Showcase - Who use it

Check the [Showcase](https://inappwebview.dev/showcase/) page to see an open list of Apps built with **Flutter** and **Flutter InAppWebView**.

#### Are you using the **Flutter InAppWebView** plugin and would you like to add your App there?

Send a submission request to the [Submit App](https://inappwebview.dev/submit-app/) page!

## Requirements

- Dart sdk: ">=2.14.0 <3.0.0"
- Flutter: ">=2.5.0"
- Android: `minSdkVersion 17` and add support for `androidx` (see [AndroidX Migration](https://flutter.dev/docs/development/androidx-migration) to migrate an existing app)
- iOS: `--ios-language swift`, Xcode version `>= 12`

## Installation

Add `flutter_inappwebview` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

## Main Classes Overview

* [InAppWebView](https://inappwebview.dev/docs/in-app-webview/basic-usage/): Flutter Widget for adding an inline native WebView integrated into the flutter widget tree.
* [ContextMenu](https://inappwebview.dev/docs/context-menu/basic-usage/): This class represents the WebView context menu.
* [HeadlessInAppWebView](https://inappwebview.dev/docs/headless-in-app-webview/basic-usage/): Class that represents a WebView in headless mode. It can be used to run a WebView in background without attaching an InAppWebView to the widget tree.
* [InAppBrowser](https://inappwebview.dev/docs/in-app-browser/basic-usage/): In-App Browser using native WebView.
* [ChromeSafariBrowser](https://inappwebview.dev/docs/chrome-safari-browser/basic-usage/): In-App Browser using Chrome Custom Tabs on Android / SFSafariViewController on iOS.
* [InAppLocalhostServer](https://inappwebview.dev/docs/in-app-localhost-server/basic-usage/): This class allows you to create a simple server on http://localhost:[port]/. The default port value is 8080.
* [CookieManager](https://inappwebview.dev/docs/cookie-manager/basic-usage/): This class implements a singleton object (shared instance) which manages the cookies used by WebView instances.
* [HttpAuthCredentialDatabase](https://inappwebview.dev/docs/http-auth-credential-database/basic-usage/): This class implements a singleton object (shared instance) that manages the shared HTTP auth credentials cache.
* [WebStorageManager](https://inappwebview.dev/docs/web-storage-manager/basic-usage/): This class implements a singleton object (shared instance) which manages the web storage used by WebView instances.

## Support

Did you find this plugin useful? Please consider to [make a donation](https://inappwebview.dev/donate/) to help improve it!

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center"><a href="https://blog.alexv525.com/"><img src="https://avatars.githubusercontent.com/u/15884415?v=4?s=100" width="100px;" alt="Alex Li"/><br /><sub><b>Alex Li</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=AlexV525" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/crazecoder"><img src="https://avatars.githubusercontent.com/u/18387906?v=4?s=100" width="100px;" alt="1/2"/><br /><sub><b>1/2</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=crazecoder" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/cbodin"><img src="https://avatars.githubusercontent.com/u/220255?v=4?s=100" width="100px;" alt="Christofer Bodin"/><br /><sub><b>Christofer Bodin</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=cbodin" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/matthewlloyd"><img src="https://avatars.githubusercontent.com/u/2041996?v=4?s=100" width="100px;" alt="Matthew Lloyd"/><br /><sub><b>Matthew Lloyd</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=matthewlloyd" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/carloserazo47"><img src="https://avatars.githubusercontent.com/u/83635384?v=4?s=100" width="100px;" alt="C E"/><br /><sub><b>C E</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=carloserazo47" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/robsonmeemo"><img src="https://avatars.githubusercontent.com/u/47990393?v=4?s=100" width="100px;" alt="Robson Araujo"/><br /><sub><b>Robson Araujo</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=robsonmeemo" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/ryanhz"><img src="https://avatars.githubusercontent.com/u/1142612?v=4?s=100" width="100px;" alt="Ryan"/><br /><sub><b>Ryan</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=ryanhz" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center"><a href="https://codeeagle.github.io/"><img src="https://avatars.githubusercontent.com/u/2311352?v=4?s=100" width="100px;" alt="CodeEagle"/><br /><sub><b>CodeEagle</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=CodeEagle" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/tneotia"><img src="https://avatars.githubusercontent.com/u/50850142?v=4?s=100" width="100px;" alt="Tanay Neotia"/><br /><sub><b>Tanay Neotia</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=tneotia" title="Code">💻</a></td>
      <td align="center"><a href="https://github.com/panndoraBoo"><img src="https://avatars.githubusercontent.com/u/8928207?v=4?s=100" width="100px;" alt="Jamie Joost"/><br /><sub><b>Jamie Joost</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=panndoraBoo" title="Code">💻</a></td>
    </tr>
  </tbody>
  <tfoot>
    
  </tfoot>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!