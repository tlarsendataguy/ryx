import 'dart:ui';

class Response<T> {
  Response(this.value, this.success, this.error) :
        assert(success != null && error != null);

  final T value;
  final bool success;
  final String error;
}

class ProjectStructure {
  ProjectStructure({this.path, this.folders, this.docs, bool expanded = false}) :
        assert(path != null && folders != null && docs != null) {
    _expanded = expanded;
  }
  final String path;
  final List<ProjectStructure> folders;
  final List<String> docs;
  bool _expanded;
  bool get expanded => _expanded;

  void toggleExpanded(){
    _expanded = !_expanded;
  }

  void renameFile(String oldName, String newName){
    var found = removeFile(oldName);
    if (found){
      addFile(newName);
    }
  }

  bool removeFile(String removePath){
    for (var i = 0; i < docs.length; i++){
      if (docs[i] != removePath){
        continue;
      }
      docs.removeAt(i);
      return true;
    }

    for (var folder in folders){
      if (folder.removeFile(removePath)){
        return true;
      }
    }
    return false;
  }

  void addFile(String addPath){
    var parentSplit = addPath.split("\\")..removeLast();
    var parent = parentSplit.join("\\");
    if (path != parent){
      for (var folder in folders){
        folder.addFile(addPath);
      }
      return;
    }
    docs.add(addPath);
    docs.sort();
  }
}

class DocumentStructure {
  DocumentStructure({this.nodes, this.conns, this.toolData}) :
        assert(nodes != null && conns != null);
  final Map<int, Node> nodes;
  final List<Conn> conns;
  final Map<String, ToolData> toolData;
}

class Node {
  Node({this.toolId, this.x, this.y, this.width, this.height, this.plugin, this.storedMacro, this.foundMacro, this.category}) :
        assert(toolId!=null && x != null && y != null && width != null && height != null && plugin != null && storedMacro != null && foundMacro != null && category != null);
  final int toolId;
  final double x;
  final double y;
  final double width;
  final double height;
  final String plugin;
  final String storedMacro;
  final String foundMacro;
  final String category;
}

class Conn {
  Conn({this.name, this.wireless, this.fromId, this.fromAnchor, this.toId, this.toAnchor}) :
        assert(name != null && fromId != null && fromAnchor != null && toId != null && toAnchor != null && wireless != null);
  final String name;
  final int fromId;
  final int toId;
  final String fromAnchor;
  final String toAnchor;
  final bool wireless;
}

class ToolData {
  ToolData({this.inputs, this.outputs, this.icon}):assert(inputs != null && outputs != null);
  final List<String> inputs;
  final List<String> outputs;
  final Image icon;
}
