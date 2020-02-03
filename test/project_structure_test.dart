

import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/communicator_data.dart';

main(){
  test("toggle expanded",(){
    var structure = ProjectStructure(path: "Some folder",folders: [],docs: []);
    expect(structure.expanded, isFalse);
    structure.toggleExpanded();
    expect(structure.expanded, isTrue);
  });
}