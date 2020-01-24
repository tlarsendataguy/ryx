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
    var containers = List<TooledNode>();
    var tools = List<TooledNode>();

    for (var node in nodes.values){
      if (['AlteryxGuiToolkit.HtmlBox.HtmlBox', 'AlteryxGuiToolkit.TextBox.TextBox', 'AlteryxGuiToolkit.ToolContainer.ToolContainer'].contains(node.node.plugin)){
        containers.add(node);
        continue;
      }
      tools.add(node);
    }

    var paint = Paint();
    paint.isAntiAlias = true;

    _paintContainers(containers, canvas, paint);
    _paintConnections(workflow.conns, nodes, canvas, paint);
    _paintTools(tools, canvas, paint);
  }

  void _paintTools(List<TooledNode> tools, Canvas canvas, Paint paint){
    for (var tool in tools){
      var rect = Rect.fromLTRB(tool.node.x, tool.node.y, tool.node.x+tool.node.width, tool.node.y+tool.node.height);
      if (tool.icon == null){
        paint.color = ui.Color.fromARGB(255, 0, 0, 255);
        canvas.drawRect(rect, paint);
      } else {
        paintImage(
          canvas: canvas,
          image: tool.icon,
          rect: rect,
          filterQuality: ui.FilterQuality.high,
        );
      }
      paint.color = ui.Color.fromARGB(255, 255, 0, 0);
      for (var input in tool.allInputs){
        canvas.drawCircle(input, 3, paint);
      }
      for (var output in tool.allOutputs){
        canvas.drawCircle(output, 3, paint);
      }
    }
  }

  void _paintContainers(List<TooledNode> containers, Canvas canvas, Paint paint){
    for (var container in containers){
      var rect = Rect.fromLTRB(container.node.x, container.node.y, container.node.x+container.node.width, container.node.y+container.node.height);
      paint.color = ui.Color.fromARGB(255, 40, 40, 40);
      paint.style = PaintingStyle.stroke;
      canvas.drawRect(rect, paint);

      var innerRect = rect.deflate(1.0);
      paint.color = ui.Color.fromARGB(100, 200, 200, 200);
      paint.style = PaintingStyle.fill;
      canvas.drawRect(innerRect, paint);
    }
  }

  void _paintConnections(List<Conn> conns, Map<int, TooledNode> nodes, Canvas canvas, Paint paint){
    paint.color = ui.Color.fromARGB(255, 0, 0, 0);
    for (var conn in conns){
      var fromNode = nodes[conn.fromId];
      var toNode = nodes[conn.toId];
      var from = fromNode.getInterfaceOut(conn.fromAnchor);
      if (from == null) from = fromNode.getOutput(conn.fromAnchor);
      var to = toNode.getInterfaceIn(conn.toAnchor);
      if (to == null) to = toNode.getInput(conn.toAnchor);

      canvas.drawLine(from, to, paint);
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