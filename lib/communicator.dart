import 'dart:convert';
import 'dart:ui';
import 'package:ryx_gui/communicator_data.dart';

abstract class Io{
  Future<String> browseFolder(String root);
  Future<String> getProjectStructure(String project);
  Future<String> getDocumentStructure(String project, String document);
  Future<String> getToolData();
  Future<String> getWhereUsed(String project, String document);
  Future<String> makeFilesAbsolute(String project, List<String> files);
  Future<String> makeAllAbsolute(String project);
  Future<String> makeFilesRelative(String project, List<String> files);
  Future<String> makeAllRelative(String project);
  Future<String> renameFiles(String project, List<String> from, List<String> to);
  Future<String> moveFiles(String project, List<String> files, String moveTo);
}

typedef Future<T> BuildData<T>(dynamic data);
typedef Future<String> SendRequest();

class Communicator{
  Communicator(Io io){
    _io = io;
  }

  Io _io;

  Future<Response<List<String>>> browseFolder(String root) async {
    return await _buildResponse(
      request: ()async => await _io.browseFolder(root),
      buildData: _buildBrowseFolder,
    );
  }

  Future<Response<ProjectStructure>> getProjectStructure(String project) async {
    return await _buildResponse(
      request: ()async => await _io.getProjectStructure(project),
      buildData: _buildProjectStructure,
    );
  }

  Future<Response<DocumentStructure>> getDocumentStructure(String project, String document) async {
    return await _buildResponse(
      request: ()async => await _io.getDocumentStructure(project, document),
      buildData: _buildDocumentStructure,
    );
  }

  Future<Response<Map<String, ToolData>>> getToolData() async {
    return await _buildResponse(
      request: ()async => await _io.getToolData(),
      buildData: _buildToolData,
    );
  }

  Future<Response<List<String>>> getWhereUsed(String project, String document) async {
    return await _buildResponse(
      request: ()async => await _io.getWhereUsed(project, document),
      buildData: _buildWhereUsed,
    );
  }

  Future<Response<int>> makeFilesAbsolute(String project, List<String> files) async {
    return await _buildResponse(
      request: ()async => await _io.makeFilesAbsolute(project, files),
      buildData: _buildIntResponse,
    );
  }

  Future<Response<int>> makeAllAbsolute(String project) async {
    return await _buildResponse(
      request: ()async => await _io.makeAllAbsolute(project),
      buildData: _buildIntResponse,
    );
  }

  Future<Response<int>> makeFilesRelative(String project, List<String> files) async {
    return await _buildResponse(
      request: () async => await _io.makeFilesRelative(project, files),
      buildData: _buildIntResponse,
    );
  }

  Future<Response<int>> makeAllRelative(String project) async {
    return await _buildResponse(
      request: () async => await _io.makeAllRelative(project),
      buildData: _buildIntResponse,
    );
  }

  Future<Response<void>> renameFiles(String project, List<String> from, List<String> to) async {
    return await _buildResponse(
      request: () async => await _io.renameFiles(project, from, to),
      buildData: (data){return;},
    );
  }

  Future<Response<List<String>>> moveFiles(String project, List<String> files, String moveTo) async {
    return await _buildResponse(
      request: () async => await _io.moveFiles(project, files, moveTo),
      buildData: _buildMoveFilesResponse,
    );
  }

  Future<Response<T>> _buildResponse<T>({SendRequest request, BuildData<T> buildData}) async {
    try {
      var response = await request();
      var json = jsonDecode(response);
      var success = json['Success'] as bool;
      var error = '';
      if (!success) {
        error = json['Data'] as String;
        return Response<T>(null, success, error);
      }
      return Response<T>(await buildData(json['Data']), true, '');
    } on Exception catch (ex) {
      return _parseError(ex.toString());
    }
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
    var docs = List<ProjectStructureDoc>();
    for (var doc in data['Docs']){
      docs.add(ProjectStructureDoc(path: doc as String));
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
      var wireless = conn['Wireless'] as bool;
      conns.add(Conn(name: name, wireless: wireless, fromId: fromId, fromAnchor: fromAnchor, toId: toId, toAnchor: toAnchor));
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

  Future<int> _buildIntResponse(dynamic data) async => data as int;

  Future<List<String>> _buildMoveFilesResponse(dynamic data) async {
    data = data as List<dynamic>;
    var errors = List<String>();
    for (var path in data) {
      errors.add(path as String);
    }
    return errors;
  }

  Response<T> _parseError<T>(String error){
    return Response<T>(null, false, 'Error parsing data returned from webserver: ' + error);
  }
}
