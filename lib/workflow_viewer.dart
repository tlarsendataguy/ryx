import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/communicator_data.dart';
import 'package:ryx_gui/datafy_nodes.dart';

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
  double scale;

  void _reset(){
    workflowX = 0;
    workflowY = 0;
    scale = 1;
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
          child: Transform.scale(alignment: Alignment.topLeft, scale: scale, child: Stack(children: content)),
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
            onPressed: () {
              setState(() {
                scale += 0.1;
                if (scale > 1.5){
                  scale = 1.5;
                }
              });
            },
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
            onPressed: () {
              setState(() {
                scale -= 0.1;
                if (scale < 0.3){
                  scale = 0.3;
                }
              });
            },
          ),
        ),
      ],
    );
  }
}

List<Widget> _generateContent(BuildContext context, DocumentStructure workflow){
  var state = BlocProvider.of<AppState>(context);
  var nodes = datafyNodes(workflow.nodes, state.currentTools);
  var children = List<Widget>();
  for (var node in nodes.values){
    Widget icon;
    if (node.icon == null){
      icon = Container(
        color: Colors.blue,
      );
    } else {
      icon = CustomPaint(painter: NodePainter(node));
    }
    children.insert(0,
      Positioned(
        left: node.node.x,
        top: node.node.y,
        width: node.node.width,
        height: node.node.width,
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

class NodePainter extends CustomPainter{
  NodePainter(this.node);
  final TooledNode node;

  void paint(ui.Canvas canvas, ui.Size size) {
    var rect = Rect.fromCenter(center: Offset(0,0),width: 60, height: 60);
    paintImage(
      canvas: canvas,
      image: node.icon,
      rect: rect,
      filterQuality: ui.FilterQuality.high,
    );
    var paint = Paint();
    paint.color = ui.Color.fromARGB(255, 255, 0, 0);
    paint.isAntiAlias = true;
    canvas.drawCircle(Offset(-33,0), 3, paint);
  }

  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

Size _getSize(DocumentStructure workflow){
  var height = 0.0, width = 0.0;
  for (var node in workflow.nodes.values){
    var right = node.width + node.x;
    var bottom = node.height + node.y;
    height = bottom > height ? bottom : height;
    width = right > width ? right : width;
  }
  return Size(width, height);
}