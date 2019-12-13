import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ryx',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Material(
        child: SelectProject(),
      ),
    );
  }
}

class SelectProject extends StatelessWidget {
  SelectProject({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return PageStructure(
      topBar: Text("Top bar stuff"),
      leftBar: Text("Left stuff"),
      rightBar: Text("Right stuff"),
      content: Text("Content stuff"),
    );
  }
}

class PageStructure extends StatelessWidget {
  PageStructure({Key key, this.topBar, this.leftBar, this.rightBar, this.content}) : super(key: key);

  final Widget topBar;
  final Widget leftBar;
  final Widget rightBar;
  final Widget content;

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          color: Colors.blue[100],
          child: topBar,
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: leftBar,
                color: Colors.grey[200],
              ),
              Expanded(
                child: Card(
                  child: content,
                  color: Colors.grey[200],
                ),
              ),
              Card(
                child: rightBar,
                color: Colors.grey[200],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
