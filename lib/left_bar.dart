import 'package:flutter/material.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/project_explorer.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/communicator_data.dart';

class LeftBar extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return StreamBuilder(
      stream: state.projectStructure,
      builder: (context, AsyncSnapshot<ProjectStructure> snapshot){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ProjectExplorer(
                    structure: snapshot.data,
                    expanded: true,
                  ),
                ),
              ),
            ),
            RaisedButton(
              child: Text(
                "Make all project macros relative",
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            RaisedButton(
              child: Text(
                "Make all project macros absolute",
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: null,
            ),
          ],
        );
      },
    );
  }
}