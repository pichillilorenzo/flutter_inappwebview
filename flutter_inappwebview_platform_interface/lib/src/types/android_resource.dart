import 'package:flutter_inappwebview_internal_annotations/flutter_inappwebview_internal_annotations.dart';

import 'enum_method.dart';

part 'android_resource.g.dart';

///Class that represents an Android resource file.
@ExchangeableObject()
class AndroidResource_ {
  ///Android resource name.
  ///
  ///A list of available `android.R.drawable` can be found
  ///[here](https://developer.android.com/reference/android/R.drawable).
  ///
  ///A list of available `android.R.anim` can be found
  ///[here](https://developer.android.com/reference/android/R.anim).
  ///
  ///A list of available `androidx.appcompat.R.anim` can be found
  ///[here](https://android.googlesource.com/platform/frameworks/support/+/HEAD/appcompat/appcompat/src/main/res/anim/)
  ///(abc_*.xml files).
  ///In this case, [defPackage] must match your App Android package name.
  String name;

  ///Optional default resource type to find, if "type/" is not included in the name.
  ///Can be `null` to require an explicit type.
  ///
  ///Example: "anim"
  String? defType;

  ///Optional default package to find, if "package:" is not included in the name.
  ///Can be `null` to require an explicit package.
  ///
  ///Example: "android" if you want use resources from `android.R.`
  String? defPackage;

  AndroidResource_({required this.name, this.defType, this.defPackage});

  static AndroidResource_ anim({required String name, String? defPackage}) {
    return AndroidResource_(
      name: name,
      defType: "anim",
      defPackage: defPackage,
    );
  }

  static AndroidResource_ layout({required String name, String? defPackage}) {
    return AndroidResource_(
      name: name,
      defType: "layout",
      defPackage: defPackage,
    );
  }

  static AndroidResource_ id({required String name, String? defPackage}) {
    return AndroidResource_(name: name, defType: "id", defPackage: defPackage);
  }

  static AndroidResource_ drawable({required String name, String? defPackage}) {
    return AndroidResource_(
      name: name,
      defType: "drawable",
      defPackage: defPackage,
    );
  }
}
