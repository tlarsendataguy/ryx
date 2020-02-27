import 'package:ryx_gui/communicator.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:ryx_gui/request.dart';

class WebIo extends Io {
  WebIo(){
    _address = html.window.location.href;
  }

  String _address;

  Future<String> browseFolder(String root) async {
    return await _request(function: "BrowseFolder", parameters: {"FolderPath": root});
  }

  Future<String> getDocumentStructure(String project, String document) async {
    return await _request(function: "GetDocumentStructure", project: project, parameters: {"FilePath": document});
  }

  Future<String> getProjectStructure(String project) async {
    return await _request(function: "GetProjectStructure", project: project);
  }

  Future<String> getToolData() async {
    return await _request(function: "GetToolData");
  }

  Future<String> getWhereUsed(String project, String document) async {
    return await _request(function: "WhereUsed", project: project, parameters: {"FilePath": document});
  }

  Future<String> makeFilesAbsolute(String project, List<String> files) async {
    return await _request(function: "MakeFilesAbsolute", project: project, parameters: {"Files": files});
  }

  Future<String> makeAllAbsolute(String project) async {
    return await _request(function: "MakeAllFilesAbsolute", project: project);
  }

  Future<String> makeFilesRelative(String project, List<String> files) async {
    return await _request(function: "MakeFilesRelative", project: project, parameters: {"Files": files});
  }

  Future<String> makeAllRelative(String project) async {
    return await _request(function: "MakeAllFilesRelative", project: project);
  }

  Future<String> renameFiles(String project, List<String> from, List<String> to) async {
    return await _request(function: "RenameFiles", project: project, parameters: {"From":from, "To": to});
  }

  Future<String> moveFiles(String project, List<String> files, String moveTo) async {
    return await _request(function: "MoveFiles", project: project, parameters: {"Files": files, "MoveTo": moveTo});
  }

  Future<String> renameFolder(String project, String from, String to) async {
    return await _request(function: "RenameFolder", project: project, parameters: {"From": from, "To": to});
  }

  Future<String> _request({String function, String project="", Map<String,Object> parameters}) async {
    if (parameters == null){
      parameters = Map<String,String>();
    }
    try{
      var request = Request(function: function, project: project, parameters: parameters);
      var encoded = request.toJson();
      var response = await http.post(_address, headers: {"Content-type":"application/json"}, body:encoded);
      return response.body;
    } catch (ex){
      return '{"Success":false,"Data":"Error connecting to web service"}';
    }
  }
}