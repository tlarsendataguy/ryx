

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:ryx_gui/app_state.dart';
import 'package:ryx_gui/bloc_provider.dart';
import 'package:ryx_gui/communicator.dart';
import 'package:ryx_gui/dialogs.dart';
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
        return Column(
          children: [
            Expanded(
              child: Row(
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
    Function(List<String>) builder;

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

    if (type == ProjectMacrosColumnType.MacroNames){
      builder = (List<String> items) {
        return (BuildContext context, int index) {
          var e = items[index];
          return Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async => await showMacroNameEditor(context, manager, e),
              ),
              Expanded(
                child: FlatButton(
                  child: Align(child: Text(e), alignment: Alignment.centerLeft),
                  color: getSelected() == e ?
                  Theme
                      .of(context)
                      .highlightColor : null,
                  onPressed: () {
                    if (getSelected() == e) {
                      selectItem("");
                    } else {
                      selectItem(e);
                    }
                  },
                ),
              ),
            ],
          );
        };
      };
    } else {
      builder = (List<String> items) {
        return (BuildContext context, int index) {
          var e = items[index];
          return FlatButton(
            child: Align(child: Text(e), alignment: Alignment.centerLeft),
            color: getSelected() == e ?
            Theme
                .of(context)
                .highlightColor : null,
            onPressed: () {
              if (getSelected() == e) {
                selectItem("");
              } else {
                selectItem(e);
              }
            },
          );
        };
      };
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
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: builder(snapshot.data),
              );
            },
          ),
        ),
      ],
    );
  }
}

Future showMacroNameEditor(BuildContext context, ProjectMacrosFilterManager manager, String name) async {
  for (var macro in manager.projectMacros){
    if (macro.name == name){
      await showDialog(
        context: context,
        child: MacroNameEditor(macro),
      );
      return;
    }
  }
}

class MacroNameEditor extends StatefulWidget {
  MacroNameEditor(this.macro);

  final MacroNameInfo macro;

  State<StatefulWidget> createState() => _MacroNameEditorState();
}

class _MacroNameEditorState extends State<MacroNameEditor> {

  TextEditingController _controller;
  Map<String, bool> _foundPaths;
  Map<String, bool> _storedPaths;


  initState(){
    super.initState();
      _controller = TextEditingController(text: widget.macro.name);
      _foundPaths = Map<String, bool>.fromIterable(
          widget.macro.foundPaths
          .map((e) => e.foundPath),
      value: (key)=>false);
    var storedPathsHash = HashSet<String>();
    widget.macro.foundPaths
        .forEach((e1) => e1.storedPaths
        .forEach((e2) => storedPathsHash.add(e2.storedPath))
    );
    _storedPaths = Map<String, bool>.fromIterable(storedPathsHash, value: (key)=>false);
  }

  Widget build(BuildContext context) {
    var state = BlocProvider.of<AppState>(context);

    return Dialog(
      child: Column(
        children: <Widget>[
          Expanded(child:
            Card(
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: "Macro Setting",
                      ),
                    ),
                    Container(height: 10),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text("Only change for the following found macros:"),
                                Expanded(
                                  child: ListView(
                                    children: _foundPaths.keys
                                      .map((e) => Row(
                                        children: <Widget>[
                                          Checkbox(
                                            value: _foundPaths[e],
                                            onChanged: (newValue)=>setState((){
                                              _foundPaths[e] = newValue;
                                            }),
                                          ),
                                          Expanded(child: Text(e)),
                                        ],
                                      ),
                                    ).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text("Only change for the following macro settings:"),
                                Expanded(
                                  child: ListView(
                                    children: _storedPaths.keys
                                        .map((e) => Row(
                                      children: <Widget>[
                                        Checkbox(
                                          value: _storedPaths[e],
                                          onChanged: (newValue)=>setState((){
                                            _storedPaths[e] = newValue;
                                          }),
                                        ),
                                        Expanded(child: Text(e)),
                                      ],
                                    ),
                                    ).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Text("Cancel"),
                    onPressed: Navigator.of(context).pop,
                  ),
                  RaisedButton(
                    child: Text("Submit"),
                    onPressed: () async {
                      showDialog(context: context, child: BusyDialog("Changing macro settings..."));
                      var foundPaths = List<String>();
                      _foundPaths.forEach((key, value) {if (value) foundPaths.add(key);});
                      var storedPaths = List<String>();
                      _storedPaths.forEach((key, value) {if (value) storedPaths.add(key);});
                      var response = await state.batchUpdateMacroSettings(
                        widget.macro.name,
                        _controller.text,
                        foundPaths,
                        storedPaths,
                      );
                      Navigator.of(context).pop();
                      if (response != "") {
                        await showDialog(context: context, child: OkDialog(Text("Error: $response")));
                        return;
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

