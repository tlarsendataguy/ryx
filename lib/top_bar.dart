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
    return Column(
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
        StreamBuilder(
          stream: state.folders,
          builder: (context, AsyncSnapshot<List<String>> snapshot){
            if (snapshot.hasData){
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index){
                  var path = snapshot.data[index];
                  var name = path.split("\\").last;
                  return InkWell(
                    onDoubleTap: ()=>state.browseFolder(path),
                    child: Text(name),
                  );
                },
              );
            }
            return ListView();
          },
        ),
      ],
    );
  }
}
