// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'android_resource.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Class that represents an Android resource file.
class AndroidResource {
  ///Android resource name.
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
  AndroidResource({required this.name, this.defType, this.defPackage});

  ///Gets a possible [AndroidResource] instance from a [Map] value.
  static AndroidResource? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final instance = AndroidResource(
      name: map['name'],
      defType: map['defType'],
      defPackage: map['defPackage'],
    );
    return instance;
  }

  static AndroidResource anim({required String name, String? defPackage}) {
    return AndroidResource(name: name, defType: "anim", defPackage: defPackage);
  }

  static AndroidResource layout({required String name, String? defPackage}) {
    return AndroidResource(
        name: name, defType: "layout", defPackage: defPackage);
  }

  static AndroidResource id({required String name, String? defPackage}) {
    return AndroidResource(name: name, defType: "id", defPackage: defPackage);
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "defType": defType,
      "defPackage": defPackage,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'AndroidResource{name: $name, defType: $defType, defPackage: $defPackage}';
  }
}
