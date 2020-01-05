import 'dart:ui';
import 'package:ryx_gui/communicator_data.dart';

class TooledNode{
  TooledNode({this.node, List<String> inputs, List<String> outputs, this.icon}){
    _inputs = {};
    _calcOffsets(_inputs, inputs, node.x);

    _outputs = {};
    _calcOffsets(_outputs, outputs, node.x + node.width);
  }

  final Node node;
  final Image icon;
  Map<String, Offset> _inputs;
  Map<String, Offset> _outputs;

  Iterable<Offset> get allInputs => _inputs.values;
  Iterable<Offset> get allOutputs => _outputs.values;

  Offset getInput(String name) => _getOffset(name, _inputs, node.x);
  Offset getOutput(String name) => _getOffset(name, _outputs, node.x+node.width);

  void _calcOffsets(Map<String, Offset> offsets, List<String> anchors, double x) {
    var distance = node.height / (anchors.length + 1);
    var inputY = node.y + distance;
    for (var anchor in anchors){
      offsets[anchor] = Offset(x, inputY);
      inputY += distance;
    }
  }

  Offset _getOffset(String name, Map<String, Offset> offsets, double defaultX){
    var position = offsets[name];
    if (position == null){
      return Offset(defaultX, node.y);
    }
    return position;
  }
}

Map<int, TooledNode> datafyNodes(Map<int, Node> nodes, Map<String, ToolData> toolData) {
  Map<int, TooledNode> enriched = {};
  for (var node in nodes.values){
    var matchingTool = toolData[node.plugin];
    if (matchingTool == null){
      enriched[node.toolId] = TooledNode(node: node, inputs: [], outputs: [], icon: null);
      continue;
    }
    enriched[node.toolId] = TooledNode(node: node, inputs: matchingTool.inputs, outputs: matchingTool.outputs, icon: matchingTool.icon);
  }
  return enriched;
}