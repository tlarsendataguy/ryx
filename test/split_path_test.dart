import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/split_path.dart';

main(){
  test("Split path",(){
    var split = splitPath("C:\\Test");
    expect(split.length, equals(3));
    expect(split[0].path, equals(""));
    expect(split[0].name, equals("root"));
    expect(split[1].path, equals("C:\\"));
    expect(split[1].name, equals("C:\\"));
    expect(split[2].path, equals("C:\\Test"));
    expect(split[2].name, equals("Test"));
  });

  test("Split root", (){
    var split = splitPath("C:\\");
    expect(split.length, equals(2));
    expect(split[0].path, equals(""));
    expect(split[0].name, equals("root"));
    expect(split[1].path, equals("C:\\"));
    expect(split[1].name, equals("C:\\"));
  });

  test("Split nothing", (){
    var split = splitPath("");
    expect(split.length, equals(1));
    expect(split[0].path, equals(""));
    expect(split[0].name, equals("root"));
  });
}