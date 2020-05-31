import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/loading_indicator.dart';
import 'package:ryx_gui/macros_in_project_viewer.dart';
import 'package:ryx_gui/workflow_viewer.dart';

class CenterContent extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return StreamBuilder(
      stream: state.isLoadingProject,
      builder: (context, AsyncSnapshot<bool> snapshot){
        if ((snapshot.hasData && snapshot.data) || !snapshot.hasData){
          return LoadingIndicator();
        }
        return StreamBuilder(
          stream: state.isLoadingDocument,
          builder: (context, AsyncSnapshot<bool> snapshot){
            if ((snapshot.hasData && snapshot.data) || !snapshot.hasData){
              return LoadingIndicator();
            }
            return StreamBuilder(
              stream: state.currentProject,
              builder: (context, AsyncSnapshot<Project> snapshot){
                if (snapshot.data == null) return Container();
                return Padding(
                  padding: EdgeInsets.all(4),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            FlatButton(
                              child: Text("Switch to macros in project"),
                              onPressed: state.showMacrosInProject,
                            ),
                            StreamBuilder(
                              stream: state.currentDocument,
                              builder: (context, AsyncSnapshot<Document> snapshot){
                                if (snapshot.data == null) return Container();
                                return FlatButton(
                                  child: Row(
                                    children: [
                                      Text("Switch to selected workflow"),
                                      Container(width: 8),
                                      InkWell(
                                        child: Icon(Icons.close),
                                        onTap: state.closeDocument,
                                      ),
                                    ],
                                  ),
                                  onPressed: state.showSelectedWorkflow,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Theme.of(context).backgroundColor,
                          child: StreamBuilder(
                            stream: state.centerPage,
                            builder: (context, AsyncSnapshot<CenterPage> snapshot){
                              if (!snapshot.hasData) return Container();
                              if (snapshot.data == CenterPage.SelectedWorkflow)
                                return WorkflowViewer();
                              return MacrosInProjectViewer();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}