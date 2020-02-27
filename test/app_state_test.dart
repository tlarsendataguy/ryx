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

  test("Make selected files absolute", () async {
    var state = AppState(MockSuccessIo());
    state.selectExplorer('Some macro');
    var changed = await state.makeSelectionAbsolute();
    expect(changed.success, isTrue);
    expect(changed.value, equals(1));
  });

  test("Make all files absolute", () async {
    var state = AppState(MockSuccessIo());
    var changed = await state.makeAllAbsolute();
    expect(changed.success, isTrue);
    expect(changed.value, equals(2));
  });

  test("Make selected files relative", () async {
    var state = AppState(MockSuccessIo());
    state.selectExplorer('some macro');
    var changed = await state.makeSelectionRelative();
    expect(changed.success, isTrue);
    expect(changed.value, equals(3));
  });

  test("Make all files relative", () async {
    var state = AppState(MockSuccessIo());
    var changed = await state.makeAllRelative();
    expect(changed.success, isTrue);
    expect(changed.value, equals(4));
  });

  test("Rename files", () async {
    var state = AppState(MockSuccessIo());
    expect(
        state.currentDocument, emitsInOrder(['', '', 'Old File', 'New File']));
    await state.getProjectStructure('project');
    state.getDocumentStructure('Old File');
    state.selectExplorer('Old File');
    var response = await state.renameFiles(['Old File'],['New File']);
    expect(response.success, isTrue);
    expect(response.value.length, equals(40));
  });

  test("Select and deselect files/folders", () async {
    var state = AppState(MockSuccessIo());
    expect(state.hasSelectedExplorer, emitsInOrder([false, true,  false, true, false]));
    expect(state.allDeselected, emitsInOrder([null]));
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

  test("Move selected files",() async {
    var state = AppState(MockSuccessIo());
    expect(state.projectStructure, emitsInOrder([null, isNotNull, isNotNull]));

    await state.getProjectStructure('project');
    state.selectExplorerList(['blah1','blah2']);
    var response = await state.moveFiles('some\\other\\folder');
    expect(response.value.length, equals(40));
  });

  test("Rename folder",() async{
    var state = AppState(MockSuccessIo());
    expect(
        state.currentDocument, emitsInOrder(['', '', 'some\\other\\folder\\Something.yxmc', '']));
    expect(
      state.projectStructure, emitsInOrder([isNull,isNotNull,isNotNull]));

    await state.getProjectStructure('project');
    await state.getDocumentStructure('some\\other\\folder\\Something.yxmc');
    var response = await state.renameFolder('some\\other\\folder', 'stuff');
    expect(response.success, isTrue);
  });

  test("Rename root folder", () async {
    var state = AppState(MockSuccessIo());
    expect(state.currentProject, emitsInOrder(['','C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing', 'C:\\Users\\tlarsen\\Documents\\new root name']));

    await state.getProjectStructure('C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing');
    await state.renameFolder('C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing', 'new root name');
  });
}