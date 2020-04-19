import 'dart:collection';
import 'package:rxdart/rxdart.dart';
import 'package:ryx_gui/communicator.dart';


typedef List<String> GetList();

class ProjectMacrosFilterManager {
  ProjectMacrosFilterManager(this.projectMacros) {
    _macroNames = BehaviorSubject.seeded(_gatherMacroNames(projectMacros));
    _foundPaths = BehaviorSubject.seeded(_gatherFoundPaths(projectMacros));
    _storedPaths = BehaviorSubject.seeded(_gatherStoredPaths(projectMacros));
    _selectedMacroNameStream = BehaviorSubject.seeded('');
  }

  final List<MacroNameInfo> projectMacros;
  String _macroNameFilter = "";
  String _foundPathsFilter = "";
  String _storedPathsFilter = "";
  String _selectedMacroName = "";
  String _selectedFoundPath = "";
  String _selectedStoredPath = "";

  String get selectedMacroName => _selectedMacroName;
  String get selectedFoundPath => _selectedFoundPath;
  String get selectedStoredPath => _selectedStoredPath;

  BehaviorSubject<List<String>> _macroNames;
  Stream<List<String>> get macroNames => _macroNames.stream;

  BehaviorSubject<List<String>> _foundPaths;
  Stream<List<String>> get foundPaths => _foundPaths.stream;

  BehaviorSubject<List<String>> _storedPaths;
  Stream<List<String>> get storedPaths => _storedPaths.stream;

  BehaviorSubject<String> _selectedMacroNameStream;
  Stream<String> get selectedMacroNameStream => _selectedMacroNameStream.stream;

  void setMacroNameFilter(String filterExpression) {
    _macroNameFilter = filterExpression;
    var macros = _gatherProjectMacros();
    _macroNames.add(_gatherMacroNames(macros));
  }

  void setFoundPathFilter(String filterExpression) {
    _foundPathsFilter = filterExpression;
    var macros = _gatherProjectMacros();
    _foundPaths.add(_gatherFoundPaths(macros));
  }

  void setStoredPathFilter(String filterExpression) {
    _storedPathsFilter = filterExpression;
    var macros = _gatherProjectMacros();
    _storedPaths.add(_gatherStoredPaths(macros));
  }

  void selectMacroName(String name){
    _selectedMacroName = name;
    _selectedMacroNameStream.add(name);
    _filterAll();
  }

  void selectFoundPath(String path){
    _selectedFoundPath = path;
    _filterAll();
  }

  void selectStoredPath(String path){
    _selectedStoredPath = path;
    _filterAll();
  }

  void _filterAll(){
    var macros = _gatherProjectMacros();
    _macroNames.add(_gatherMacroNames(macros));
    _foundPaths.add(_gatherFoundPaths(macros));
    _storedPaths.add(_gatherStoredPaths(macros));
  }

  List<String> _filterList(String filterExpression, List<String> list){
    var regex = generateRegex(filterExpression);
    return list
        .where((element) => regex.hasMatch(element))
        .toList();
  }

  RegExp generateRegex(String filterExpression) {
    try {
      return RegExp(filterExpression, caseSensitive: false);
    } catch (ex) {
      return RegExp(RegExp.escape(filterExpression));
    }
  }

  List<MacroNameInfo> _gatherProjectMacros(){
    var macros = List<MacroNameInfo>();
    for (var macro in projectMacros){
      if (_selectedMacroName != "" && macro.name != _selectedMacroName){
        continue;
      }
      var foundPaths = List<MacroFoundInfo>();
      for (var found in macro.foundPaths) {
        if (_selectedFoundPath != "" && found.foundPath != _selectedFoundPath) {
          continue;
        }
        var storedPaths = List<MacroStoredInfo>();
        for (var stored in found.storedPaths) {
          if (_selectedStoredPath != "" && stored.storedPath != _selectedStoredPath) {
            continue;
          }
          storedPaths.add(
            MacroStoredInfo(
              storedPath: stored.storedPath,
              whereUsed: stored.whereUsed,
            ),
          );
        }
        if (storedPaths.length == 0) continue;
        foundPaths.add(
          MacroFoundInfo(
            foundPath: found.foundPath,
            storedPaths: storedPaths,
          ),
        );
      }
      if (foundPaths.length == 0) continue;
      macros.add(
        MacroNameInfo(
          name: macro.name,
          foundPaths: foundPaths,
        ),
      );
    }
    return macros;
  }

  List<String> _gatherMacroNames(List<MacroNameInfo> macros) {
    var macroNames = macros
      .map<String>((e) => e.name)
      .toList()
      ..sort(_compare);
    return _filterList(_macroNameFilter, macroNames);
  }

  List<String> _gatherFoundPaths(List<MacroNameInfo> macros) {
    var foundHash = HashSet<String>();
    macros
        .forEach((e1) => e1.foundPaths
        .forEach((e2) => foundHash.add(e2.foundPath)));
    return _filterList(_foundPathsFilter, foundHash.toList()..sort(_compare));
  }

  List<String> _gatherStoredPaths(List<MacroNameInfo> macros) {
    var storedHash = HashSet<String>();
    macros
        .forEach((e1) => e1.foundPaths
        .forEach((e2) => e2.storedPaths
        .forEach((e3) => storedHash.add(e3.storedPath))));
    return _filterList(_storedPathsFilter, storedHash.toList()..sort(_compare));
  }

  int _compare(String e1, String e2){
    return e1.toLowerCase().compareTo(e2.toLowerCase());
  }

  void dispose() {
    _macroNames.close();
    _foundPaths.close();
    _storedPaths.close();
    _selectedMacroNameStream.close();
  }
}
