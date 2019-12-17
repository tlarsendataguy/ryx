import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/communicator.dart';
import 'package:ryx_gui/communicator_data.dart';

class MockSuccessIo extends Io {
  Future<String> browseFolder(String root) async {
    return '{"Success":true,"Data":["C:\\\\","D:\\\\"]}';
  }
  Future<String> getProjectStructure(String project) async {
    return '{"Success":true,"Data":{"Path":"C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing","Folders":[{"Path":"C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing\\\\macros","Folders":[],"Docs":["C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing\\\\macros\\\\Tag with Sets.yxmc"]}],"Docs":["C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing\\\\01 SETLEAF Equations Completed.yxmd","C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing\\\\Calculate Filter Expression.yxmc","C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing\\\\new.yxmc"]}}';
  }
  Future<String> getDocumentStructure(String project, String document) async {
    return '{"Success":true,"Data":{"Nodes":[{"ToolId":1,"X":54,"Y":54,"Width":60,"Height":60,"Plugin":"AlteryxBasePluginsGui.TextInput.TextInput","StoredMacro":"","FoundMacro":"","Category":"Tool"},{"ToolId":6,"X":150,"Y":54,"Width":60,"Height":60,"Plugin":"AlteryxBasePluginsGui.Join.Join","StoredMacro":"","FoundMacro":"","Category":"Tool"},{"ToolId":18,"X":726,"Y":222,"Width":60,"Height":60,"Plugin":"","StoredMacro":"macros\\\\Tag with Sets.yxmc","FoundMacro":"C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing\\\\macros\\\\Tag with Sets.yxmc","Category":"Macro"},{"ToolId":22,"X":497,"Y":341,"Width":152.0632,"Height":114,"Plugin":"AlteryxGuiToolkit.ToolContainer.ToolContainer","StoredMacro":"","FoundMacro":"","Category":"Container"},{"ToolId":4,"X":54,"Y":138,"Width":60,"Height":60,"Plugin":"AlteryxBasePluginsGui.TextInput.TextInput","StoredMacro":"","FoundMacro":"","Category":"Tool"},{"ToolId":12,"X":246,"Y":54,"Width":60,"Height":60,"Plugin":"","StoredMacro":"Calculate Filter Expression.yxmc","FoundMacro":"C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing\\\\Calculate Filter Expression.yxmc","Category":"Macro"},{"ToolId":19,"X":822,"Y":222,"Width":60,"Height":60,"Plugin":"AlteryxBasePluginsGui.BrowseV2.BrowseV2","StoredMacro":"","FoundMacro":"","Category":"Tool"},{"ToolId":23,"X":522,"Y":390,"Width":100,"Height":40,"Plugin":"AlteryxGuiToolkit.TextBox.TextBox","StoredMacro":"","FoundMacro":"","Category":"Cosmetic"},{"ToolId":5,"X":54,"Y":222,"Width":60,"Height":60,"Plugin":"AlteryxBasePluginsGui.TextInput.TextInput","StoredMacro":"","FoundMacro":"","Category":"Tool"},{"ToolId":13,"X":342,"Y":54,"Width":60,"Height":60,"Plugin":"AlteryxBasePluginsGui.Filter.Filter","StoredMacro":"","FoundMacro":"","Category":"Tool"},{"ToolId":21,"X":294,"Y":378,"Width":100,"Height":40,"Plugin":"AlteryxGuiToolkit.TextBox.TextBox","StoredMacro":"","FoundMacro":"","Category":"Cosmetic"},{"ToolId":17,"X":630,"Y":54,"Width":60,"Height":60,"Plugin":"AlteryxSpatialPluginsGui.Summarize.Summarize","StoredMacro":"","FoundMacro":"","Category":"Tool"},{"ToolId":20,"X":269,"Y":292,"Width":405.0632,"Height":188,"Plugin":"AlteryxGuiToolkit.ToolContainer.ToolContainer","StoredMacro":"","FoundMacro":"","Category":"Container"},{"ToolId":24,"X":438,"Y":54,"Width":60,"Height":60,"Plugin":"","StoredMacro":"new.yxmc","FoundMacro":"C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing\\\\new.yxmc","Category":"Macro"}],"Connections":[{"Name":"","FromId":1,"ToId":6,"FromAnchor":"Output","ToAnchor":"Left"},{"Name":"","FromId":4,"ToId":6,"FromAnchor":"Output","ToAnchor":"Right"},{"Name":"","FromId":5,"ToId":18,"FromAnchor":"Output","ToAnchor":"Input1"},{"Name":"","FromId":17,"ToId":18,"FromAnchor":"Output","ToAnchor":"Control"},{"Name":"","FromId":6,"ToId":12,"FromAnchor":"Join","ToAnchor":"Input1"},{"Name":"","FromId":12,"ToId":13,"FromAnchor":"Output","ToAnchor":"Input"},{"Name":"","FromId":13,"ToId":24,"FromAnchor":"True","ToAnchor":"Input18"},{"Name":"","FromId":13,"ToId":24,"FromAnchor":"False","ToAnchor":"Input19"},{"Name":"","FromId":24,"ToId":17,"FromAnchor":"Output20","ToAnchor":"Input"},{"Name":"","FromId":18,"ToId":19,"FromAnchor":"Output7","ToAnchor":"Input"}]}}';
  }
}

class MockInvalidIo extends Io {
  Future<String> browseFolder(String root) async {
    //return '{"Success":true,"Data":"Hello world"}';
    return 'blah blah blah';
  }
  Future<String> getProjectStructure(String project) async => "blah blah blah";
  Future<String> getDocumentStructure(String project, String document) async => "blah blah blah";
}

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