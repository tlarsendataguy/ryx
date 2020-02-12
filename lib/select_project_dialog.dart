import 'package:flutter/material.dart';
import 'package:ryx_gui/split_path.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/dialogs.dart';
import 'package:ryx_gui/formats.dart';

class SelectProjectDialog extends StatelessWidget {
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 600,
        width: 600,
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
        Card(
          child: Padding(
            child: currentPathStrip, 
            padding: EdgeInsets.all(2.0),
          ),
          color: cardColor,
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: folderSelector,
            ),
            color: cardColor,
          ),
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.all(2.0),
            child: buttons,
          ),
          color: cardColor,
        ),
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

        var folders = splitFolderPath(currentFolder);
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
                    showDialog(context: context, builder: (context)=>ErrorDialog(error));
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
                    showDialog(context: context, builder: (context)=>ErrorDialog(error));
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
                Navigator.of(context).pop(snapshot.data);
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
