

import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/communicator.dart';
import 'package:ryx_gui/project_macros_filter_manager.dart';

class MacrosInProjectViewer extends StatefulWidget {
  State<StatefulWidget> createState() => _MacrosInProjectViewerState();
}

class _MacrosInProjectViewerState extends State<MacrosInProjectViewer> {

  ProjectMacrosFilterManager manager;
  TextEditingController _macroController;
  TextEditingController _foundController;
  TextEditingController _storedController;

  initState(){
    super.initState();
    _macroController = TextEditingController(text: "");
    _foundController = TextEditingController(text: "");
    _storedController = TextEditingController(text: "");
  }

  dispose(){
    if (manager != null) manager.dispose();
    _macroController.dispose();
    _storedController.dispose();
    _foundController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);
    return StreamBuilder(
      stream: state.currentProjectMacros,
      builder: (context, AsyncSnapshot<List<MacroNameInfo>> snapshot){
        if (manager != null) manager.dispose();
        if (snapshot.data == null) return Container();
        manager = ProjectMacrosFilterManager(snapshot.data);
        return Row(
          children: <Widget>[
            Expanded(
              child: ProjectMacrosColumnStructure(
                child: ProjectMacrosColumnContent(
                  label: "Macros",
                  filterController: _macroController,
                  type: ProjectMacrosColumnType.MacroNames,
                  manager: manager,
                ),
              ),
            ),
            Expanded(
              child: ProjectMacrosColumnStructure(
                child: ProjectMacrosColumnContent(
                  label: "Found Paths",
                  filterController: _foundController,
                  type: ProjectMacrosColumnType.FoundPaths,
                  manager: manager,
                ),
              ),
            ),
            Expanded(
              child: ProjectMacrosColumnStructure(
                child: ProjectMacrosColumnContent(
                  label: "Stored Paths",
                  filterController: _storedController,
                  type: ProjectMacrosColumnType.StoredPaths,
                  manager: manager,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProjectMacrosColumnStructure extends StatelessWidget {
  ProjectMacrosColumnStructure({this.child});
  final Widget child;

  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(4),
        child: child,
      ),
    );
  }
}

enum ProjectMacrosColumnType {
  MacroNames,
  FoundPaths,
  StoredPaths,
}

class ProjectMacrosColumnContent extends StatelessWidget {
  ProjectMacrosColumnContent({this.label, this.filterController, this.type, this.manager});
  final String label;
  final TextEditingController filterController;
  final ProjectMacrosColumnType type;
  final ProjectMacrosFilterManager manager;

  Widget build(BuildContext context) {
    Function(String) updateFilter;
    Function(String) selectItem;
    Stream<List<String>> stream;
    Function getSelected;
    switch (type) {
      case ProjectMacrosColumnType.MacroNames:
        updateFilter = manager.setMacroNameFilter;
        stream = manager.macroNames;
        selectItem = manager.selectMacroName;
        getSelected = ()=>manager.selectedMacroName;
        break;
      case ProjectMacrosColumnType.FoundPaths:
        updateFilter = manager.setFoundPathFilter;
        stream = manager.foundPaths;
        selectItem = manager.selectFoundPath;
        getSelected = ()=>manager.selectedFoundPath;
        break;
      case ProjectMacrosColumnType.StoredPaths:
        updateFilter = manager.setStoredPathFilter;
        stream = manager.storedPaths;
        selectItem = manager.selectStoredPath;
        getSelected = ()=>manager.selectedStoredPath;
        break;
    }
    return Column(
      children: [
        Text(label),
        TextField(
          controller: filterController,
          onChanged: updateFilter,
          decoration: InputDecoration(labelText: "Quick filter"),
        ),
        Expanded(
          child: StreamBuilder(
            stream: stream,
            builder: (context, AsyncSnapshot<List<String>> snapshot){
              if (!snapshot.hasData) return Container();
              return ListView(
                children: snapshot.data.map((e) => FlatButton(
                  child: Align(child: Text(e), alignment: Alignment.centerLeft),
                  color: getSelected() == e ?
                  Theme.of(context).highlightColor : null,
                  onPressed: (){
                    if (getSelected() == e){
                      selectItem("");
                    } else {
                      selectItem(e);
                    }
                  },
                )).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
