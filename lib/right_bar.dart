import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/change_paths_button.dart';
import 'package:ryx_gui/dialogs.dart';
import 'package:ryx_gui/formats.dart';

class RightBar extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return StreamBuilder(
      stream: state.currentDocument,
      builder: (context, AsyncSnapshot<String> snapshot) {
        if (!snapshot.hasData || snapshot.data == "") {
          return Container();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
              child: Text(
                "Rename Macro",
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: () async {
                var controller = TextEditingController();
                var newName = await showDialog<String>(
                  context: context,
                  builder: (context){
                    return Dialog(
                      backgroundColor: cardColor,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              controller: controller,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  child: Text("Cancel"),
                                  onPressed: ()=>Navigator.of(context).pop(''),
                                ),
                                RaisedButton(
                                  child: Text("Rename"),
                                  onPressed: ()=>Navigator.of(context).pop(controller.text),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                );
                if (newName == ""){
                  return;
                }
                var error = await state.renameFile(newName);
                if (error == ""){
                  return;
                }
                await showDialog(
                  context: context,
                  builder: (context){
                    return ErrorDialog(error);
                  },
                );
              },
            ),
            RaisedButton(
              child: Text(
                "Move Macro",
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            ChangePathsButton(
              child: Text(
                "Make macro relative",
                overflow: TextOverflow.ellipsis,
              ),
              busyMessage: "Making macro relative in project workflows...",
              changePathsAction: () => state.makeMacroRelative(snapshot.data),
            ),
            ChangePathsButton(
              child: Text(
                "Make macro absolute",
                overflow: TextOverflow.ellipsis,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              busyMessage: "Making macro absolute in project workflows...",
              changePathsAction: () => state.makeMacroAbsolute(snapshot.data),
            ),
            RaisedButton(
              child: Text(
                "Extract selection to macro",
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: null,
            ),
            RaisedButton(
              child: Text(
                "Make selection relative",
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            RaisedButton(
              child: Text(
                "Make selection absolute",
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: null,
            ),
            Expanded(
              child: WhereUsedViewer(),
            ),
          ],
        );
      },
    );
  }
}

class WhereUsedViewer extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return Column(
      children: <Widget>[
        Text(
          "Where used in project:",
          overflow: TextOverflow.ellipsis,
        ),
        Expanded(
          child: StreamBuilder(
            stream: state.isLoadingWhereUsed,
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (!snapshot.hasData || snapshot.data) {
                return Center(child: CircularProgressIndicator());
              }
              return StreamBuilder(
                stream: state.whereUsed,
                builder: (context, AsyncSnapshot<List<String>> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          child: Text(snapshot.data[index]),
                          onDoubleTap: () =>
                              state.getDocumentStructure(snapshot.data[index]),
                        );
                      },
                    );
                  }
                  return Container();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
