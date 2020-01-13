import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';

class RightBar extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        RaisedButton(
          child: Text(
            "Rename Macro",
            overflow: TextOverflow.ellipsis,
          ),
          onPressed: null,
        ),
        RaisedButton(
          child: Text(
            "Move Macro",
            overflow: TextOverflow.ellipsis,
          ),
          onPressed: null,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
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
              Expanded(
                child: StreamBuilder(
                  stream: state.whereUsed,
                  builder: (context, AsyncSnapshot<List<String>> snapshot){
                    if (snapshot.hasData){
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index){
                          return Text(snapshot.data[index]);
                        },
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}