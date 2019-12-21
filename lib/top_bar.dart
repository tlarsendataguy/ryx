import 'package:flutter/material.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'app_state.dart';

class TopBar extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return Row(
      children: <Widget>[
        RaisedButton(
          child: Text("Open Project"),
          onPressed: (){
            state.clearFolder();
            state.browseFolder("");
            showDialog(context: context, child: SelectProjectDialog());
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
              if (snapshot.hasData){
                return Text(snapshot.data);
              }
              return const Text("");
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
