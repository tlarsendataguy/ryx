import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/communicator.dart';
import 'package:ryx_gui/communicator_data.dart';
import 'mock_io.dart';

main(){
  var validIo = MockSuccessIo();
  var badIo = MockInvalidIo();

  test("browse folders",() async {
    var communicator = Communicator(validIo);
    var response = await communicator.browseFolder('');
    expect(response.success, isTrue);
    expect(response.error, equals(''));
    expect(response.value.length, equals(2));
    expect(response.value[0], equals('C:\\'));
    expect(response.value[1], equals('D:\\'));
  });

  test("browse folders with invalid returned json", () async{
    var communicator = Communicator(badIo);
    var response = await communicator.browseFolder('');
    expectParsingDataError(response);
  });

  test("get project structure",() async{
    var communicator = Communicator(validIo);
    var response = await communicator.getProjectStructure('');
    expect(response.success, isTrue);
    expect(response.error, equals(''));
    expect(response.value.path, equals("C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing"));
    expect(response.value.folders.length, equals(1));
    expect(response.value.docs.length, equals(3));
    expect(response.value.folders[0].path, equals("C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing\\macros"));
    expect(response.value.folders[0].folders.length, equals(0));
    expect(response.value.folders[0].docs.length, equals(1));
  });

  test("get project structure with invalid returned json", () async{
    var communicator = Communicator(badIo);
    var response = await communicator.getProjectStructure('');
    expectParsingDataError(response);
  });

  test("get document structure",() async{
    var communicator = Communicator(validIo);
    var response = await communicator.getDocumentStructure('', '');
    expect(response.success, isTrue);
    expect(response.error, equals(''));
    expect(response.value.nodes.length, equals(14));
    expect(response.value.nodes[0].toolId, equals(1));
    expect(response.value.nodes[0].x, equals(54));
    expect(response.value.nodes[0].y, equals(54));
    expect(response.value.nodes[0].width, equals(60));
    expect(response.value.nodes[0].height, equals(60));
    expect(response.value.nodes[0].plugin, equals('AlteryxBasePluginsGui.TextInput.TextInput'));
    expect(response.value.nodes[0].storedMacro, equals(''));
    expect(response.value.nodes[0].foundMacro, equals(''));
    expect(response.value.nodes[0].category, equals('Tool'));
    expect(response.value.conns.length, equals(10));
    expect(response.value.conns[0].name, equals(''));
    expect(response.value.conns[0].fromId, equals(1));
    expect(response.value.conns[0].fromAnchor, equals('Output'));
    expect(response.value.conns[0].toId, equals(6));
    expect(response.value.conns[0].toAnchor, equals('Left'));
  });

  test("get document structure with invalid returned json", () async{
    var communicator = Communicator(badIo);
    var response = await communicator.getDocumentStructure('','');
    expectParsingDataError(response);
  });
}


void expectParsingDataError(Response response){
  expect(response.success, isFalse);
  expect(response.error, equals('Error parsing data returned from webserver'));
  expect(response.value, isNull);
}