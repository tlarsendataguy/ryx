import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/project_explorer.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/communicator_data.dart';

class LeftBar extends StatelessWidget {
  final verticalScroll = ScrollController();
  final horizontalScroll = ScrollController();

  Widget build(BuildContext context) {
    final state = BlocProvider.of<AppState>(context);

    return StreamBuilder(
      stream: state.isLoadingProject,
      builder: (context, AsyncSnapshot<bool> snapshot){
        if ((snapshot.hasData && snapshot.data) || !snapshot.hasData){
          return Center(child: CircularProgressIndicator());
        }
        return StreamBuilder(
          stream: state.projectStructure,
          builder: (context, AsyncSnapshot<ProjectStructure> snapshot){
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: CupertinoScrollbar(
                    controller: verticalScroll,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: CupertinoScrollbar(
                        controller: horizontalScroll,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ProjectExplorer(
                            structure: snapshot.data,
                            expanded: true,
                          ),
                        ),
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
                ),
                RaisedButton(
                  child: Text(
                    "Make all project macros absolute",
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                RaisedButton(
                  child: Text(
                    "Move selected files",
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: null,
                ),
              ],
            );
          },
        );
      },
    );
  }
}