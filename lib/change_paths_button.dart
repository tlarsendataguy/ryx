import 'package:flutter/material.dart';
import 'package:ryx_gui/dialogs.dart';

typedef Future<int> ChangePathsAction();

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
        await showDialog(
          context: context,
          child: OkDialog("$changed workflows updated"),
        );
      },
    );
  }
}