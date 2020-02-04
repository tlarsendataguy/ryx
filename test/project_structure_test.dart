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
    structure.renameFile("C:\\Library\\Folder1\\Doc1_1", "C:\\Library\\Folder1\\NewName");
    expect(structure.folders[0].docs[0], equals("C:\\Library\\Folder1\\Doc1_2"));
    expect(structure.folders[0].docs[1], equals("C:\\Library\\Folder1\\NewName"));
  });

  test("Move file", (){
    var structure = generateSampleStructure();
    structure.renameFile("C:\\Library\\Folder1\\Doc1_1", "C:\\Library\\Folder2\\Doc1_1");
    expect(structure.folders[0].docs.length, equals(1));
    expect(structure.folders[0].docs[0], equals("C:\\Library\\Folder1\\Doc1_2"));
    expect(structure.folders[1].docs.length, equals(3));
    expect(structure.folders[1].docs[0], equals("C:\\Library\\Folder2\\Doc1_1"));
    expect(structure.folders[1].docs[1], equals("C:\\Library\\Folder2\\Doc2_1"));
    expect(structure.folders[1].docs[2], equals("C:\\Library\\Folder2\\Doc2_2"));
  });

  test("Rename file that does not exist", (){
    var structure = generateSampleStructure();
    structure.renameFile("C:\\Library\\Folder1\\Blah blah", "C:\\Library\\Folder1\\NewName");
    expect(structure.folders[0].docs.length, equals(2));
    expect(structure.folders[1].docs.length, equals(2));
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
          "C:\\Library\\Folder1\\Doc1_1",
          "C:\\Library\\Folder1\\Doc1_2",
        ],
        folders: [],
      ),
      ProjectStructure(
        path: "C:\\Library\\Folder2",
        docs: [
          "C:\\Library\\Folder2\\Doc2_1",
          "C:\\Library\\Folder2\\Doc2_2",
        ],
        folders: [],
      ),
    ],
  );
}