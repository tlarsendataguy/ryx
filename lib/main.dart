import 'package:flutter/material.dart';
import 'sidebar.dart';

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

class PageStructure extends StatefulWidget {
  PageStructure(
      {Key key, this.topBar, this.leftBar, this.rightBar, this.content})
      : super(key: key);

  final Widget topBar;
  final Widget leftBar;
  final Widget rightBar;
  final Widget content;

  State<StatefulWidget> createState() => _PageStructureState();
}

class _PageStructureState extends State<PageStructure> {

  var leftVisible = true;
  var rightVisible = true;
  static const minimizeWidth = 8.0;
  var cardColor = Colors.grey[200];
  var topBarColor = Colors.blue[100];

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          color: topBarColor,
          child: widget.topBar,
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SideBar(
                child: widget.leftBar,
                color: cardColor,
                position: SideBarPosition.Left,
              ),
              Expanded(
                child: Card(
                  child: widget.content,
                  color: cardColor,
                ),
              ),
              SideBar(
                child: widget.rightBar,
                color: cardColor,
                position: SideBarPosition.Right,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
