import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/change_paths_button.dart';
import 'package:ryx_gui/dialogs.dart';
import 'package:ryx_gui/loading_indicator.dart';
import 'package:ryx_gui/project_explorer.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/communicator_data.dart';
import 'package:ryx_gui/choose_folder_dialog.dart';

class LeftBar extends StatelessWidget {
  Widget build(BuildContext context) {
    final state = BlocProvider.of<AppState>(context);

    return StreamBuilder(
      stream: state.isLoadingProject,
      builder: (context, AsyncSnapshot<bool> snapshot){
        if ((snapshot.hasData && snapshot.data) || !snapshot.hasData){
          return LoadingIndicator();
        }
        return StreamBuilder(
          stream: state.projectStructure,
          builder: (context, AsyncSnapshot<ProjectStructure> snapshot){
            if (!snapshot.hasData){
              return Container();
            }
            return Padding(
              padding: EdgeInsets.only(top: 4, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Wrap(
                    children: <Widget>[
                      Tooltip(
                        message: "Convert project to relative paths",
                        child: ChangePathsButton(
                          child: Text("Rel"),
                          busyMessage: "Making macros relative...",
                          changePathsAction: state.makeAllRelative,
                        ),
                      ),
                      Tooltip(
                        message: "Convert project to absolute paths",
                        child: ChangePathsButton(
                          child: Text("Abs"),
                          busyMessage: "Making macros absolute...",
                          changePathsAction: state.makeAllAbsolute,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(4),
                      color: Theme.of(context).canvasColor,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ProjectExplorer(
                            structure: snapshot.data,
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
                      return Wrap(
                        children: <Widget>[
                          Tooltip(
                            message: "Deselect all",
                            child: IconButton(
                              icon: Icon(Icons.check_box_outline_blank),
                              onPressed: state.deselectAllExplorer,
                            ),
                          ),
                          Tooltip(
                            message: "Rename selected workflows",
                            child: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: _buildOnRename(context),
                            ),
                          ),
                          Tooltip(
                            message: "Move selected workflows",
                            child: IconButton(
                              icon: Icon(Icons.exit_to_app),
                              onPressed: _buildOnMove(context),
                            ),
                          ),
                          Tooltip(
                            message: "Convert selected workflows to relative paths",
                            child: IconButton(
                              icon: Text("Rel"),
                              onPressed: _buildOnSelectionRelative(context),
                            ),
                          ),
                          Tooltip(
                            message: "Convert selected workflows to absolute paths",
                            child: IconButton(
                              icon: Text("Abs"),
                              onPressed: _buildOnSelectionAbsolute(context),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Function _buildOnSelectionRelative(BuildContext context){
  return () async {
    var state = BlocProvider.of<AppState>(context);
    showDialog(context: context, child: BusyDialog("Making macro paths relative..."));
    var response = await state.makeSelectionRelative();
    Navigator.of(context).pop();
    if (!response.success){
      await showDialog(
        context: context,
        child: OkDialog(Text("Error: ${response.error}")),
      );
    }
  };
}

Function _buildOnSelectionAbsolute(BuildContext context){
  return () async {
    var state = BlocProvider.of<AppState>(context);
    showDialog(context: context, child: BusyDialog("Making macro paths absolute..."));
    var response = await state.makeSelectionAbsolute();
    Navigator.of(context).pop();
    if (!response.success){
      await showDialog(
        context: context,
        child: OkDialog(Text("Error: ${response.error}")),
      );
    }
  };
}

Function _buildOnRename(BuildContext context) {
  var state = BlocProvider.of<AppState>(context);
  return () async {
    var selectedFiles = state.selectedExplorer.toList()..sort();
    List<String> renamedFiles = await showDialog(
      context: context,
      child: _RenameFilesDialog(selectedFiles: selectedFiles),
    );
    if (renamedFiles == null) return;
    for (var i = 0; i < selectedFiles.length; i++) {
      var selectedFile = selectedFiles[i];
      var pathSplit = selectedFile.split("\\")..removeLast();
      var oldExt = selectedFile.split(".").last;
      var newName = "${renamedFiles[i]}.$oldExt";
      pathSplit.add(newName);
      renamedFiles[i] = pathSplit.join("\\");
    }
    showDialog(context: context, child: BusyDialog("Renaming files..."));
    var response = await state.renameFiles(selectedFiles, renamedFiles);
    Navigator.of(context).pop();
    if (!response.success){
      await showDialog(context: context, child: OkDialog(Text(response.error)));
      return;
    }
    if (response.value.length>0){
      await showDialog(
        context: context,
        child: _FailedFilesDialog(
            message: "The following files could not be renamed:",
            failedFiles: response.value,
        ),
      );
    }
  };
}

class _RenameFilesDialog extends StatefulWidget {
  _RenameFilesDialog({this.selectedFiles});
  final List<String> selectedFiles;
  State<StatefulWidget> createState() => _RenameFilesDialogState();
}

class _RenameFilesDialogState extends State<_RenameFilesDialog> {
  List<TextEditingController> controllers;

  initState(){
    super.initState();
    controllers = widget.selectedFiles.map((file){
      var fileName = file.split("\\").last;
      var nameWithoutExt = fileName.split(".")..removeLast();
      var name = nameWithoutExt.join('.');
      return TextEditingController(text: name);
    }).toList();
  }

  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 600,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ListView.builder(
                    itemCount: widget.selectedFiles.length,
                    itemBuilder: (context, index){
                      return Row(
                        children: <Widget>[
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(widget.selectedFiles[index]),
                            ),
                          ),
                          Container(width: 8),
                          Expanded(
                            child: TextField(
                              key: Key(widget.selectedFiles[index]),
                              controller: controllers[index],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed: ()=>Navigator.of(context).pop(),
                    ),
                    RaisedButton(
                      child: Text("Rename"),
                      onPressed: (){
                        var newNames = controllers.map((controller)=>controller.text).toList();
                        Navigator.of(context).pop(newNames);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Function _buildOnMove(BuildContext context) {
  var state = BlocProvider.of<AppState>(context);
  return () async {
    var folder = await _showChooseFolder(context);
    if (folder == "") return;

    showDialog(context: context, child: BusyDialog('Moving files...'), barrierDismissible: false);
    var response = await state.moveFiles(folder);
    Navigator.of(context).pop();
    if (!response.success){
      await showDialog(context: context, child: OkDialog(Text(response.error)));
      return;
    }
    if (response.value.length > 0) {
      await showDialog(
        context: context,
        child: _FailedFilesDialog(
          message: "The following files could not be moved:",
          failedFiles: response.value,
        ),
      );
    }
  };
}

Future<String> _showChooseFolder(BuildContext context) async {
  var state = BlocProvider.of<AppState>(context);
  return await showDialog<String>(
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
}

class _FailedFilesDialog extends StatelessWidget {
  _FailedFilesDialog({this.message, this.failedFiles});
  final String message;
  final List<String> failedFiles;

  Widget build(BuildContext context) {
    var child = Column(
      children: <Widget>[
        Text(message),
        Container(
          width: 600,
          padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
          constraints: BoxConstraints(maxHeight: 600),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: failedFiles.length,
            itemBuilder: (context, index){
              return Text(failedFiles[index]);
            },
          ),
        ),
      ],
    );
    return OkDialog(child);
  }
}