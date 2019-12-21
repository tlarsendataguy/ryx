import 'package:flutter/material.dart';
import 'package:ryx_gui/split_path.dart';
import 'app_state.dart';
import 'bloc_provider.dart';
import 'formats.dart';

class SelectProjectDialog extends StatelessWidget {
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 700),
      child: Dialog(
        child: SelectProjectDialogStructure(
          currentPathStrip: CurrentPathStrip(),
          folderSelector: FolderSelector(),
          buttons: ButtonsRow(),
        ),
      ),
    );
  }
}

class SelectProjectDialogStructure extends StatelessWidget {
  SelectProjectDialogStructure({this.currentPathStrip, this.folderSelector, this.buttons});

  final Widget currentPathStrip;
  final Widget folderSelector;
  final Widget buttons;

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Card(child: currentPathStrip, color: cardColor),
        Expanded(child: Card(child: folderSelector, color: cardColor)),
        Card(child: buttons, color: cardColor)
      ],
    );
  }
}

class CurrentPathStrip extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return StreamBuilder(
      stream: state.currentFolder,
      builder: (context, AsyncSnapshot<String> snapshot){
        var currentFolder = "";
        if (snapshot.hasData){
          currentFolder = snapshot.data;
        }

        var folders = splitPath(currentFolder);
        return Container(
          height: 30,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: folders.length,
            itemBuilder: (context, index){
              return FlatButton(
                child: Text(folders[index].name),
                onPressed: () async {
                  var error = await state.browseFolder(folders[index].path);
                  if (error != ""){
                    print(error);
                  }
                },
              );
            },
            separatorBuilder: (context, index){
              return Center(child: Text("|"));
            },
          ),
        );
      },
    );
  }
}

class FolderSelector extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return StreamBuilder(
      stream: state.folders,
      builder: (context, AsyncSnapshot<List<String>> snapshot){
        if (snapshot.hasData){
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index){
              var path = snapshot.data[index];
              var name = path.split("\\").last;
              if (name == ''){
                name = path;
              }
              return InkWell(
                onTap: () async {
                  var error = await state.browseFolder(path);
                  if (error != ""){
                    print(error);
                  }
                },
                child: Container(height: 30, child: Center(child: Text(name))),
              );
            },
          );
        }
        return ListView(children: <Widget>[]);
      },
    );
  }
}

class ButtonsRow extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: ()=>Navigator.of(context).pop(),
        ),
        StreamBuilder(
          stream: state.currentFolder,
          builder: (context, AsyncSnapshot<String> snapshot){
            Function onPressed;
            if (snapshot.hasData && snapshot.data != ""){
              onPressed = (){
                state.getProjectStructure(snapshot.data);
                Navigator.of(context).pop();
              };
            }
            return RaisedButton(
              child: Text("Select"),
              onPressed: onPressed,
            );
          },
        ),
      ],
    );
  }
}

void selectCurrentFolder(){

}