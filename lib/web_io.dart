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
    return await _request(function: "GetProjectStructure");
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