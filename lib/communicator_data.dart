import 'package:flutter/widgets.dart';

class Response<T> {
  Response(this.value, this.success, this.error) :
        assert(success != null && error != null);

  final T value;
  final bool success;
  final String error;
}

class ProjectStructure {
  ProjectStructure({this.path, this.folders, this.docs}) :
        assert(path != null && folders != null && docs != null);
  final String path;
  final List<ProjectStructure> folders;
  final List<String> docs;
}

class DocumentStructure {
  DocumentStructure({this.nodes, this.conns}) :
        assert(nodes != null && conns != null);
  final List<Node> nodes;
  final List<Conn> conns;
}

class Node {
  Node({this.toolId, this.x, this.y, this.width, this.height, this.plugin, this.storedMacro, this.foundMacro, this.category}) :
        assert(toolId!=null && x != null && y != null && width != null && height != null && plugin != null && storedMacro != null && foundMacro != null && category != null);
  final int toolId;
  final int x;
  final int y;
  final double width;
  final double height;
  final String plugin;
  final String storedMacro;
  final String foundMacro;
  final String category;
}

class Conn {
  Conn({this.name, this.fromId, this.fromAnchor, this.toId, this.toAnchor}) :
        assert(name != null && fromId != null && fromAnchor != null && toId != null && toAnchor != null);
  final String name;
  final int fromId;
  final int toId;
  final String fromAnchor;
  final String toAnchor;
}

class ToolData {
  ToolData({this.inputs, this.outputs, this.icon}):assert(inputs != null && outputs != null);
  final List<String> inputs;
  final List<String> outputs;
  final Image icon;
}
