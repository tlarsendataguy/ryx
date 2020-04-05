import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/loading_indicator.dart';
import 'package:ryx_gui/workflow_viewer.dart';

class CenterContent extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return StreamBuilder(
      stream: state.isLoadingDocument,
      builder: (context, AsyncSnapshot<bool> snapshot){
        if ((snapshot.hasData && snapshot.data) || !snapshot.hasData){
          return LoadingIndicator();
        }
        return Padding(
          padding: EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder(
                stream: state.currentDocument,
                builder: (context, AsyncSnapshot<String> snapshot){
                  if (snapshot.hasData && snapshot.data != "") {
                    var text = snapshot.data.split("\\").last;
                    return Row(
                      children: <Widget>[
                        Text(text),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () async => await state.getDocumentStructure(snapshot.data),
                        ),
                      ],
                    );
                  }
                  return Text("");
                },
              ),
              Expanded(child: WorkflowViewer()),
            ],
          ),
        );
      },
    );
  }
}