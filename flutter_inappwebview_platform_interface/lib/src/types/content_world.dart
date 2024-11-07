import 'enum_method.dart';

final _contentWorldNameRegExp = RegExp(r'[\s]');

///Class that represents an object that defines a scope of execution for JavaScript code and which you use to prevent conflicts between different scripts.
///
///**NOTE for iOS**: available on iOS 14.0+. This class represents the native [WKContentWorld](https://developer.apple.com/documentation/webkit/wkcontentworld) class.
///
///**NOTE for Android**: it will create and append an `<iframe>` HTML element with `id` attribute equals to `flutter_inappwebview_[name]`
///to the webpage's content that contains only the inline `<script>` HTML elements in order to define a new scope of execution for JavaScript code.
///Unfortunately, there isn't any other way to do it.
///There are some limitations:
///- for any [ContentWorld], except [ContentWorld.PAGE] (that is the webpage itself), if you need to access to the `window` or `document` global Object,
///you need to use `window.top` and `window.top.document` because the code runs inside an `<iframe>`;
///- also, the execution of the inline `<script>` could be blocked by the `Content-Security-Policy` header.
class ContentWorld {
  ///The name of a custom content world.
  ///It cannot contain space characters.
  final String name;

  ///Returns the custom content world with the specified name.
  ContentWorld.world({required this.name}) {
    // WINDOW-ID- is used internally by the plugin!
    assert(!this.name.startsWith("WINDOW-ID-") &&
        !this.name.contains(_contentWorldNameRegExp));
  }

  ///The default world for clients.
  static final ContentWorld DEFAULT_CLIENT =
      ContentWorld.world(name: "defaultClient");

  ///The content world for the current webpage’s content.
  ///This property contains the content world for scripts that the current webpage executes.
  ///Be careful when manipulating variables in this content world.
  ///If you modify a variable with the same name as one the webpage uses, you may unintentionally disrupt the normal operation of that page.
  static final ContentWorld PAGE = ContentWorld.world(name: "page");

  ///Gets a possible [ContentWorld] instance from a [Map] value.
  static ContentWorld? fromMap(Map<String, dynamic>? map,
      {EnumMethod? enumMethod}) {
    if (map == null) {
      return null;
    }
    return ContentWorld.world(name: map["name"]);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {"name": name};
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
