import 'dart:convert';
import 'dart:ui';
import 'package:ryx_gui/communicator_data.dart';

abstract class Io{
  Future<String> browseFolder(String root);
  Future<String> getProjectStructure(String project);
  Future<String> getDocumentStructure(String project, String document);
  Future<String> getToolData();
  Future<String> getWhereUsed(String project, String document);
}

typedef Future<T> BuildData<T>(dynamic data);

class Communicator{
  Communicator(Io io){
    _io = io;
  }

  Io _io;

  Future<Response<List<String>>> browseFolder(String root) async {
    try {
      return await _buildResponse<List<String>>(await _io.browseFolder(root), _buildBrowseFolder);
    } on Exception catch (ex) {
      return _parseError(ex.toString());
    }
  }

  Future<Response<ProjectStructure>> getProjectStructure(String project) async {
    try {
      return await _buildResponse<ProjectStructure>(await _io.getProjectStructure(project), _buildProjectStructure);
    } on Exception catch (ex) {
      return _parseError(ex.toString());
    }
  }

  Future<Response<DocumentStructure>> getDocumentStructure(String project, String document) async {
    try {
      return await _buildResponse<DocumentStructure>(await _io.getDocumentStructure(project, document), _buildDocumentStructure);
    } on Exception catch (ex) {
      return _parseError(ex.toString());
    }
  }

  Future<Response<Map<String, ToolData>>> getToolData() async {
    try {
      return await _buildResponse<Map<String, ToolData>>(await _io.getToolData(), _buildToolData);
    } on Exception catch (ex) {
      return _parseError(ex.toString());
    }
  }

  Future<Response<List<String>>> getWhereUsed(String project, String document) async {
    try {
      return await _buildResponse<List<String>>(await _io.getWhereUsed(project, document), _buildWhereUsed);
    } on Exception catch (ex) {
      return _parseError(ex.toString());
    }
  }

  Future<Response<T>> _buildResponse<T>(String response, BuildData<T> buildData) async {
    var json = jsonDecode(response);
    var success = json['Success'] as bool;
    var error = '';
    if (!success) {
      error = json['Data'] as String;
      return Response<T>(null, success, error);
    }
    return Response<T>(await buildData(json['Data']), true, '');
  }

  Future<List<String>> _buildBrowseFolder(dynamic data) async {
    data = data as List<dynamic>;
    var paths = List<String>();
    for (var path in data) {
      paths.add(path as String);
    }
    return paths..sort();
  }

  Future<ProjectStructure> _buildProjectStructure(dynamic data) async {
    data = data as Map<String, dynamic>;
    var path = data['Path'] as String;
    var folders = List<ProjectStructure>();
    for (var folder in data['Folders']){
      folders.add(await _buildProjectStructure(folder));
    }
    var docs = List<String>();
    for (var doc in data['Docs']){
      docs.add(doc as String);
    }
    return ProjectStructure(path: path, folders: folders, docs: docs);
  }

  Future<DocumentStructure> _buildDocumentStructure(dynamic data) async {
    data = data as Map<String, dynamic>;
    var nodes = Map<int, Node>();
    for (var node in (data['Nodes'] as List<dynamic>)) {
      node = node as Map<String, dynamic>;
      var toolId = node['ToolId'] as int;
      var x = double.parse(node['X'].toString());
      var y = double.parse(node['Y'].toString());
      var width = double.parse(node['Width'].toString());
      var height = double.parse(node['Height'].toString());
      var plugin = node['Plugin'] as String;
      var storedMacro = node['StoredMacro'] as String;
      var foundMacro = node['FoundMacro'] as String;
      var category = node['Category'] as String;
      nodes[toolId] = Node(toolId: toolId, x: x, y: y, width: width, height: height, plugin: plugin, storedMacro: storedMacro, foundMacro: foundMacro, category: category);
    }

    var conns = List<Conn>();
    for (var conn in (data['Connections'] as List<dynamic>)) {
      conn = conn as Map<String, dynamic>;
      var name = conn['Name'] as String;
      var fromId = conn['FromId'] as int;
      var toId = conn['ToId'] as int;
      var fromAnchor = conn['FromAnchor'] as String;
      var toAnchor = conn['ToAnchor'] as String;
      conns.add(Conn(name: name, fromId: fromId, fromAnchor: fromAnchor, toId: toId, toAnchor: toAnchor));
    }

    var toolData = await _buildToolData(data['MacroToolData']);
    return DocumentStructure(nodes: nodes, conns: conns, toolData: toolData);
  }

  Future<Map<String, ToolData>> _buildToolData(dynamic data) async {
    data = data as List<dynamic>;
    var tools = Map<String, ToolData>();
    for (var tool in (data)){
      tool = tool as Map<String, dynamic>;
      var plugin = tool['Plugin'] as String;
      var inputs = List<String>();
      for (var input in (tool['Inputs'] as List<dynamic>)){
        inputs.add(input as String);
      }
      var outputs = List<String>();
      for (var output in (tool['Outputs'] as List<dynamic>)) {
        outputs.add(output as String);
      }
      var iconStr = tool['Icon'] as String;
      Image icon;
      if (iconStr != ""){
        try {
          var codec = await instantiateImageCodec(base64Decode(iconStr));
          var frame = await codec.getNextFrame();
          icon = frame.image;
        } catch (ex) {
          icon = null;
        }
      }
      tools[plugin] = ToolData(
        inputs: inputs,
        outputs: outputs,
        icon: icon,
      );
    }
    return tools;
  }

  Future<List<String>> _buildWhereUsed(dynamic data) async {
    data = data as List<dynamic>;
    var whereUsed = List<String>();
    for (var where in data){
      whereUsed.add(where as String);
    }
    whereUsed.sort();
    return whereUsed;
  }

  Response<T> _parseError<T>(String error){
    return Response<T>(null, false, 'Error parsing data returned from webserver: ' + error);
  }
}
