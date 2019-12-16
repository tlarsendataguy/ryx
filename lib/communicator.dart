import 'dart:convert';

class Response<T> {
  Response(this.value, this.success, this.error);

  final T value;
  final bool success;
  final String error;
}

class ProjectStructure {
  ProjectStructure({this.path, this.folders, this.docs});
  final String path;
  final List<ProjectStructure> folders;
  final List<String> docs;
}

abstract class Io{
  String browseFolder(String root);
  String getProjectStructure(String project);
}

typedef T BuildData<T>(dynamic data);

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

  Response<ProjectStructure> getProjectStructure(String project) {
    try {
      return _buildResponse<ProjectStructure>(_io.getProjectStructure(project), _buildProjectStructure);
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
    return Response<T>(buildData(json['Data']), true, '');
  }

  List<String> _buildBrowseFolder(dynamic data){
    data = data as List<dynamic>;
    var paths = List<String>();
    for (var path in data) {
      paths.add(path as String);
    }
    return paths;
  }

  ProjectStructure _buildProjectStructure(dynamic data){
    data = data as Map<String, dynamic>;
    var path = data['Path'] as String;
    var folders = List<ProjectStructure>();
    for (var folder in data['Folders']){
      folders.add(_buildProjectStructure(folder));
    }
    var docs = List<String>();
    for (var doc in data['Docs']){
      docs.add(doc as String);
    }
    return ProjectStructure(path: path, folders: folders, docs: docs);
  }

  Response<T> _parseError<T>(){
    return Response<T>(null, false, 'Error parsing data returned from webserver');
  }
}
