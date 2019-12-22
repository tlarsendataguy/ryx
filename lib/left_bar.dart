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
        if (!snapshot.hasData){
          return Container();
        }

        var structure = ProjectExplorer(structure: snapshot.data, expanded: true);
        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: structure,
          ),
        );
      },
    );
  }
}