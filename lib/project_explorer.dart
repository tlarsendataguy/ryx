import 'package:flutter/material.dart';
import 'package:ryx_gui/communicator_data.dart';

class ProjectExplorer extends StatefulWidget {
  ProjectExplorer({this.structure, this.expanded});
  final ProjectStructure structure;
  final bool expanded;
  @override
  State<StatefulWidget> createState() => _ProjectExplorerState();
}

const Color folderColor = Color.fromARGB(255, 232, 194, 70);
const Color yxwzColor = Color.fromARGB(255, 27, 63, 111);
const Color yxmdColor = Color.fromARGB(255, 53, 168, 248);
const Color yxmcColor = Color.fromARGB(255, 82, 89, 182);

class _ProjectExplorerState extends State<ProjectExplorer> {
  _ProjectExplorerState();

  initState(){
    expanded = widget.expanded;
    super.initState();
  }

  bool expanded;

  Widget build(BuildContext context) {
    if (widget.structure == null){
      return Container();
    }

    var label = widget.structure.path.split("\\").last;
    var widgets = <Widget>[
      InkWell(
        child: Row(
          children: <Widget>[
            Icon(Icons.folder, color: folderColor),
            Text(label),
          ],
        ),
        onTap: ()=>setState(()=>expanded = !expanded),
      ),
    ];

    if (!expanded){
      return Column(children: widgets);
    }

    for (var folder in widget.structure.folders) {
      widgets.add(Padding(padding: EdgeInsets.fromLTRB(8, 0, 0, 0), child: ProjectExplorer(structure: folder, expanded: false)));
    }
    for (var file in widget.structure.docs) {
      var label = file.split("\\").last;
      var ext = file.split(".").last;
      Color color;
      switch (ext){
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

      widgets.add(
          Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Row(
              children: [
                Icon(Icons.description, color: color),
                Text(label),
              ],
            ),
          ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}