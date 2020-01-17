import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/dialogs.dart';
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
            if (!snapshot.hasData){
              return Container();
            }
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
                ChangePathsButton(
                  child: Text(
                    "Make all project macros relative",
                    overflow: TextOverflow.ellipsis,
                  ),
                  busyMessage: "Making macros relative...",
                  changePathsAction: state.makeAllRelative,
                ),
                ChangePathsButton(
                  child: Text(
                    "Make all project macros absolute",
                    overflow: TextOverflow.ellipsis,
                  ),
                  busyMessage: "Making macros absolute...",
                  changePathsAction: state.makeAllAbsolute,
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

typedef Future<int> _action();

class ChangePathsButton extends StatelessWidget{
  ChangePathsButton({this.child, this.changePathsAction, this.busyMessage, this.materialTapTargetSize});
  final Widget child;
  final _action changePathsAction;
  final String busyMessage;
  final MaterialTapTargetSize materialTapTargetSize;

  Widget build(BuildContext context) {
    return RaisedButton(
      child: child,
      onPressed: () async {
        showDialog(
          barrierDismissible: false,
          context: context,
          child: BusyDialog(busyMessage),
        );
        var changed = await changePathsAction();
        Navigator.of(context).pop();
        await showDialog(
          context: context,
          child: OkDialog("$changed workflows updated"),
        );
      },
    );
  }
}