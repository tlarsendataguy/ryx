import 'package:flutter/material.dart';

enum SideBarPosition{
  Left,
  Right,
}

class SideBar extends StatefulWidget {
  SideBar({Key key, this.color, this.child, this.position}) : super(key: key);

  final Color color;
  final Widget child;
  final SideBarPosition position;

  State<StatefulWidget> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  var visible = true;
  static const minimizeWidth = 8.0;
  Widget inkwell;

  void initState() {
    inkwell = InkWell(
      child: Container(width: minimizeWidth),
      onTap: () => setState(()=>visible = !visible),
    );
    super.initState();
  }

  Widget build(BuildContext context) {
    var children = <Widget>[inkwell];

    if (visible) {
      switch (widget.position) {
        case SideBarPosition.Left:
          children.add(widget.child);
          break;
        case SideBarPosition.Right:
          children.insert(0, widget.child);
          break;
      }
    }

    return Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
      color: widget.color,
    );
  }
}
