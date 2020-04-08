import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/layouter.dart';
import 'package:ryx_gui/top_bar.dart';
import 'package:ryx_gui/web_io.dart';
import 'package:ryx_gui/left_bar.dart';
import 'package:ryx_gui/sidebar.dart';
import 'package:ryx_gui/center_content.dart';
import 'mock_io.dart';

void main() => runApp(
    BlocProvider<AppState>(
      child: MyApp(),
      bloc: AppState(MockSuccessIo()),
    ),
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ryx',
      theme: ThemeData(
        primaryColor: Colors.blue[200],
        brightness: Brightness.light,
        buttonColor: Colors.blue[200],
        cardColor: Colors.grey[50],
        canvasColor: Colors.grey[200],
        backgroundColor:Colors.grey[200],
        dialogBackgroundColor: Colors.grey[200],
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.purple[900],
        brightness: Brightness.dark,
        buttonColor: Colors.purple[900],
        cardColor: Colors.grey[800],
        canvasColor: Colors.grey[850],
        backgroundColor: Colors.grey[850],
        dialogBackgroundColor: Colors.grey[850],
      ),
      home: Material(
        child: PageStructure(
          topBar: TopBar(),
          leftBar: LeftBar(),
          content: CenterContent(),
        ),
      ),
    );
  }
}

class PageStructure extends StatefulWidget {
  PageStructure(
      {Key key, this.topBar, this.leftBar, this.content})
      : super(key: key);

  final Widget topBar;
  final Widget leftBar;
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
    sidebarWidth: 300,
  );

  Widget build(BuildContext context) {
    layouter = layouter.copy(()=>context.size.width);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          child: widget.topBar,
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SideBar(
                child: widget.leftBar,
                position: SideBarPosition.Left,
                tryWidth: layouter.trySidebarWidth,
                tryUnhide: layouter.unhideSidebar,
                minWidth: minSidebarWidth,
                onHide: layouter.hideSidebar,
              ),
              Expanded(
                child: Card(
                  child: widget.content,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
