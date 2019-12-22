import 'package:flutter/material.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/select_project_dialog.dart';
import 'package:ryx_gui/app_state.dart';

class TopBar extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return Row(
      children: <Widget>[
        RaisedButton(
          child: Text("Open Project"),
          onPressed: () async {
            state.clearFolder();
            state.browseFolder("");
            showDialog(context: context, builder: (context) => SelectProjectDialog());
          },
        ),
        StreamBuilder(
          stream: state.currentProject,
          builder: (context, AsyncSnapshot<String> snapshot){
            if (snapshot.hasData){
              return Center(child: Text(snapshot.data));
            }
            return Text("");
          },
        ),
      ],
    );
  }
}
