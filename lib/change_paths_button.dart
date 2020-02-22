import 'package:flutter/material.dart';
import 'package:ryx_gui/dialogs.dart';
import 'package:ryx_gui/communicator_data.dart';

typedef Future<Response<int>> ChangePathsAction();

class ChangePathsButton extends StatelessWidget{
  ChangePathsButton({this.child, this.changePathsAction, this.busyMessage, this.materialTapTargetSize});
  final Widget child;
  final ChangePathsAction changePathsAction;
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
        if (changed.success){
          await showDialog(
            context: context,
            child: OkDialog(Text("${changed.value} workflows updated")),
          );
        } else {
          await showDialog(
            context: context,
            child: OkDialog(Text("Error: ${changed.error}")),
          );
        }
      },
    );
  }
}