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
    state.dispose();
  });

  test("Browse folder error", () async {
    var state = AppState(MockInvalidIo());
    var error = await state.browseFolder("");
    expect(error, isNot(equals("")));
    expect(state.folders, emits(null));
    state.dispose();
  });

  test("Clear current folder", () async {
    var state = AppState(MockSuccessIo());
    expect(state.folders, emitsInOrder([null, ["C:\\", "D:\\"], null]));
    expect(state.currentFolder, emitsInOrder(["", "C:\\", ""]));

    await state.browseFolder("C:\\");
    state.clearFolder();
    state.dispose();
  });

  test("Get project structure", () async {
    var state = AppState(MockSuccessIo());
    expect(state.currentProject, emitsInOrder([isNull, isNotNull]));
    expect(state.toolData, emitsInOrder([isNull, isNotNull]));
    expect(state.isLoadingProject, emitsInOrder([false, true, false]));
    expect(state.currentProjectMacros, emitsInOrder([isEmpty, isNotEmpty]));

    var error = await state.getProjectStructure("Blah");
    expect(error, equals(""));
    var project = await state.currentProject.firstWhere((
        project) => project.structure != null);
    expect(project.structure.expanded, isTrue);
    state.dispose();
  });

  test("Get project structure error", () async {
    var state = AppState(MockInvalidIo());
    expect(state.currentProject, emits(isNull));
    expect(state.isLoadingProject, emitsInOrder([false, true, false]));
    var error = await state.getProjectStructure("Blah");
    expect(error, isNot(equals("")));
    state.dispose();
  });

  test("Loading project clears current document", () async {
    var state = AppState(MockSuccessIo());
    expect(state.centerPage, emitsInOrder([CenterPage.MacrosInProject, CenterPage.SelectedWorkflow, CenterPage.MacrosInProject]));
    expect(state.currentDocument,
        emitsInOrder([isNull, isNull, isNotNull, isNull]));
    expect(state.whereUsed, emitsInOrder([
      [],
      [
        "C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing\\01 SETLEAF Equations Completed.yxmd"
      ],
      []
    ]));
    await state.getProjectStructure('project1');
    await state.getDocumentStructure("Blah");
    state.showSelectedWorkflow();
    await state.getProjectStructure('project2');
    state.dispose();
  });

  test("Get document structure", () async {
    var state = AppState(MockSuccessIo());
    expect(state.centerPage, emitsInOrder([CenterPage.MacrosInProject, CenterPage.SelectedWorkflow]));
    expect(state.currentDocument,
        emitsInOrder([isNull, isNull, isNotNull]));
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
    state.dispose();
  });

  test("Get document structure multiple times", () async {
    var state = AppState(MockSuccessIo());
    expect(state.currentDocument, emitsInOrder(
        [isNull, isNull, isNotNull, isNull, isNotNull]));
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
    state.dispose();
  });

  test("Get document structure error", () async {
    var state = AppState(MockValidProjectInvalidOthers());
    expect(state.currentDocument, emits(isNull));
    expect(state.whereUsed, emitsInOrder([[], []]));
    expect(state.isLoadingDocument, emitsInOrder([false, true, false]));
    expect(state.isLoadingWhereUsed, emitsInOrder([false, true, false]));
    await state.getProjectStructure("project");
    var error = await state.getDocumentStructure("Blah");
    print(error);
    expect(error, isNot(equals("")));
    state.dispose();
  });

  test("Get document structure without opening project", () async {
    var state = AppState(MockSuccessIo());
    expect(state.currentDocument, emits(isNull));
    var error = await state.getDocumentStructure("Blah");
    expect(error, isNot(equals("")));
    print(error);
    state.dispose();
  });

  test("Make selected files absolute", () async {
    var state = AppState(MockSuccessIo());
    expect(state.currentProjectMacros, emitsInOrder([isEmpty, isNotEmpty]));
    await state.getProjectStructure('project');
    state.selectExplorer('Some macro');
    var changed = await state.makeSelectionAbsolute();
    state.dispose();
    expect(changed.success, isTrue);
    expect(changed.value, equals(1));
    state.dispose();
  });

  test("Make all files absolute", () async {
    var state = AppState(MockSuccessIo());
    expect(state.currentProjectMacros, emitsInOrder([isEmpty, isNotEmpty]));
    await state.getProjectStructure('project');
    var changed = await state.makeAllAbsolute();
    expect(changed.success, isTrue);
    expect(changed.value, equals(2));
    state.dispose();
  });

  test("Make selected files relative", () async {
    var state = AppState(MockSuccessIo());
    expect(state.currentProjectMacros, emitsInOrder([isEmpty, isNotEmpty]));
    await state.getProjectStructure('project');
    state.selectExplorer('some macro');
    var changed = await state.makeSelectionRelative();
    expect(changed.success, isTrue);
    expect(changed.value, equals(3));
    state.dispose();
  });

  test("Make all files relative", () async {
    var state = AppState(MockSuccessIo());
    expect(state.currentProjectMacros, emitsInOrder([isEmpty, isNotEmpty]));
    await state.getProjectStructure('project');
    var changed = await state.makeAllRelative();
    expect(changed.success, isTrue);
    expect(changed.value, equals(4));
    state.dispose();
  });

  test("Rename files", () async {
    var state = AppState(MockSuccessIo());
    expect(
        state.currentDocument.map((s)=>s?.path), emitsInOrder([isNull, isNull, 'Old File', 'New File']));
    expect(state.currentProjectMacros, emitsInOrder([isEmpty, isNotEmpty, isNotEmpty]));
    await state.getProjectStructure('project');
    state.getDocumentStructure('Old File');
    state.selectExplorer('Old File');
    var response = await state.renameFiles(['Old File'],['New File']);
    expect(response.success, isTrue);
    expect(response.value.length, equals(40));
    state.dispose();
  });

  test("Select and deselect files/folders", () async {
    var state = AppState(MockSuccessIo());
    expect(state.hasSelectedExplorer, emitsInOrder([false, true,  false, true, false]));
    expect(state.allDeselected, emitsInOrder([null]));
    expect(state.selectedExplorer.length, equals(0));
    await state.getProjectStructure('project');
    state.selectExplorer('blah');
    expect(state.selectedExplorer.length, equals(1));
    state.deselectExplorer('blah');
    expect(state.selectedExplorer.length, equals(0));
    state.selectExplorer('blah2');
    expect(state.selectedExplorer.length, equals(1));
    state.deselectAllExplorer();
    expect(state.selectedExplorer.length, equals(0));
    state.dispose();
  });

  test("Opening project clears selected files/folders",() async {
    var state = AppState(MockSuccessIo());
    expect(state.hasSelectedExplorer, emitsInOrder([false, true,  false]));
    state.selectExplorer('blah');
    await state.getProjectStructure("project");
    expect(state.selectedExplorer.length, equals(0));
    state.dispose();
  });

  test("Select and deselect lists of files/folders", () async {
    var state = AppState(MockSuccessIo());
    expect(state.hasSelectedExplorer, emitsInOrder([false, true,  false]));
    expect(state.selectedExplorer.length, equals(0));
    state.selectExplorerList(['blah1','blah2']);
    expect(state.selectedExplorer.length, equals(2));
    state.deselectExplorerList(['blah1','blah2']);
    expect(state.selectedExplorer.length, equals(0));
    state.dispose();
  });

  test("Move selected files",() async {
    var state = AppState(MockSuccessIo());
    expect(state.currentProject, emitsInOrder([null, isNotNull, isNotNull]));
    expect(state.currentProjectMacros, emitsInOrder([isEmpty, isNotEmpty, isNotEmpty]));
    await state.getProjectStructure('project');
    state.selectExplorerList(['blah1','blah2']);
    var response = await state.moveFiles('some\\other\\folder');
    expect(response.value.length, equals(40));
    state.dispose();
  });

  test("Rename folder",() async{
    var state = AppState(MockSuccessIo());
    expect(
        state.currentDocument.map((s)=>s?.path), emitsInOrder([null, null, 'some\\other\\folder\\Something.yxmc', null]));
    expect(
      state.currentProject, emitsInOrder([isNull,isNotNull,isNotNull]));
    expect(state.currentProjectMacros, emitsInOrder([isEmpty, isNotEmpty, isNotEmpty]));

    await state.getProjectStructure('project');
    await state.getDocumentStructure('some\\other\\folder\\Something.yxmc');
    var response = await state.renameFolder('some\\other\\folder', 'stuff');
    expect(response.success, isTrue);
    state.dispose();
  });

  test("Rename root folder", () async {
    var state = AppState(MockSuccessIo());
    expect(state.currentProject.map((s)=>s?.path), emitsInOrder([null,'C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing', 'C:\\Users\\tlarsen\\Documents\\new root name']));

    await state.getProjectStructure('C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing');
    await state.renameFolder('C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing', 'new root name');
    state.dispose();
  });

  test("Change center page", () async {
    var state = AppState(MockSuccessIo());
    expect(state.centerPage, emitsInOrder([CenterPage.MacrosInProject, CenterPage.SelectedWorkflow, CenterPage.MacrosInProject]));
    state.showSelectedWorkflow();
    state.showMacrosInProject();
    state.dispose();
  });

  test("Close document", () async {
    var state = AppState(MockSuccessIo());
    expect(state.currentDocument, emitsInOrder([isNull, isNull, isNotNull, isNull]));
    expect(state.centerPage, emitsInOrder([CenterPage.MacrosInProject, CenterPage.SelectedWorkflow, CenterPage.MacrosInProject]));

    await state.getProjectStructure('project');
    await state.getDocumentStructure('document');
    state.closeDocument();
    state.dispose();
  });

  test("Batch update macro settings", () async {
    var state = AppState(MockSuccessIo());
    expect(state.currentProjectMacros, emitsInOrder([
      isEmpty,
      isNotEmpty,
      isNotEmpty,
    ]));

    await state.getProjectStructure('project');
    var error = await state.batchUpdateMacroSettings('macro', 'c:\\macro.yxmc', [], []);
    expect(error, equals(''));
    state.dispose();
  });
}