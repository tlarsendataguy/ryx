import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/change_paths_button.dart';
import 'package:ryx_gui/dialogs.dart';
import 'package:ryx_gui/formats.dart';

class FileParts{
  FileParts({this.parent, this.name, this.ext});
  final String parent;
  final String name;
  final String ext;

  String newName(String newName){
    return parent + newName + ext;
  }

  static FileParts fromPath(String path){
    var split = path.split("\\");
    var file = split.removeLast();
    var parent = split.join("\\") + "\\";
    var fileSplit = file.split(".");
    var ext = "." + fileSplit.removeLast();
    var name = fileSplit.join(".");
    return FileParts(parent: parent, name: name, ext: ext);
  }
}
class RightBar extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return StreamBuilder(
      stream: state.currentDocument,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (!snapshot.hasData || snapshot.data == "") {
          return Container();
        }

        var fileParts = FileParts.fromPath(snapshot.data);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
              child: Text(
                "Rename Macro",
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: buildOnRename(context, fileParts, state),
            ),
            RaisedButton(
              child: Text(
                "Move Macro",
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            ChangePathsButton(
              child: Text(
                "Make macro relative",
                overflow: TextOverflow.ellipsis,
              ),
              busyMessage: "Making macro relative in project workflows...",
              changePathsAction: () => state.makeMacroRelative(snapshot.data),
            ),
            ChangePathsButton(
              child: Text(
                "Make macro absolute",
                overflow: TextOverflow.ellipsis,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              busyMessage: "Making macro absolute in project workflows...",
              changePathsAction: () => state.makeMacroAbsolute(snapshot.data),
            ),
            RaisedButton(
              child: Text(
                "Extract selection to macro",
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: null,
            ),
            RaisedButton(
              child: Text(
                "Make selection relative",
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            RaisedButton(
              child: Text(
                "Make selection absolute",
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: null,
            ),
            Expanded(
              child: WhereUsedViewer(),
            ),
          ],
        );
      },
    );
  }
}

class WhereUsedViewer extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return Column(
      children: <Widget>[
        Text(
          "Where used in project:",
          overflow: TextOverflow.ellipsis,
        ),
        Expanded(
          child: StreamBuilder(
            stream: state.isLoadingWhereUsed,
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData || snapshot.data) {
                return Center(child: CircularProgressIndicator());
              }
              return StreamBuilder(
                stream: state.whereUsed,
                builder: (context, AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          child: Text(snapshot.data[index]),
                          onDoubleTap: () =>
                              state.getDocumentStructure(snapshot.data[index]),
                        );
                      },
                    );
                  }
                  return Container();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

Function buildOnRename(BuildContext context, FileParts fileParts, AppState state){
  return () async {
    var controller = TextEditingController(text: fileParts.name);
    var newName = await showDialog<String>(
        context: context,
        builder: (context){
          return RenameDialog(controller: controller, fileParts: fileParts);
        }
    );
    print("'$newName'");
    if (newName == ""){
      return;
    }
    var newPath = fileParts.newName(newName);
    showDialog(context: context, child: BusyDialog('Renaming file...'), barrierDismissible: false);
    var error = await state.renameFile(newPath);
    Navigator.pop(context);
    if (error == ""){
      return;
    }
    await showDialog(
      context: context,
      builder: (context){
        return ErrorDialog(error);
      },
    );
  };
}

class RenameDialog extends StatelessWidget{
  RenameDialog({this.controller, this.fileParts});

  final TextEditingController controller;
  final FileParts fileParts;

  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: cardColor,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                  ),
                ),
                Text(fileParts.ext),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: ()=>Navigator.of(context).pop(''),
                ),
                RaisedButton(
                  child: Text("Rename"),
                  onPressed: ()=>Navigator.of(context).pop(controller.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
