import 'package:test_gen/src/types/main.dart';
import 'package:test_gen/src/types/test_enum.dart';

void main() {
  TestClass test = TestClass(test1: "test1", test2: TestClass2(test1: ""), actionModeMenuItem: ActionModeMenuItem.MENU_ITEM_NONE);
}