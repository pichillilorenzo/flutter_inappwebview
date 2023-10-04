<div align="center">

# Flutter InAppWebView Plugin [![Share on Twitter](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Flutter%20InAppBrowser%20plugin!&url=https://github.com/pichillilorenzo/flutter_inappwebview&hashtags=flutter,flutterio,dart,dartlang,webview) [![Share on Facebook](https://img.shields.io/badge/share-facebook-blue.svg?longCache=true&style=flat&colorB=%234267b2)](https://www.facebook.com/sharer/sharer.php?u=https%3A//github.com/pichillilorenzo/flutter_inappwebview)

![InAppWebView-logo](https://user-images.githubusercontent.com/5956938/195422744-bdcfed16-73f0-4bc9-94ab-ecf10771a1c4.png)

<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-73-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

[![Pub](https://img.shields.io/pub/v/flutter_inappwebview?include_prereleases)](https://pub.dartlang.org/packages/flutter_inappwebview)
[![Pub Points](https://img.shields.io/pub/points/flutter_inappwebview)](https://pub.dev/packages/flutter_inappwebview/score)
[![Pub Popularity](https://img.shields.io/pub/popularity/flutter_inappwebview)](https://pub.dev/packages/flutter_inappwebview/score)
[![Pub Likes](https://img.shields.io/pub/likes/flutter_inappwebview)](https://pub.dev/packages/flutter_inappwebview/score)
[![Awesome Flutter](https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square)](https://stackoverflow.com/questions/tagged/flutter-inappwebview)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](/LICENSE)

[![Donate to this project](https://img.shields.io/badge/support-donate-yellow.svg)](https://inappwebview.dev/donate/)
[![GitHub forks](https://img.shields.io/github/forks/pichillilorenzo/flutter_inappwebview?style=social)](https://github.com/pichillilorenzo/flutter_inappwebview)
[![GitHub stars](https://img.shields.io/github/stars/pichillilorenzo/flutter_inappwebview?style=social)](https://github.com/pichillilorenzo/flutter_inappwebview)

A Flutter plugin that allows you to add an inline webview, to use an headless webview, and to open an in-app browser window.

</div>

## New Version 6.x.x is OUT NOW!

Migrating from version `5.x.x` is easy! Follow the online [Migration guide](https://inappwebview.dev/docs/migration-guide).

## Articles/Resources

- [Official documentation: inappwebview.dev/docs](https://inappwebview.dev/docs/intro)
- Read the online [API Reference](https://pub.dartlang.org/documentation/flutter_inappwebview/latest/) to get the **full API documentation**.
- [Official blog: inappwebview.dev/blog](https://inappwebview.dev/blog/)
- Find open source projects on the [Official Showcase page: inappwebview.dev/showcase](https://inappwebview.dev/showcase/)
- Check the [flutter_inappwebview_examples](https://github.com/pichillilorenzo/flutter_inappwebview_examples) repository for project examples
- Check the [example/integration_test/webview_flutter_test.dart](https://github.com/pichillilorenzo/flutter_inappwebview/blob/master/example/integration_test/webview_flutter_test.dart) file for other code examples
- [Flutter Browser App](https://github.com/pichillilorenzo/flutter_browser_app): A Full-Featured Mobile Browser App (such as the Google Chrome mobile browser) created using Flutter and the features offered by the flutter_inappwebview plugin

## Showcase - Who use it

Check the [Showcase](https://inappwebview.dev/showcase/) page to see an open list of Apps built with **Flutter** and **Flutter InAppWebView**.

#### Are you using the **Flutter InAppWebView** plugin and would you like to add your App there?

Send a submission request to the [Submit App](https://inappwebview.dev/submit-app/) page!

## Requirements

- Dart sdk: ">=2.15.0 <4.0.0"
- Flutter: ">=3.0.0"
- Android: `minSdkVersion 19` and add support for `androidx` (see [AndroidX Migration](https://docs.flutter.dev/development/platform-integration/android/androidx-migration) to migrate an existing app)
- iOS 9.0+: `--ios-language swift`, Xcode version `>= 14.3`
- MacOS 10.11+: Xcode version `>= 14.3`

## Installation

Add `flutter_inappwebview` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

### Installation - Web support

To make it work properly on the Web platform, you need to add the `web_support.js` file inside the `<head>` of your `web/index.html` file:

```html
<head>
    <!-- ... -->
    <script type="application/javascript" src="/assets/packages/flutter_inappwebview/assets/web/web_support.js" defer></script>
    <!-- ... -->
</head>
```  

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
      <td align="center" valign="top" width="14.28%"><a href="https://blog.alexv525.com/"><img src="https://avatars.githubusercontent.com/u/15884415?v=4?s=100" width="100px;" alt="Alex Li"/><br /><sub><b>Alex Li</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=AlexV525" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/crazecoder"><img src="https://avatars.githubusercontent.com/u/18387906?v=4?s=100" width="100px;" alt="1/2"/><br /><sub><b>1/2</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=crazecoder" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cbodin"><img src="https://avatars.githubusercontent.com/u/220255?v=4?s=100" width="100px;" alt="Christofer Bodin"/><br /><sub><b>Christofer Bodin</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=cbodin" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/matthewlloyd"><img src="https://avatars.githubusercontent.com/u/2041996?v=4?s=100" width="100px;" alt="Matthew Lloyd"/><br /><sub><b>Matthew Lloyd</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=matthewlloyd" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/carloserazo47"><img src="https://avatars.githubusercontent.com/u/83635384?v=4?s=100" width="100px;" alt="C E"/><br /><sub><b>C E</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=carloserazo47" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/robsonmeemo"><img src="https://avatars.githubusercontent.com/u/47990393?v=4?s=100" width="100px;" alt="Robson Araujo"/><br /><sub><b>Robson Araujo</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=robsonmeemo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ryanhz"><img src="https://avatars.githubusercontent.com/u/1142612?v=4?s=100" width="100px;" alt="Ryan"/><br /><sub><b>Ryan</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=ryanhz" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://codeeagle.github.io/"><img src="https://avatars.githubusercontent.com/u/2311352?v=4?s=100" width="100px;" alt="CodeEagle"/><br /><sub><b>CodeEagle</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=CodeEagle" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tneotia"><img src="https://avatars.githubusercontent.com/u/50850142?v=4?s=100" width="100px;" alt="Tanay Neotia"/><br /><sub><b>Tanay Neotia</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=tneotia" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/panndoraBoo"><img src="https://avatars.githubusercontent.com/u/8928207?v=4?s=100" width="100px;" alt="Jamie Joost"/><br /><sub><b>Jamie Joost</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=panndoraBoo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://deandreamatias.com/"><img src="https://avatars.githubusercontent.com/u/21011641?v=4?s=100" width="100px;" alt="Matias de Andrea"/><br /><sub><b>Matias de Andrea</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=deandreamatias" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://blog.csdn.net/j550341130"><img src="https://avatars.githubusercontent.com/u/17899073?v=4?s=100" width="100px;" alt="YouCii"/><br /><sub><b>YouCii</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=YouCii" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cutzmf"><img src="https://avatars.githubusercontent.com/u/1662033?v=4?s=100" width="100px;" alt="Salnikov Sergey"/><br /><sub><b>Salnikov Sergey</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=cutzmf" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/a00012025"><img src="https://avatars.githubusercontent.com/u/12824216?v=4?s=100" width="100px;" alt="Po-Jui Chen"/><br /><sub><b>Po-Jui Chen</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=a00012025" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Manuito83"><img src="https://avatars.githubusercontent.com/u/4816367?v=4?s=100" width="100px;" alt="Manuito"/><br /><sub><b>Manuito</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Manuito83" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/setcy"><img src="https://avatars.githubusercontent.com/u/86180691?v=4?s=100" width="100px;" alt="setcy"/><br /><sub><b>setcy</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=setcy" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/EArminjon2"><img src="https://avatars.githubusercontent.com/u/92172436?v=4?s=100" width="100px;" alt="EArminjon"/><br /><sub><b>EArminjon</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=EArminjon2" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/ashank-bharati-497989127/"><img src="https://avatars.githubusercontent.com/u/22197948?v=4?s=100" width="100px;" alt="Ashank Bharati"/><br /><sub><b>Ashank Bharati</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=ashank96" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://dart.art/"><img src="https://avatars.githubusercontent.com/u/1755207?v=4?s=100" width="100px;" alt="Michael Chow"/><br /><sub><b>Michael Chow</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=chownation" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/RodXander"><img src="https://avatars.githubusercontent.com/u/23609784?v=4?s=100" width="100px;" alt="Osvaldo Saez"/><br /><sub><b>Osvaldo Saez</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=RodXander" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/rsydor"><img src="https://avatars.githubusercontent.com/u/79581663?v=4?s=100" width="100px;" alt="rsydor"/><br /><sub><b>rsydor</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=rsydor" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/hoanglm4"><img src="https://avatars.githubusercontent.com/u/7067757?v=4?s=100" width="100px;" alt="Le Minh Hoang"/><br /><sub><b>Le Minh Hoang</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=hoanglm4" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Miiha"><img src="https://avatars.githubusercontent.com/u/3897167?v=4?s=100" width="100px;" alt="Michael Kao"/><br /><sub><b>Michael Kao</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Miiha" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cloudygeek"><img src="https://avatars.githubusercontent.com/u/6059542?v=4?s=100" width="100px;" alt="cloudygeek"/><br /><sub><b>cloudygeek</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=cloudygeek" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/chreck"><img src="https://avatars.githubusercontent.com/u/8030398?v=4?s=100" width="100px;" alt="Christoph Eck"/><br /><sub><b>Christoph Eck</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=chreck" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Ser1ous"><img src="https://avatars.githubusercontent.com/u/4497968?v=4?s=100" width="100px;" alt="Ser1ous"/><br /><sub><b>Ser1ous</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Ser1ous" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://spacelaunchnow.me/"><img src="https://avatars.githubusercontent.com/u/4519230?v=4?s=100" width="100px;" alt="Caleb Jones"/><br /><sub><b>Caleb Jones</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=ItsCalebJones" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://sungazer.io/"><img src="https://avatars.githubusercontent.com/u/6215122?v=4?s=100" width="100px;" alt="Saverio Murgia"/><br /><sub><b>Saverio Murgia</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=savy-91" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/tranductam2802"><img src="https://avatars.githubusercontent.com/u/4957579?v=4?s=100" width="100px;" alt="Trần Đức Tâm"/><br /><sub><b>Trần Đức Tâm</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=tranductam2802" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://pcqpcq.me/"><img src="https://avatars.githubusercontent.com/u/1411571?v=4?s=100" width="100px;" alt="Joker"/><br /><sub><b>Joker</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=pcqpcq" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/ycv005/"><img src="https://avatars.githubusercontent.com/u/26734819?v=4?s=100" width="100px;" alt="Yash Chandra Verma"/><br /><sub><b>Yash Chandra Verma</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=ycv005" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/arneke"><img src="https://avatars.githubusercontent.com/u/425235?v=4?s=100" width="100px;" alt="Arne Kepp"/><br /><sub><b>Arne Kepp</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=arneke" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://omralcrt.github.io/"><img src="https://avatars.githubusercontent.com/u/12418327?v=4?s=100" width="100px;" alt="Ömral Cörüt"/><br /><sub><b>Ömral Cörüt</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=omralcrt" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/albatrosify"><img src="https://avatars.githubusercontent.com/u/64252708?v=4?s=100" width="100px;" alt="LrdHelmchen"/><br /><sub><b>LrdHelmchen</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=albatrosify" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://ungapps.com/"><img src="https://avatars.githubusercontent.com/u/8141036?v=4?s=100" width="100px;" alt="Steven Gunanto"/><br /><sub><b>Steven Gunanto</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=gunantosteven" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://schlau.bi/"><img src="https://avatars.githubusercontent.com/u/16060205?v=4?s=100" width="100px;" alt="Michael Rittmeister"/><br /><sub><b>Michael Rittmeister</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=DRSchlaubi" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://aakira.app/"><img src="https://avatars.githubusercontent.com/u/3386962?v=4?s=100" width="100px;" alt="Akira Aratani"/><br /><sub><b>Akira Aratani</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=AAkira" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Doflatango"><img src="https://avatars.githubusercontent.com/u/3091033?v=4?s=100" width="100px;" alt="Doflatango"/><br /><sub><b>Doflatango</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Doflatango" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Eddayy"><img src="https://avatars.githubusercontent.com/u/17043852?v=4?s=100" width="100px;" alt="Edmund Tay"/><br /><sub><b>Edmund Tay</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Eddayy" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://andreidiaconu.com/"><img src="https://avatars.githubusercontent.com/u/1402046?v=4?s=100" width="100px;" alt="Andrei Diaconu"/><br /><sub><b>Andrei Diaconu</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=andreidiaconu" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/plateaukao"><img src="https://avatars.githubusercontent.com/u/4084738?v=4?s=100" width="100px;" alt="Daniel Kao"/><br /><sub><b>Daniel Kao</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=plateaukao" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/xtyxtyx"><img src="https://avatars.githubusercontent.com/u/15033141?v=4?s=100" width="100px;" alt="xuty"/><br /><sub><b>xuty</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=xtyxtyx" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://bieker.ninja/"><img src="https://avatars.githubusercontent.com/u/818880?v=4?s=100" width="100px;" alt="Ben Bieker"/><br /><sub><b>Ben Bieker</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=wwwdata" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/phamnhuvu-dev"><img src="https://avatars.githubusercontent.com/u/22906656?v=4?s=100" width="100px;" alt="Phạm Như Vũ"/><br /><sub><b>Phạm Như Vũ</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=phamnhuvu-dev" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/SebastienBtr"><img src="https://avatars.githubusercontent.com/u/18089010?v=4?s=100" width="100px;" alt="SebastienBtr"/><br /><sub><b>SebastienBtr</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=SebastienBtr" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/fattiger00"><img src="https://avatars.githubusercontent.com/u/38494401?v=4?s=100" width="100px;" alt="NeZha"/><br /><sub><b>NeZha</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=fattiger00" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/klydra"><img src="https://avatars.githubusercontent.com/u/40038209?v=4?s=100" width="100px;" alt="Jan Klinge"/><br /><sub><b>Jan Klinge</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=klydra" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/PauloDurrerMelo"><img src="https://avatars.githubusercontent.com/u/29310557?v=4?s=100" width="100px;" alt="PauloDurrerMelo"/><br /><sub><b>PauloDurrerMelo</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=PauloDurrerMelo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/benmeemo"><img src="https://avatars.githubusercontent.com/u/47991706?v=4?s=100" width="100px;" alt="benmeemo"/><br /><sub><b>benmeemo</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=benmeemo" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cinos1"><img src="https://avatars.githubusercontent.com/u/19343437?v=4?s=100" width="100px;" alt="cinos"/><br /><sub><b>cinos</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=cinos1" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://xraph.com/"><img src="https://avatars.githubusercontent.com/u/11243590?v=4?s=100" width="100px;" alt="Rex Raphael"/><br /><sub><b>Rex Raphael</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=juicycleff" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Sense545"><img src="https://avatars.githubusercontent.com/u/769406?v=4?s=100" width="100px;" alt="Jan Henrik Høiland"/><br /><sub><b>Jan Henrik Høiland</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Sense545" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/igtm"><img src="https://avatars.githubusercontent.com/u/6331737?v=4?s=100" width="100px;" alt="Iguchi Tomokatsu"/><br /><sub><b>Iguchi Tomokatsu</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=igtm" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://uekoetter.dev/"><img src="https://avatars.githubusercontent.com/u/1270149?v=4?s=100" width="100px;" alt="Jonas Uekötter"/><br /><sub><b>Jonas Uekötter</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=ueman" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/emakar"><img src="https://avatars.githubusercontent.com/u/7767193?v=4?s=100" width="100px;" alt="emakar"/><br /><sub><b>emakar</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=emakar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://weibo.com/magicrolan"><img src="https://avatars.githubusercontent.com/u/671431?v=4?s=100" width="100px;" alt="liasica"/><br /><sub><b>liasica</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=liasica" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/addie9000"><img src="https://avatars.githubusercontent.com/u/2036910?v=4?s=100" width="100px;" alt="Eiichiro Adachi"/><br /><sub><b>Eiichiro Adachi</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=addie9000" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/kamilpowalowski"><img src="https://avatars.githubusercontent.com/u/83073?v=4?s=100" width="100px;" alt="Kamil Powałowski"/><br /><sub><b>Kamil Powałowski</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=kamilpowalowski" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/akioyamamoto1977"><img src="https://avatars.githubusercontent.com/u/429219?v=4?s=100" width="100px;" alt="Akio Yamamoto"/><br /><sub><b>Akio Yamamoto</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=akioyamamoto1977" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mohenaxiba"><img src="https://avatars.githubusercontent.com/u/7977540?v=4?s=100" width="100px;" alt="mohenaxiba"/><br /><sub><b>mohenaxiba</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=mohenaxiba" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.acidic.co.nz"><img src="https://avatars.githubusercontent.com/u/1319813?v=4?s=100" width="100px;" alt="Ben Anderson"/><br /><sub><b>Ben Anderson</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=bagedevimo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/daanporon"><img src="https://avatars.githubusercontent.com/u/71901?v=4?s=100" width="100px;" alt="Daan Poron"/><br /><sub><b>Daan Poron</b></sub></a><br /><a href="#security-daanporon" title="Security">🛡️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://yuki0311.com"><img src="https://avatars.githubusercontent.com/u/34892635?v=4?s=100" width="100px;" alt="ふぁ"/><br /><sub><b>ふぁ</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=fa0311" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/perffecto"><img src="https://avatars.githubusercontent.com/u/2116618?v=4?s=100" width="100px;" alt="perffecto"/><br /><sub><b>perffecto</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=perffecto" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/chandra-abdul-fattah"><img src="https://avatars.githubusercontent.com/u/16184998?v=4?s=100" width="100px;" alt="Chandra Abdul Fattah"/><br /><sub><b>Chandra Abdul Fattah</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=chandrabezzo" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.bebilica.rs/"><img src="https://avatars.githubusercontent.com/u/41632269?v=4?s=100" width="100px;" alt="Aleksandar Lugonja"/><br /><sub><b>Aleksandar Lugonja</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=LugonjaAleksandar" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.hera.cc"><img src="https://avatars.githubusercontent.com/u/534840?v=4?s=100" width="100px;" alt="Alexandre Richonnier"/><br /><sub><b>Alexandre Richonnier</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=heralight" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Sunbreak"><img src="https://avatars.githubusercontent.com/u/7928961?v=4?s=100" width="100px;" alt="Sunbreak"/><br /><sub><b>Sunbreak</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Sunbreak" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/cslee"><img src="https://avatars.githubusercontent.com/u/590752?v=4?s=100" width="100px;" alt="Eric Lee"/><br /><sub><b>Eric Lee</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=cslee" title="Documentation">📖</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/KhatibFX"><img src="https://avatars.githubusercontent.com/u/5616640?v=4?s=100" width="100px;" alt="KhatibFX"/><br /><sub><b>KhatibFX</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=KhatibFX" title="Code">💻</a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://www.guide.inc"><img src="https://avatars.githubusercontent.com/u/106543148?v=4?s=100" width="100px;" alt="Guide.inc"/><br /><sub><b>Guide.inc</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=guide-flutter" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/Nirajn2311"><img src="https://avatars.githubusercontent.com/u/36357875?v=4?s=100" width="100px;" alt="Niraj Nandish"/><br /><sub><b>Niraj Nandish</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=Nirajn2311" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/nesquikm"><img src="https://avatars.githubusercontent.com/u/3867874?v=4?s=100" width="100px;" alt="nesquikm"/><br /><sub><b>nesquikm</b></sub></a><br /><a href="https://github.com/pichillilorenzo/flutter_inappwebview/commits?author=nesquikm" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
