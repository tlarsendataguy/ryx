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
  static const Map<String, double> _interfaceIns = {
    "Condition": 1/3,
    "Question": 2/3,
    "Question Input": 0.5,
    "Action": 0.5,
  };
  static const Map<String, double> _interfaceOuts = {
    "Question": 0.5,
    "Action": 0.5,
    "True Condition": 1/3,
    "False Condition": 2/3,
  };

  Iterable<Offset> get allInputs => _inputs.values;
  Iterable<Offset> get allOutputs => _outputs.values;

  Offset getInput(String name) => _getOffset(name, _inputs, node.x);
  Offset getOutput(String name) => _getOffset(name, _outputs, node.x+node.width);
  Offset getInterfaceIn(String name) {
    if (!_interfaceIns.containsKey(name)) return null;
    return Offset((node.width * _interfaceIns[name]) + node.x, node.y);
  }
  Offset getInterfaceOut(String name) {
    if (!_interfaceOuts.containsKey(name)) return null;
    return Offset((node.width * _interfaceOuts[name]) + node.x, node.y+node.height);
  }

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
    var key = node.plugin == "" ? node.foundMacro : node.plugin;
    var matchingTool = toolData[key];
    if (matchingTool == null){
      enriched[node.toolId] = TooledNode(node: node, inputs: [], outputs: [], icon: null);
      continue;
    }
    enriched[node.toolId] = TooledNode(node: node, inputs: matchingTool.inputs, outputs: matchingTool.outputs, icon: matchingTool.icon);
  }
  return enriched;
}