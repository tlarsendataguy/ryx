import 'package:flutter/widgets.dart';

class ToolData {
  ToolData({this.inputs, this.outputs, this.icon}):assert(inputs != null && outputs != null);
  final List<String> inputs;
  final List<String> outputs;
  final Image icon;
}
