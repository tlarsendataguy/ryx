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
    var state = BlocProvider.of<AppState>(context);
    var toolData = state.currentTools;
    for (var key in widget.workflow.toolData.keys){
      toolData[key] = widget.workflow.toolData[key];
    }

    return Stack(
      children: <Widget>[
        Container(color: Colors.white70),
        Positioned(
          left: workflowX,
          top: workflowY,
          width: size.width,
          height: size.height,
          child: Transform.scale(alignment: Alignment.topLeft, scale: scale, child: CustomPaint(painter: WorkflowPainter(widget.workflow, toolData))),
        ),
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
          child: Container(color: Colors.transparent),
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

class WorkflowPainter extends CustomPainter{
  WorkflowPainter(this.workflow, this.toolData);
  final DocumentStructure workflow;
  final Map<String, ToolData> toolData;

  void paint(ui.Canvas canvas, ui.Size size) {
    var nodes = datafyNodes(workflow.nodes, toolData);

    var paint = Paint();
    paint.isAntiAlias = true;
    paint.color = ui.Color.fromARGB(255, 0, 0, 0);
    for (var conn in workflow.conns){
      var fromNode = nodes[conn.fromId];
      var toNode = nodes[conn.toId];
      var from = fromNode.getInterfaceOut(conn.fromAnchor);
      if (from == null) from = fromNode.getOutput(conn.fromAnchor);
      var to = toNode.getInterfaceIn(conn.toAnchor);
      if (to == null) to = toNode.getInput(conn.toAnchor);
      
      canvas.drawLine(from, to, paint);
    }

    for (var node in nodes.values){
      var rect = Rect.fromLTRB(node.node.x, node.node.y, node.node.x+node.node.width, node.node.y+node.node.height);
      if (node.icon == null){
        paint.color = ui.Color.fromARGB(255, 0, 0, 255);
        canvas.drawRect(rect, paint);
      } else {
        paintImage(
          canvas: canvas,
          image: node.icon,
          rect: rect,
          filterQuality: ui.FilterQuality.high,
        );
      }
      paint.color = ui.Color.fromARGB(255, 255, 0, 0);
      for (var input in node.allInputs){
        canvas.drawCircle(input, 3, paint);
      }
      for (var output in node.allOutputs){
        canvas.drawCircle(output, 3, paint);
      }
    }
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