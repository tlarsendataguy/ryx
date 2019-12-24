import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

enum SideBarPosition{
  Left,
  Right,
}

typedef bool TryWidth(double width);
typedef double TryUnhide();
typedef void Hide();

class SideBar extends StatefulWidget {
  SideBar({Key key, this.color, this.child, this.position, this.tryWidth, this.tryUnhide, this.minWidth, this.onHide}) : super(key: key){
    assert(color != null && child != null && position != null && tryWidth != null && tryUnhide != null && minWidth != null);
  }

  final Color color;
  final Widget child;
  final SideBarPosition position;
  final double minWidth;
  final TryWidth tryWidth;
  final TryUnhide tryUnhide;
  final Hide onHide;

  State<StatefulWidget> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  var visible = true;
  static const hideWidth = 8.0;
  static const resizeWidth = 4.0;
  Widget hideButton;
  Widget resizeButton;
  var width = 300.0;
  Offset dragStart;
  var dragStartWidth = 300.0;

  void initState() {
    hideButton = InkWell(
      child: Container(width: hideWidth),
      onTap: () => setState((){
        visible = !visible;
        if (visible){
          width = widget.tryUnhide();
        } else {
          if (widget.onHide != null)
            widget.onHide();
        }
      }),
    );
    resizeButton = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (details){
        dragStart = details.globalPosition;
        dragStartWidth = width;
      },
      onHorizontalDragUpdate: (details){
        var newPos = details.globalPosition;
        var delta = newPos.dx - dragStart.dx;
        if (widget.position == SideBarPosition.Right){
          delta *= -1;
        }

        var newWidth = dragStartWidth + delta;
        var ok = widget.tryWidth(newWidth);
        if (ok){
          setState((){
            width = newWidth;
          });
        }
      },
      child: HandCursor(
        child: Container(
          width: resizeWidth,
        ),
      ),
    ) ;
    super.initState();
  }

  Widget build(BuildContext context) {
    var children = <Widget>[hideButton];
    var contentContainer = Container(
      width: width,
      child: widget.child,
      constraints: BoxConstraints(minWidth: widget.minWidth),
    );

    if (visible) {
      switch (widget.position) {
        case SideBarPosition.Left:
          children.add(contentContainer);
          children.add(resizeButton);
          break;
        case SideBarPosition.Right:
          children.insert(0, contentContainer);
          children.insert(0, resizeButton);
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

class HandCursor extends MouseRegion {
  static final appContainer = html.window.document.getElementById('app-container');
  HandCursor({Widget child})
      : super(
    onHover: (PointerHoverEvent evt) {
      appContainer.style.cursor = 'ew-resize';
    },
    onExit: (PointerExitEvent evt) {
      appContainer.style.cursor = 'default';
    },
    child: child,
  );
}