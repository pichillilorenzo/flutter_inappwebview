library test_gen;

import 'package:test_gen/src/types/test_class.dart';
import 'package:test_gen/src/test/test_class_2.dart';
import 'package:test_gen/src/types/test_enum.dart';

void main() {
  TestClass a = TestClass(test1: "test1", test2: TestClass2(test1: "test2"), actionModeMenuItem: ActionModeMenuItem.MENU_ITEM_NONE);
  a.toMap();
}