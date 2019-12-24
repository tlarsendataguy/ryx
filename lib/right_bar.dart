import 'package:flutter/material.dart';

class RightBar extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RaisedButton(
          child: Text(
            "Make macro relative",
            overflow: TextOverflow.ellipsis,
          ),
          onPressed: null,
        ),
        RaisedButton(
          child: Text(
            "Make macro absolute",
            overflow: TextOverflow.ellipsis,
          ),
          onPressed: null,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
          child: Column(
            children: <Widget>[
              Text(
                "Where used in project:",
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}