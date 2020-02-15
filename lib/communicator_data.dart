import 'dart:ui';

class Response<T> {
  Response(this.value, this.success, this.error) :
        assert(success != null && error != null);

  final T value;
  final bool success;
  final String error;
}

abstract class Selectable {
  bool _selected = false;
  bool get selected => _selected;

  bool toggleSelected(){
    _selected = !_selected;
    return _selected;
  }

  void deselect() => _selected = false;
  void select() => _selected = true;
}

class ProjectStructure extends Selectable {
  ProjectStructure({this.path, this.folders, this.docs, bool expanded = false, bool selected = false}) :
        assert(path != null && folders != null && docs != null) {
    _expanded = expanded;
    _selected = selected;
  }
  final String path;
  final List<ProjectStructure> folders;
  final List<ProjectStructureDoc> docs;
  bool _expanded;
  bool get expanded => _expanded;

  void toggleExpanded(){
    _expanded = !_expanded;
  }

  void renameFile(String oldName, String newName){
    var found = _removeFile(oldName);
    if (found){
      _addFile(newName);
    }
  }

  void selectAllDocsRecursive(){
    for (var folder in folders){
      folder.select();
      folder.selectAllDocsRecursive();
    }
    for (var doc in docs){
      doc.select();
    }
  }

  void deselectAllDocsRecursive(){
    for (var folder in folders){
      folder.deselect();
      folder.deselectAllDocsRecursive();
    }
    for (var doc in docs){
      doc.deselect();
    }
  }

  List<String> getAllDocsRecursive(){
    var allDocs = List<String>();
    for (var doc in docs){
      allDocs.add(doc.path);
    }
    for (var folder in folders){
      allDocs.addAll(folder.getAllDocsRecursive());
    }
    return allDocs;
  }

  ProjectStructure copyFolders(){
    var copy = ProjectStructure(path: path, folders: [], docs: [], expanded: expanded);
    for (var folder in folders){
      copy.folders.add(folder.copyFolders());
    }
    return copy;
  }

  bool _removeFile(String removePath){
    for (var i = 0; i < docs.length; i++){
      if (docs[i].path != removePath){
        continue;
      }
      docs.removeAt(i);
      return true;
    }

    for (var folder in folders){
      if (folder._removeFile(removePath)){
        return true;
      }
    }
    return false;
  }

  void _addFile(String addPath){
    var parentSplit = addPath.split("\\")..removeLast();
    var parent = parentSplit.join("\\");
    if (path != parent){
      for (var folder in folders){
        folder._addFile(addPath);
      }
      return;
    }
    docs.add(ProjectStructureDoc(path: addPath));
    docs.sort((doc1, doc2)=> doc1.path.compareTo(doc2.path));
  }
}

class ProjectStructureDoc extends Selectable {
  ProjectStructureDoc({this.path});
  final String path;
  String get label => path.split("\\").last;
  String get ext => path.split(".").last;
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
