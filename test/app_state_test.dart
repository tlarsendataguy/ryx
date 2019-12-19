import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/app_state.dart';
import 'mock_io.dart';

main(){
  test("Browse folder",() async {
    var state = AppState(MockSuccessIo());
    var error = await state.browseFolder("");
    expect(error, equals(""));
    expect(state.folders, emits(["C:\\","D:\\"]));
    expect(state.currentFolder, emits(""));

    await state.browseFolder("C:\\");
    expect(state.currentFolder, emits("C:\\"));
  });

  test("Browse folder error", () async {
    var state = AppState(MockInvalidIo());
    var error = await state.browseFolder("");
    expect(error, isNot(equals("")));
    expect(state.folders, emits([]));
  });
}