import 'dart:convert';

class Response<T> {
  Response(this.value, this.success, this.error);

  final T value;
  final bool success;
  final String error;
}

abstract class Io{
  String browseFolder(String root);
}

typedef T BuildData<T>(Map<String, dynamic> json);

class Communicator{
  Communicator(Io io){
    _io = io;
  }

  Io _io;

  Response<List<String>> browseFolder(String root) {
    try {
      return _buildResponse<List<String>>(_io.browseFolder(root), _buildBrowseFolder);
    } catch (ex) {
      return _parseError();
    }
  }

  Response<T> _buildResponse<T>(String response, BuildData<T> buildData) {
    var json = jsonDecode(response);
    var success = json['Success'] as bool;
    var error = '';
    if (!success) {
      error = json['Data'] as String;
      return Response<T>(null, success, error);
    }
    return Response<T>(buildData(json), true, '');
  }

  List<String> _buildBrowseFolder(Map<String, dynamic> json){
    List<dynamic> paths = json['Data'];
    var data = List<String>();
    for (var path in paths) {
      data.add(path as String);
    }
    return data;
  }

  Response<T> _parseError<T>(){
    return Response<T>(null, false, 'Error parsing data returned from webserver');
  }
}
