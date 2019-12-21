import 'package:flutter/material.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'app_state.dart';
import 'split_path.dart';

class TopBar extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return Row(
      children: <Widget>[
        RaisedButton(
          child: Text("Open Project"),
          onPressed: () async {
            state.clearFolder();
            var future = state.browseFolder("");
            showDialog(context: context, child: SelectProjectDialog());
            var error = await future;
            if (error != ''){
              print(error);
            }
          },
        ),
      ],
    );
  }
}

class SelectProjectDialog extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return Dialog(
      child: Column(
        children: <Widget>[
          StreamBuilder(
            stream: state.currentFolder,
            builder: (context, AsyncSnapshot<String> snapshot){
              var currentFolder = "";
              if (snapshot.hasData){
                currentFolder = snapshot.data;
              }

              var folders = splitPath(currentFolder);
              return Container(
                height: 30,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: folders.length,
                  itemBuilder: (context, index){
                    return RaisedButton(
                      child: Text(folders[index].name),
                      onPressed: () async {
                        var error = await state.browseFolder(folders[index].path);
                        if (error != ""){
                          print(error);
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder(
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
                        onDoubleTap: () async {
                          var error = await state.browseFolder(path);
                          if (error != ""){
                            print(error);
                          }
                        },
                        child: Text(name),
                      );
                    },
                  );
                }
                return ListView(children: <Widget>[]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
