import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/communicator.dart';

class MockSuccessIo extends Io {
  String browseFolder(String root){
    return '{"Success":true,"Data":["C:\\\\","D:\\\\"]}';
  }
}

class MockInvalidIo extends Io {
  String browseFolder(String root){
    //return '{"Success":true,"Data":"Hello world"}';
    return 'blah blah blah';
  }
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
    expect(response.success, isFalse);
    expect(response.error, equals('Error parsing data returned from webserver'));
    expect(response.value, isNull);
  });
}