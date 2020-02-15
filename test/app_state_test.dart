import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/app_state.dart';
import 'mock_io.dart';

main() {
  test("Browse folder", () async {
    var state = AppState(MockSuccessIo());
    expect(state.folders,
        emitsInOrder([null, ["C:\\", "D:\\"], ["C:\\", "D:\\"]]));
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

  test("Clear current folder", () async {
    var state = AppState(MockSuccessIo());
    expect(state.folders, emitsInOrder([null, ["C:\\", "D:\\"], null]));
    expect(state.currentFolder, emitsInOrder(["", "C:\\", ""]));

    await state.browseFolder("C:\\");
    state.clearFolder();
  });

  test("Get project structure", () async {
    var state = AppState(MockSuccessIo());
    expect(state.projectStructure, emitsInOrder([isNull, isNotNull]));
    expect(state.currentProject, emitsInOrder([equals(""), equals("Blah")]));
    expect(state.toolData, emitsInOrder([isNull, isNotNull]));
    expect(state.isLoadingProject, emitsInOrder([false, true, false]));

    var error = await state.getProjectStructure("Blah");
    expect(error, equals(""));
    var structure = await state.projectStructure.firstWhere((
        structure) => structure != null);
    expect(structure.expanded, isTrue);
  });

  test("Get project structure error", () async {
    var state = AppState(MockInvalidIo());
    expect(state.currentProject, emits(""));
    expect(state.isLoadingProject, emitsInOrder([false, true, false]));
    var error = await state.getProjectStructure("Blah");
    expect(error, isNot(equals("")));
  });

  test("Loading project clears current document", () async {
    var state = AppState(MockSuccessIo());
    expect(state.documentStructure, emitsInOrder([isNull, isNotNull, isNull]));
    expect(state.currentDocument,
        emitsInOrder([equals(""), equals(""), equals("Blah"), equals("")]));
    expect(state.whereUsed, emitsInOrder([
      [],
      [
        "C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing\\01 SETLEAF Equations Completed.yxmd"
      ],
      []
    ]));
    await state.getProjectStructure('project1');
    await state.getDocumentStructure("Blah");
    await state.getProjectStructure('project2');
  });

  test("Get document structure", () async {
    var state = AppState(MockSuccessIo());
    expect(state.documentStructure, emitsInOrder([isNull, isNotNull]));
    expect(state.currentDocument,
        emitsInOrder([equals(""), equals(""), equals("Blah")]));
    expect(state.isLoadingDocument, emitsInOrder([false, true, false]));
    expect(state.whereUsed, emitsInOrder([
      [],
      [
        "C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing\\01 SETLEAF Equations Completed.yxmd"
      ]
    ]));
    expect(state.isLoadingWhereUsed, emitsInOrder([false, true, false]));

    await state.getProjectStructure("project");
    var error = await state.getDocumentStructure("Blah");
    expect(error, equals(""));
  });

  test("Get document structure multiple times", () async {
    var state = AppState(MockSuccessIo());
    expect(state.documentStructure, emitsInOrder([isNull, isNotNull]));
    expect(state.currentDocument, emitsInOrder(
        [equals(""), equals(""), equals("Blah"), equals(""), equals("Blah2")]));
    expect(state.isLoadingDocument,
        emitsInOrder([false, true, false, true, false]));
    expect(state.whereUsed, emitsInOrder([
      [],
      [
        "C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing\\01 SETLEAF Equations Completed.yxmd"
      ],
      [
        "C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing\\01 SETLEAF Equations Completed.yxmd"
      ]
    ]));
    expect(state.isLoadingWhereUsed,
        emitsInOrder([false, true, false, true, false]));

    await state.getProjectStructure("project");
    var error = await state.getDocumentStructure("Blah");
    expect(error, equals(""));
    error = await state.getDocumentStructure("Blah2");
    expect(error, equals(""));
  });

  test("Get document structure error", () async {
    var state = AppState(MockValidProjectInvalidOthers());
    expect(state.currentDocument, emits(""));
    expect(state.whereUsed, emitsInOrder([[], []]));
    expect(state.isLoadingDocument, emitsInOrder([false, true, false]));
    expect(state.isLoadingWhereUsed, emitsInOrder([false, true, false]));
    await state.getProjectStructure("project");
    var error = await state.getDocumentStructure("Blah");
    print(error);
    expect(error, isNot(equals("")));
  });

  test("Get document structure without opening project", () async {
    var state = AppState(MockSuccessIo());
    expect(state.currentDocument, emits(""));
    var error = await state.getDocumentStructure("Blah");
    expect(error, isNot(equals("")));
    print(error);
  });

  test("Make macro absolute", () async {
    var state = AppState(MockSuccessIo());
    var changed = await state.makeMacroAbsolute('some macro');
    expect(changed, equals(1));
  });

  test("Make all macros absolute", () async {
    var state = AppState(MockSuccessIo());
    var changed = await state.makeAllAbsolute();
    expect(changed, equals(2));
  });

  test("Make macro relative", () async {
    var state = AppState(MockSuccessIo());
    var changed = await state.makeMacroRelative('some macro');
    expect(changed, equals(3));
  });

  test("Make all macros relative", () async {
    var state = AppState(MockSuccessIo());
    var changed = await state.makeAllRelative();
    expect(changed, equals(4));
  });

  test("Rename file", () async {
    var state = AppState(MockSuccessIo());
    expect(
        state.currentDocument, emitsInOrder(['', '', 'Old File', 'New File']));
    await state.getProjectStructure('project');
    await state.getDocumentStructure('Old File');
    var error = await state.renameFile('New File');
    expect(error, equals(''));
  });

  test("Select and deselect files/folders", () async {
    var state = AppState(MockSuccessIo());
    expect(state.hasSelectedExplorer, emitsInOrder([false, true,  false, true, false]));
    expect(state.selectedExplorer.length, equals(0));
    state.selectExplorer('blah');
    expect(state.selectedExplorer.length, equals(1));
    state.deselectExplorer('blah');
    expect(state.selectedExplorer.length, equals(0));
    state.selectExplorer('blah2');
    expect(state.selectedExplorer.length, equals(1));
    state.deselectAllExplorer();
    expect(state.selectedExplorer.length, equals(0));
  });

  test("Opening project clears selected files/folders",() async {
    var state = AppState(MockSuccessIo());
    expect(state.hasSelectedExplorer, emitsInOrder([false, true,  false]));
    state.selectExplorer('blah');
    await state.getProjectStructure("project");
    expect(state.selectedExplorer.length, equals(0));
  });

  test("Select and deselect lists of files/folders", () async {
    var state = AppState(MockSuccessIo());
    expect(state.hasSelectedExplorer, emitsInOrder([false, true,  false]));
    expect(state.selectedExplorer.length, equals(0));
    state.selectExplorerList(['blah1','blah2']);
    expect(state.selectedExplorer.length, equals(2));
    state.deselectExplorerList(['blah1','blah2']);
    expect(state.selectedExplorer.length, equals(0));
  });
}