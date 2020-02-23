import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/loading_indicator.dart';

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
            /*RaisedButton(
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
            ),*/
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
                return LoadingIndicator();
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
                          onDoubleTap: () async =>
                              await state.getDocumentStructure(snapshot.data[index]),
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
