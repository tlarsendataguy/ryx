import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/communicator_data.dart';

class WorkflowViewer extends StatelessWidget {
  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return StreamBuilder(
      stream: state.documentStructure,
      builder: (builderContext, AsyncSnapshot<DocumentStructure> snapshot)
      {
        if (!snapshot.hasData) {
          return Container();
        }
        return new WorkflowCanvas(workflow: snapshot.data);
      },
    );
  }
}

class WorkflowCanvas extends StatefulWidget {
  WorkflowCanvas({this.workflow}) : assert(workflow != null);
  final DocumentStructure workflow;

  State<StatefulWidget> createState() {
    return _WorkflowCanvasState();
  }
}

class _WorkflowCanvasState extends State<WorkflowCanvas>{
  double workflowX;
  double workflowY;
  Offset dragStart;

  void _reset(){
    workflowX = 0;
    workflowY = 0;
  }

  didUpdateWidget(covariant WorkflowCanvas oldWidget){
    _reset();
    super.didUpdateWidget(oldWidget);
  }

  initState(){
    _reset();
    super.initState();
  }

  Widget build(BuildContext context) {
    var size = _getSize(widget.workflow);
    var content = _generateContent(context, widget.workflow);
    return Stack(
      children: <Widget>[
        GestureDetector(
          onPanStart: (details) {
            dragStart = details.globalPosition;
          },
          onPanUpdate: (details) {
            setState(() {
              workflowX += details.delta.dx;
              workflowY += details.delta.dy;
              workflowX = workflowX > 0 ? 0 : workflowX;
              workflowY = workflowY > 0 ? 0 : workflowY;
            });
          },
          child: Container(color: Colors.white70),
        ),
        Positioned(
          left: workflowX,
          top: workflowY,
          width: size.width,
          height: size.height,
          child: Stack(children: content),
        ),
        Positioned(
          left: 20,
          top: 20,
          width: 40,
          height: 40,
          child: RaisedButton(
            padding: EdgeInsets.all(0),
            child: Icon(Icons.explore),
            onPressed: () {},
          ),
        ),
        Positioned(
          left: 65,
          top: 20,
          width: 40,
          height: 40,
          child: RaisedButton(
            padding: EdgeInsets.all(0),
            child: Icon(Icons.edit),
            onPressed: () {},
          ),
        ),
        Positioned(
          right: 20,
          top: 20,
          width: 25,
          height: 25,
          child: RaisedButton(
            padding: EdgeInsets.all(2),
            child: Icon(Icons.zoom_in),
            onPressed: () {},
          ),
        ),
        Positioned(
          right: 45,
          top: 20,
          width: 25,
          height: 25,
          child: RaisedButton(
            padding: EdgeInsets.all(2),
            child: Icon(Icons.zoom_out),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}


List<Widget> _generateContent(BuildContext context, DocumentStructure workflow){
  var state = BlocProvider.of<AppState>(context);
  var children = List<Widget>();
  for (var node in workflow.nodes){
    Widget icon = state.currentTools[node.plugin]?.icon;
    if (icon == null){
      icon = Container(
        color: Colors.blue,
      );
    }
    children.insert(0,
      Positioned(
        left: node.x.toDouble(),
        top: node.y.toDouble(),
        width: node.width,
        height: node.width,
        child: FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: (){print("button");},
          child: icon,
        ),
      ),
    );
  }
  return children;
}

Size _getSize(DocumentStructure workflow){
  var height = 0.0, width = 0.0;
  for (var node in workflow.nodes){
    var right = node.width + node.x;
    var bottom = node.height + node.y;
    height = bottom > height ? bottom : height;
    width = right > width ? right : width;
  }
  return Size(width, height);
}