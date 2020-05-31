import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/communicator.dart';
import 'package:ryx_gui/project_macros_filter_manager.dart';

main(){
  test("Filter and unfilter macro name",(){
    var manager = ProjectMacrosFilterManager(projectMacros);
    expect(manager.macroNames, emitsInOrder([['Macro 1', 'Macro 2'], ['Macro 1'], ['Macro 1','Macro 2']]));
    manager.setMacroNameFilter('Macro 1');
    manager.setMacroNameFilter('');
    manager.dispose();
  });

  test("Filter and unfilter macro name using regex",(){
    var manager = ProjectMacrosFilterManager(projectMacros);
    expect(manager.macroNames, emitsInOrder([
      ['Macro 1', 'Macro 2'],
      ['Macro 1'],
      ['Macro 1','Macro 2'],
    ]));
    manager.setMacroNameFilter('.*1\$');
    manager.setMacroNameFilter('');
    manager.dispose();
  });

  test("Filter and unfilter found paths",(){
    var manager = ProjectMacrosFilterManager(projectMacros);
    expect(manager.foundPaths, emitsInOrder([
      ["", "c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "c:\\Macro 2.yxmc"],
      [""],
      ["", "c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "c:\\Macro 2.yxmc"],
    ]));
    manager.setFoundPathFilter('^\$');
    manager.setFoundPathFilter('');
    manager.dispose();
  });

  test("Filter and unfilter stored paths",(){
    var manager = ProjectMacrosFilterManager(projectMacros);
    expect(manager.storedPaths, emitsInOrder([
      ["c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "C:\\Macro 2.yxmc", "folder\\Macro 2.yxmc", "invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc", "Macro 1.yxmc"],
      ["invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc"],
      ["c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "C:\\Macro 2.yxmc", "folder\\Macro 2.yxmc", "invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc", "Macro 1.yxmc"],
    ]));
    manager.setStoredPathFilter('^invalid');
    manager.setStoredPathFilter('');
    manager.dispose();
  });

  test("Select and deselect macro name",(){
    var manager = ProjectMacrosFilterManager(projectMacros);
    expect(manager.selectedMacroName, isNull);
    expect(manager.selectedMacroNameStream, emitsInOrder([
      null,
      'Macro 1',
      null
    ]));
    expect(manager.macroNames, emitsInOrder([
      ['Macro 1', 'Macro 2'],
      ['Macro 1'],
      ['Macro 1', 'Macro 2'],
    ]));
    expect(manager.foundPaths, emitsInOrder([
      ["", "c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "c:\\Macro 2.yxmc"],
      ["", "c:\\Macro 1.yxmc"],
      ["", "c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "c:\\Macro 2.yxmc"],
    ]));
    expect(manager.storedPaths, emitsInOrder([
      ["c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "C:\\Macro 2.yxmc", "folder\\Macro 2.yxmc", "invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc", "Macro 1.yxmc"],
      ["c:\\Macro 1.yxmc", "invalid\\folder\\Macro 1.yxmc", "Macro 1.yxmc"],
      ["c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "C:\\Macro 2.yxmc", "folder\\Macro 2.yxmc", "invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc", "Macro 1.yxmc"],
    ]));
    manager.selectMacroName('Macro 1');
    expect(manager.selectedMacroName, equals("Macro 1"));
    manager.selectMacroName(null);
    expect(manager.selectedMacroName, isNull);
    manager.dispose();
  });

  test("Select and deselect found paths",(){
    var manager = ProjectMacrosFilterManager(projectMacros);
    expect(manager.selectedFoundPath, isNull);
    expect(manager.macroNames, emitsInOrder([
      ['Macro 1', 'Macro 2'],
      ['Macro 1'],
      ['Macro 1', 'Macro 2'],
    ]));
    expect(manager.foundPaths, emitsInOrder([
      ["", "c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "c:\\Macro 2.yxmc"],
      ["c:\\Macro 1.yxmc"],
      ["", "c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "c:\\Macro 2.yxmc"],
    ]));
    expect(manager.storedPaths, emitsInOrder([
      ["c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "C:\\Macro 2.yxmc", "folder\\Macro 2.yxmc", "invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc", "Macro 1.yxmc"],
      ["c:\\Macro 1.yxmc", "Macro 1.yxmc"],
      ["c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "C:\\Macro 2.yxmc", "folder\\Macro 2.yxmc", "invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc", "Macro 1.yxmc"],
    ]));
    manager.selectFoundPath("c:\\Macro 1.yxmc");
    expect(manager.selectedFoundPath, equals("c:\\Macro 1.yxmc"));
    manager.selectFoundPath(null);
    expect(manager.selectedFoundPath, isNull);
    manager.dispose();
  });

  test("Select and deselect stored paths",(){
    var manager = ProjectMacrosFilterManager(projectMacros);
    expect(manager.selectedStoredPath, isNull);
    expect(manager.macroNames, emitsInOrder([
      ['Macro 1', 'Macro 2'],
      ['Macro 1'],
      ['Macro 1', 'Macro 2'],
    ]));
    expect(manager.foundPaths, emitsInOrder([
      ["", "c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "c:\\Macro 2.yxmc"],
      ["c:\\Macro 1.yxmc"],
      ["", "c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "c:\\Macro 2.yxmc"],
    ]));
    expect(manager.storedPaths, emitsInOrder([
      ["c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "C:\\Macro 2.yxmc", "folder\\Macro 2.yxmc", "invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc", "Macro 1.yxmc"],
      ["Macro 1.yxmc"],
      ["c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "C:\\Macro 2.yxmc", "folder\\Macro 2.yxmc", "invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc", "Macro 1.yxmc"],
    ]));
    manager.selectStoredPath("Macro 1.yxmc");
    expect(manager.selectedStoredPath, equals("Macro 1.yxmc"));
    manager.selectStoredPath(null);
    expect(manager.selectedStoredPath, isNull);
    manager.dispose();
  });

  test("Selecting and filtering work together",(){
    var manager = ProjectMacrosFilterManager(projectMacros);
    expect(manager.storedPaths, emitsInOrder([
      ["c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "C:\\Macro 2.yxmc", "folder\\Macro 2.yxmc", "invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc", "Macro 1.yxmc"],
      ["c:\\Macro 1.yxmc", "invalid\\folder\\Macro 1.yxmc", "Macro 1.yxmc"],
      ["invalid\\folder\\Macro 1.yxmc", "Macro 1.yxmc"],
      ["folder\\Macro 2.yxmc", "invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc", "Macro 1.yxmc"],
      ["c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "C:\\Macro 2.yxmc", "folder\\Macro 2.yxmc", "invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc", "Macro 1.yxmc"],
    ]));
    manager.selectMacroName("Macro 1");
    manager.setStoredPathFilter("^[^cC][^:][^\\\\]");
    manager.selectMacroName(null);
    manager.setStoredPathFilter("");
    manager.dispose();
  });

  test("Invalid regex gets escaped",(){
    var manager = ProjectMacrosFilterManager(projectMacros);
    expect(()=>manager.setMacroNameFilter("this is invalid regex: [\\]"), returnsNormally);
    expect(()=>manager.setFoundPathFilter("this is invalid regex: [\\]"), returnsNormally);
    expect(()=>manager.setStoredPathFilter("this is invalid regex: [\\]"), returnsNormally);
  });

  test("select blank found macro",(){
    var manager = ProjectMacrosFilterManager(projectMacros);
    expect(manager.storedPaths, emitsInOrder([
      ["c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "C:\\Macro 2.yxmc", "folder\\Macro 2.yxmc", "invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc", "Macro 1.yxmc"],
      ["invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc"],
      ["c:\\folder\\Macro 2.yxmc", "c:\\Macro 1.yxmc", "C:\\Macro 2.yxmc", "folder\\Macro 2.yxmc", "invalid\\folder\\Macro 1.yxmc", "invalid\\folder\\Macro 2.yxmc", "Macro 1.yxmc"],
    ]));
    manager.selectFoundPath("");
    manager.selectFoundPath(null);
    manager.dispose();
  });
}

var projectMacros = <MacroNameInfo>[
  MacroNameInfo(
    name: "Macro 1",
    foundPaths: [
      MacroFoundInfo(
        foundPath: "c:\\Macro 1.yxmc",
        storedPaths: [
          MacroStoredInfo(
              storedPath: "Macro 1.yxmc",
              whereUsed: ["C:\\Something.yxmd"]
          ),
          MacroStoredInfo(
            storedPath: "c:\\Macro 1.yxmc",
            whereUsed: ["C:\\Something else.yxmd","C:\\La la la.yxmd"],
          ),
        ],
      ),
      MacroFoundInfo(
        foundPath: "",
        storedPaths: [
          MacroStoredInfo(
            storedPath: "invalid\\folder\\Macro 1.yxmc",
            whereUsed: ["C:\\Has Invalid Reference.yxmd"],
          ),
        ],
      ),
    ],
  ),
  MacroNameInfo(
    name: "Macro 2",
    foundPaths: [
      MacroFoundInfo(
        foundPath: "c:\\Macro 2.yxmc",
        storedPaths: [
          MacroStoredInfo(
            storedPath: "C:\\Macro 2.yxmc",
            whereUsed: ["C:\\Something.yxmd"],
          ),
        ],
      ),
      MacroFoundInfo(
        foundPath: "c:\\folder\\Macro 2.yxmc",
        storedPaths: [
          MacroStoredInfo(
            storedPath: "c:\\folder\\Macro 2.yxmc",
            whereUsed: ["C:\\La la la.yxmd"],
          ),
          MacroStoredInfo(
            storedPath: "folder\\Macro 2.yxmc",
            whereUsed: ["C:\\My workflow.yxmd"],
          )
        ],
      ),
      MacroFoundInfo(
        foundPath: "",
        storedPaths: [
          MacroStoredInfo(
            storedPath: "invalid\\folder\\Macro 2.yxmc",
            whereUsed: ["C:\\Has Invalid Reference.yxmd"],
          ),
        ],
      ),
    ],
  ),
];
