import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/change_paths_button.dart';
import 'package:ryx_gui/dialogs.dart';
import 'package:ryx_gui/project_explorer.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/communicator_data.dart';
import 'package:ryx_gui/choose_folder_dialog.dart';

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
                Center(child: Text("Project:")),
                Row(
                  children: <Widget>[
                    Expanded(child: ChangePathsButton(
                      child: Text(
                        "Make relative",
                        overflow: TextOverflow.ellipsis,
                      ),
                      busyMessage: "Making macros relative...",
                      changePathsAction: state.makeAllRelative,
                    )),
                    Expanded(child: ChangePathsButton(
                      child: Text(
                        "Make absolute",
                        overflow: TextOverflow.ellipsis,
                      ),
                      busyMessage: "Making macros absolute...",
                      changePathsAction: state.makeAllAbsolute,
                    )),
                  ],
                ),
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
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: state.hasSelectedExplorer,
                  builder: (context, AsyncSnapshot<bool> explorerSnapshot){
                    if (!explorerSnapshot.hasData || !explorerSnapshot.data){
                      return Container();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Center(child: Text("Selection:")),
                        RaisedButton(
                          child: Text("Deselect all"),
                          onPressed: state.deselectAllExplorer,
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: RaisedButton(
                                child: Text("Rename"),
                                onPressed: null,
                              ),
                            ),
                            Expanded(
                              child: RaisedButton(
                                child: Text("Move"),
                                onPressed: () async {
                                  var folder = await showDialog<String>(
                                    context: context,
                                    builder: (context){
                                      return StreamBuilder(
                                        stream: state.projectStructure,
                                        builder: (context, AsyncSnapshot<ProjectStructure> snapshot){
                                          if (!snapshot.hasData){
                                            return Container();
                                          }
                                          return ChooseFolderDialog(structure: snapshot.data.copyFolders());
                                        },
                                      );
                                    },
                                  );
                                  if (folder == ""){
                                    return;
                                  }
                                  showDialog(context: context, child: BusyDialog('Moving files...'), barrierDismissible: false);
                                  var response = await state.moveFiles(folder);
                                  Navigator.of(context).pop();
                                  if (!response.success){
                                    await showDialog(context: context, child: OkDialog(response.error));
                                    return;
                                  }
                                  if (response.value.length > 0) {
                                    await showDialog(context: context, child: OkDialog("${response.value.length} files could not be moved"));
                                    return;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: RaisedButton(
                                child: Text("Make relative"),
                                onPressed: null,
                              ),
                            ),
                            Expanded(
                              child: RaisedButton(
                                child: Text("Make absolute"),
                                onPressed: null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

