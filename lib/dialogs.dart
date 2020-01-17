import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  ErrorDialog(this.message);
  final String message;

  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Error"),
      content: Text(message),
      actions: <Widget>[
        RaisedButton(
          child: Text("Ok"),
          onPressed: Navigator.of(context).pop,
        )
      ],
    );
  }
}

class BusyDialog extends StatelessWidget {
  BusyDialog(this.message);
  final String message;

  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Text(message),
            ),
          ],
        ),
      ),
    );
  }
}

class OkDialog extends StatelessWidget {
  OkDialog(this.message);
  final String message;

  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message),
            RaisedButton(
              child: Text("Ok"),
              onPressed: Navigator.of(context).pop,
            ),
          ],
        ),
      ),
    );
  }
}