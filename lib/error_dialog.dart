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