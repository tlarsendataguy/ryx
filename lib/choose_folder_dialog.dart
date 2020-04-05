import 'package:flutter/material.dart';
import 'package:ryx_gui/communicator_data.dart';
import 'package:ryx_gui/formats.dart';


class ChooseFolderDialog extends StatefulWidget {
  ChooseFolderDialog({this.structure});

  final ProjectStructure structure;

  State<StatefulWidget> createState() => _ChooseFolderDialogState();
}

class _ChooseFolderDialogState extends State<ChooseFolderDialog> {

  String selectedFolder = "";

  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 600,
        child:  Column(
          children: <Widget>[
            Card(
              child: Container(
                padding: EdgeInsets.all(6.0),
                height: 30,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [Text("Selected: $selectedFolder")],
                ),
              ),
            ),
            Expanded(
              child: Card(
                child: ListView(
                  padding: EdgeInsets.all(8.0),
                  children: [
                    ChooseFolder(
                      widget.structure,
                          (value)=>setState(()=>selectedFolder = value),
                    ),
                  ],
                ),
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
                      child: Text("Select"),
                      onPressed: selectedFolder == "" ? null : (){
                        Navigator.of(context).pop(selectedFolder);
                      },
                    )
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

typedef void OnSelectedCallback(String selection);

class ChooseFolder extends StatefulWidget {
  ChooseFolder(this.structure, this.onSelected);
  final ProjectStructure structure;
  final OnSelectedCallback onSelected;
  State<StatefulWidget> createState() => _ChooseFolderState();
}

class _ChooseFolderState extends State<ChooseFolder>{
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
        onTap: () => widget.onSelected(widget.structure.path),
        onDoubleTap: () => setState(widget.structure.toggleExpanded),
      ),
    ];

    if (!widget.structure.expanded){
      return Column(children: widgets);
    }

    for (var folder in widget.structure.folders) {
      widgets.add(Padding(padding: EdgeInsets.fromLTRB(8, 0, 0, 0), child: ChooseFolder(folder, widget.onSelected)));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
  }
}
