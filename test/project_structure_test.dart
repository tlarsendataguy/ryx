import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/communicator_data.dart';

main(){
  test("Toggle expanded",(){
    var structure = ProjectStructure(path: "Some folder",folders: [],docs: []);
    expect(structure.expanded, isFalse);
    structure.toggleExpanded();
    expect(structure.expanded, isTrue);
  });

  test("Rename file",(){
    var structure = generateSampleStructure();
    structure.renameFiles(["C:\\Library\\Folder1\\Doc1_1"], ["C:\\Library\\Folder1\\NewName"]);
    expect(structure.folders[0].docs[0].path, equals("C:\\Library\\Folder1\\Doc1_2"));
    expect(structure.folders[0].docs[1].path, equals("C:\\Library\\Folder1\\NewName"));
  });

  test("Move file", (){
    var structure = generateSampleStructure();
    structure.renameFiles(["C:\\Library\\Folder1\\Doc1_1"], ["C:\\Library\\Folder2\\Doc1_1"]);
    expect(structure.folders[0].docs.length, equals(1));
    expect(structure.folders[0].docs[0].path, equals("C:\\Library\\Folder1\\Doc1_2"));
    expect(structure.folders[1].docs.length, equals(3));
    expect(structure.folders[1].docs[0].path, equals("C:\\Library\\Folder2\\Doc1_1"));
    expect(structure.folders[1].docs[1].path, equals("C:\\Library\\Folder2\\Doc2_1"));
    expect(structure.folders[1].docs[2].path, equals("C:\\Library\\Folder2\\Doc2_2"));
  });

  test("Rename file that does not exist", (){
    var structure = generateSampleStructure();
    structure.renameFiles(["C:\\Library\\Folder1\\Blah blah"], ["C:\\Library\\Folder1\\NewName"]);
    expect(structure.folders[0].docs.length, equals(2));
    expect(structure.folders[1].docs.length, equals(2));
  });

  test("Stucture are not empty if they have docs",(){
    var structure = ProjectStructure(
      path: "C:\\Library",
      folders: [],
      docs: [
        ProjectStructureDoc(path: "C:\\Library\\SomeFile"),
      ],
    );
    expect(structure.isEmpty(), isFalse);
  });

  test("Structures are not empty if their folders contain docs",(){
    var structure = generateSampleStructure();
    expect(structure.isEmpty(), isFalse);
  });

  test("Rename folder in structure", () async {
    var structure = generateSampleStructure();
    structure.folders[0].folders.add(ProjectStructure(path: "C:\\Library\\Folder1\\Subfolder", folders: [], docs: []));
    var newStructure = structure.renameFolder("C:\\Library\\Folder1", "NewFolder");
    expect(newStructure.folders[1].path, equals("C:\\Library\\Folder2"));
    expect(newStructure.folders[0].path, equals("C:\\Library\\NewFolder"));
    expect(newStructure.folders[0].folders[0].path, equals("C:\\Library\\NewFolder\\Subfolder"));
    expect(newStructure.folders[0].docs[0].path, equals("C:\\Library\\NewFolder\\Doc1_1"));
    expect(newStructure.folders[0].docs[1].path, equals("C:\\Library\\NewFolder\\Doc1_2"));
  });
}

ProjectStructure generateSampleStructure(){
  return ProjectStructure(
    path: "C:\\Library",
    docs: [],
    folders: [
      ProjectStructure(
        path: "C:\\Library\\Folder1",
        docs: [
          ProjectStructureDoc(path: "C:\\Library\\Folder1\\Doc1_1"),
          ProjectStructureDoc(path: "C:\\Library\\Folder1\\Doc1_2"),
        ],
        folders: [],
      ),
      ProjectStructure(
        path: "C:\\Library\\Folder2",
        docs: [
          ProjectStructureDoc(path: "C:\\Library\\Folder2\\Doc2_1"),
          ProjectStructureDoc(path: "C:\\Library\\Folder2\\Doc2_2"),
        ],
        folders: [],
      ),
    ],
  );
}