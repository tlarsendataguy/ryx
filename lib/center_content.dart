

import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/communicator_data.dart';

class CenterContent extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StreamBuilder(
          stream: state.currentDocument,
          builder: (context, AsyncSnapshot<String> snapshot){
            var text = "";
            if (snapshot.hasData) {
              text = snapshot.data.split("\\").last;
            }
            return Text(text);
          },
        ),
        Expanded(
          child: StreamBuilder(
            stream: state.documentStructure,
            builder: (context, AsyncSnapshot<DocumentStructure> snapshot){
              if (!snapshot.hasData){
                return Container();
              }

              var children = List<Widget>();
              for (var node in snapshot.data.nodes){
                Widget icon = state.currentTools[node.plugin]?.icon;
                if (icon == null){
                  icon = Container(
                    color: Colors.blue,
                  );
                }
                children.add(
                  Positioned(
                    left: node.x.toDouble(),
                    top: node.y.toDouble(),
                    width: node.width,
                    height: node.width,
                    child: icon,
                  ),
                );
              }
              return Stack(
                children: children,
              );
            },
          ),
        ),
      ],
    );
  }
}