import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/app_state.dart';
import 'mock_io.dart';

main(){
  test("Browse folder",() async {
    var state = AppState(MockSuccessIo());
    expect(state.folders, emitsInOrder([null, ["C:\\","D:\\"], ["C:\\","D:\\"]]));
    expect(state.currentFolder, emitsInOrder(["", "C:\\"]));

    var error = await state.browseFolder("");
    expect(error, equals(""));

    await state.browseFolder("C:\\");
  });

  test("Browse folder error", () async {
    var state = AppState(MockInvalidIo());
    var error = await state.browseFolder("");
    expect(error, isNot(equals("")));
    expect(state.folders, emits(null));
  });

  test("Clear current folder",() async {
    var state = AppState(MockSuccessIo());
    expect(state.folders, emitsInOrder([null, ["C:\\","D:\\"], null]));
    expect(state.currentFolder, emitsInOrder(["","C:\\",""]));

    await state.browseFolder("C:\\");
    state.clearFolder();
  });

  test("Get project structure", () async {
    var state = AppState(MockSuccessIo());
    expect(state.projectStructure, emitsInOrder([isNull, isNotNull]));
    expect(state.currentProject, emitsInOrder([equals(""), equals("Blah")]));

    var error = await state.getProjectStructure("Blah");
    expect(error, equals(""));
  });

  test("Get project structure error", () async {
    var state = AppState(MockInvalidIo());
    expect(state.currentProject, emits(""));
    var error = await state.getProjectStructure("Blah");
    expect(error, isNot(equals("")));
  });
}