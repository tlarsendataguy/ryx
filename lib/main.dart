import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/layouter.dart';
import 'package:ryx_gui/top_bar.dart';
import 'package:ryx_gui/web_io.dart';
import 'package:ryx_gui/formats.dart';
import 'package:ryx_gui/left_bar.dart';
import 'package:ryx_gui/sidebar.dart';
//import 'mock_io.dart';

void main() => runApp(
    BlocProvider<AppState>(
      child: MyApp(),
      bloc: AppState(WebIo()),
    ),
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ryx',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Material(
        child: PageStructure(
          topBar: TopBar(),
          leftBar: LeftBar(),
          rightBar: Text("Right stuff"),
          content: Text("Content stuff"),
        ),
      ),
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

  static const minSidebarWidth = 20.0;
  var leftVisible = true;
  var rightVisible = true;
  var layouter = new Layouter(
    getWidth: () => 0,
    minContentWidth: 100,
    minSidebarWidth: minSidebarWidth,
    leftWidth: 112,
    rightWidth: 112,
  );

  Widget build(BuildContext context) {
    layouter = layouter.copy(()=>context.size.width);

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
                tryWidth: layouter.tryLeftWidth,
                tryUnhide: layouter.unhideLeft,
                minWidth: minSidebarWidth,
                onHide: layouter.hideLeft,
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
                tryWidth: layouter.tryRightWidth,
                tryUnhide: layouter.unhideRight,
                minWidth: minSidebarWidth,
                onHide: layouter.hideRight,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
