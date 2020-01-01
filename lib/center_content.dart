

import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/workflow_viewer.dart';

class CenterContent extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StreamBuilder(
          stream: state.currentDocument,
          builder: (context, AsyncSnapshot<String> snapshot){
            var text = "";
            if (snapshot.hasData) {
              text = snapshot.data.split("\\").last;
            }
            return Text(text);
          },
        ),
        Expanded(child: WorkflowViewer()),
      ],
    );
  }
}