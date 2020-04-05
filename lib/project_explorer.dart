import 'package:flutter/material.dart';
import 'package:ryx_gui/formats.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/communicator_data.dart';
import 'package:ryx_gui/dialogs.dart';

class ProjectExplorer extends StatefulWidget {
  ProjectExplorer({this.structure});
  final ProjectStructure structure;
  @override
  State<StatefulWidget> createState() => _ProjectExplorerState();
}

class _ProjectExplorerState extends State<ProjectExplorer> {
  _ProjectExplorerState();

  Widget build(BuildContext context) {
    if (widget.structure == null){
      return Container();
    }
    var state = BlocProvider.of<AppState>(context);
    var label = widget.structure.path.split("\\").last;
    var widgets = <Widget>[
      InkWell(
        child: Row(
          children: <Widget>[
            widget.structure.isEmpty() ?
              Icon(Icons.folder_open, color: folderColor) :
              Icon(Icons.folder, color: folderColor),
            InkWell(
              child: Icon(Icons.edit, size: 16),
              onTap: _buildOnRename(context, widget.structure.path),
            ),
            Text(label),
          ],
        ),
        onDoubleTap: ()=>setState(widget.structure.toggleExpanded),
        onTap: ()=>setState((){
          var allDocs = widget.structure.getAllDocsRecursive();
          var selected = widget.structure.toggleSelected();
          if (selected){
            widget.structure.selectAllDocsRecursive();
            state.selectExplorerList(allDocs);
          } else {
            widget.structure.deselectAllDocsRecursive();
            state.deselectExplorerList(allDocs);
          }
        }),
      ),
    ];

    if (!widget.structure.expanded){
      return Column(children: widgets);
    }

    for (var folder in widget.structure.folders) {
      widgets.add(Padding(padding: EdgeInsets.fromLTRB(8, 0, 0, 0), child: ProjectExplorer(structure: folder)));
    }
    for (var doc in widget.structure.docs) {
      widgets.add(
          Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: FileExplorer(doc: doc),
          ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class FileExplorer extends StatefulWidget {
  FileExplorer({this.doc});
  final ProjectStructureDoc doc;
  State<StatefulWidget> createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {

  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    Color color;
    switch (widget.doc.ext){
      case 'yxmd':
        color = yxmdColor;
        break;
      case 'yxmc':
        color = yxmcColor;
        break;
      case 'yxwz':
        color = yxwzColor;
        break;
      default:
        color = Colors.black;
        break;
    }

    return StreamBuilder(
      stream: state.allDeselected,
        builder: (context, snapshot){
        return InkWell(
          onDoubleTap: () async {
            var error = await state.getDocumentStructure(widget.doc.path);
            if (error != ''){
              showDialog(context: context, child: ErrorDialog(error));
            }
          },
          onTap: () => setState((){
            var selected = widget.doc.toggleSelected();
            if (selected){
              state.selectExplorer(widget.doc.path);
            } else {
              state.deselectExplorer(widget.doc.path);
            }
          }),
          child: Container(
            color: widget.doc.selected ? Color.fromARGB(25, 0, 0, 150) : Colors.transparent,
            child: Row(
              children: [
                Icon(Icons.description, color: color),
                Text(widget.doc.label),
              ],
            ),
          ),
        );
      }
    );
  }
}

Function _buildOnRename(BuildContext context, String path) {
  return () async {
    var state = BlocProvider.of<AppState>(context);
    var newName = await showDialog(
      context: context,
      child: _RenameDialog(path),
    );
    if (newName == "") return;

    showDialog(context: context, child: BusyDialog("Renaming folder..."));
    var result = await state.renameFolder(path, newName);
    Navigator.of(context).pop();
    if (!result.success) {
      await showDialog(context: context, child: ErrorDialog(result.error));
    }
  };
}

class _RenameDialog extends StatelessWidget {
  _RenameDialog(String path){
    var name = path.split("\\").removeLast();
    _controller = TextEditingController(text: name);
  }

  TextEditingController _controller;

  Widget build(BuildContext context) {

    return Dialog(
      child: Container(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
          Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: TextField(controller: _controller),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed: ()=>Navigator.of(context).pop(""),
                    ),
                    RaisedButton(
                      child: Text("Rename"),
                      onPressed: (){
                        Navigator.of(context).pop(_controller.text);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}