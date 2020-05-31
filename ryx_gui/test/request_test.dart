import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/request.dart';

main(){
  test("test JSON conversion",(){
    var request = Request(function: "BrowseFolder", project: "Something", parameters: {});

    try {
      var json = request.toJson();
      print("json: " + json);

    } catch (ex){
      expect(ex, isNull);
    }
  });
}