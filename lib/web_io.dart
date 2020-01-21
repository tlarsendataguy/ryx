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

  Future<String> makeMacroAbsolute(String project, String macro) async {
    return await _request(function: "MakeMacroAbsolute", project: project, parameters: {"Macro": macro});
  }

  Future<String> makeAllAbsolute(String project) async {
    return await _request(function: "MakeAllMacrosAbsolute", project: project);
  }

  Future<String> makeMacroRelative(String project, String macro) async {
    return await _request(function: "MakeMacroRelative", project: project, parameters: {"Macro": macro});
  }

  Future<String> makeAllRelative(String project) async {
    return await _request(function: "MakeAllMacrosRelative", project: project);
  }

  Future<String> renameFile(String project, String from, String to) async {
    return await _request(function: "RenameFile", project: project, parameters: {"From":from, "To": to});
  }

  Future<String> _request({String function, String project="", Map<String,String> parameters}) async {
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