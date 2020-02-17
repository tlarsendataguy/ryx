import 'dart:convert';

class Request {
  Request({this.function, this.project = "", this.parameters});
  final String function;
  final String project;
  final Map<String, Object> parameters;

  String toJson(){
    return jsonEncode({
      "Function": function,
      "Project": project,
      "Parameters": parameters,
    });
  }
}
