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
            widget.structure.docs.length == 0 ?
              Icon(Icons.folder_open, color: folderColor) :
              Icon(Icons.folder, color: folderColor),
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