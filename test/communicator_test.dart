import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/communicator.dart';

class MockSuccessIo extends Io {
  String browseFolder(String root){
    return '{"Success":true,"Data":["C:\\\\","D:\\\\"]}';
  }
  String getProjectStructure(String project) {
    return '{"Success":true,"Data":{"Path":"C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing","Folders":[{"Path":"C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing\\\\macros","Folders":[],"Docs":["C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing\\\\macros\\\\Tag with Sets.yxmc"]}],"Docs":["C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing\\\\01 SETLEAF Equations Completed.yxmd","C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing\\\\Calculate Filter Expression.yxmc","C:\\\\Users\\\\tlarsen\\\\Documents\\\\Ryx Unit Testing\\\\new.yxmc"]}}';
  }
}

class MockInvalidIo extends Io {
  String browseFolder(String root){
    //return '{"Success":true,"Data":"Hello world"}';
    return 'blah blah blah';
  }
  String getProjectStructure(String project) => "blah blah blah";
}

main(){
  var validIo = MockSuccessIo();
  var badIo = MockInvalidIo();

  test("browse folders",(){
    var communicator = Communicator(validIo);
    var response = communicator.browseFolder('');
    expect(response.success, isTrue);
    expect(response.error, equals(''));
    expect(response.value.length, equals(2));
    expect(response.value[0], equals('C:\\'));
    expect(response.value[1], equals('D:\\'));
  });

  test("browse folders with invalid returned json", (){
    var communicator = Communicator(badIo);
    var response = communicator.browseFolder('');
    expectParsingDataError(response);
  });

  test("get project structure",(){
    var communicator = Communicator(validIo);
    var response = communicator.getProjectStructure('');
    expect(response.success, isTrue);
    expect(response.error, equals(''));
    expect(response.value.path, equals("C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing"));
    expect(response.value.folders.length, equals(1));
    expect(response.value.docs.length, equals(3));
    expect(response.value.folders[0].path, equals("C:\\Users\\tlarsen\\Documents\\Ryx Unit Testing\\macros"));
    expect(response.value.folders[0].folders.length, equals(0));
    expect(response.value.folders[0].docs.length, equals(1));
  });

  test("get project structure with invalid returned json", (){
    var communicator = Communicator(badIo);
    var response = communicator.getProjectStructure('');
    expectParsingDataError(response);
  });
}

void expectParsingDataError(Response response){
  expect(response.success, isFalse);
  expect(response.error, equals('Error parsing data returned from webserver'));
  expect(response.value, isNull);
}