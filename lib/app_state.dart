import 'dart:async';
import 'dart:collection';

import 'package:ryx_gui/communicator.dart';
import 'package:ryx_gui/communicator_data.dart';
import 'package:ryx_gui/bloc_state.dart';
import 'package:rxdart/rxdart.dart';

const String loadingNew = "Another doc is loading";

class AppState extends BlocState{
  AppState(Io io){
    _communicator = Communicator(io);
  }

  Communicator _communicator;

  var _toolData = BehaviorSubject<Map<String,ToolData>>.seeded(null);
  Stream<Map<String,ToolData>> get toolData => _toolData.stream;
  Map<String,ToolData> get currentTools => _toolData.value;

  var _folders = BehaviorSubject<List<String>>.seeded(null);
  Stream<List<String>> get folders => _folders.stream;

  var _currentFolder = BehaviorSubject<String>.seeded("");
  Stream<String> get currentFolder => _currentFolder.distinct();

  var _currentProject = BehaviorSubject<String>.seeded("");
  Stream<String> get currentProject => _currentProject.stream;

  var _projectStructure = BehaviorSubject<ProjectStructure>.seeded(null);
  Stream<ProjectStructure> get projectStructure => _projectStructure.stream;

  var _isLoadingProject = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoadingProject => _isLoadingProject.stream;

  var _currentDocument = BehaviorSubject<String>.seeded("");
  Stream<String> get currentDocument => _currentDocument.stream;

  var _whereUsed = BehaviorSubject<List<String>>.seeded([]);
  Stream<List<String>> get whereUsed => _whereUsed.stream;

  var _loadingDocumentProcesses = 0;
  bool _incrementDocumentProcesses(){
    _loadingDocumentProcesses++;
    return _calculateIsLoadingDocument();
  }
  bool _decrementDocumentProcesses(){
    _loadingDocumentProcesses--;
    return _calculateIsLoadingDocument();
  }
  bool _calculateIsLoadingDocument(){
    var isLoading = _loadingDocumentProcesses != 0;
    _isLoadingDocument.add(isLoading);
    return isLoading;
  }
  var _isLoadingDocument = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoadingDocument => _isLoadingDocument.stream;

  var _loadingWhereUsedProcesses = 0;
  void _incrementWhereUsedProcesses(){
    _loadingWhereUsedProcesses++;
    _calculateIsLoadingWhereUsed();
  }
  void _decrementWhereUsedProcesses(){
    _loadingWhereUsedProcesses--;
    _calculateIsLoadingWhereUsed();
  }
  void _calculateIsLoadingWhereUsed(){
    var isLoading = _loadingWhereUsedProcesses != 0;
    _isLoadingWhereUsed.add(isLoading);
  }
  var _isLoadingWhereUsed = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoadingWhereUsed => _isLoadingWhereUsed.stream;

  var _documentStructure = BehaviorSubject<DocumentStructure>.seeded(null);
  Stream<DocumentStructure> get documentStructure => _documentStructure.stream;

  var _hasSelectedExplorer = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get hasSelectedExplorer => _hasSelectedExplorer.distinct();
  var _allDeselected = BehaviorSubject<void>();
  Stream<void> get allDeselected => _allDeselected.stream;
  HashSet<String> selectedExplorer = HashSet<String>();

  Future<String> browseFolder(String root) async {
    var response = await _communicator.browseFolder(root);
    if (response.success){
      _currentFolder.add(root);
      _folders.add(response.value);
    }
    return response.error;
  }

  Future<String> getProjectStructure(String project) async {
    _isLoadingProject.add(true);
    _removeExplorerSelection();
    _unloadDocument();
    var toolDataResponse = await _communicator.getToolData();
    if (!toolDataResponse.success){
      _isLoadingProject.add(false);
      return toolDataResponse.error;
    }
    _toolData.add(toolDataResponse.value);

    var structureResponse = await _communicator.getProjectStructure(project);
    if (structureResponse.success){
      structureResponse.value.toggleExpanded();
      _projectStructure.add(structureResponse.value);
      _currentProject.add(project);
    }
    _isLoadingProject.add(false);
    return structureResponse.error;
  }

  Future<String> getDocumentStructure(String document) async {
    _currentDocument.add("");
    _setLoadingDocStructure(true);
    var project = _currentProject.value;
    if (project == ''){
      _setLoadingDocStructure(false);
      return "no project was open";
    }
    var error = await _processDoc(project, document);
    if (error == loadingNew){
      _decrementWhereUsedProcesses();
      return '';
    }
    if (error != ""){
      _whereUsed.add([]);
      _setLoadingDocStructure(false);
      return error;
    }
    error = await _processWhereUsed(project, document);
    _decrementWhereUsedProcesses();
    return error;
  }

  Future<Response<int>> makeSelectionAbsolute() async {
    var project = _currentProject.value;
    var response = await _communicator.makeFilesAbsolute(project, selectedExplorer.toList());
    return response;
  }

  Future<Response<int>> makeAllAbsolute() async {
    var project = _currentProject.value;
    var response = await _communicator.makeAllAbsolute(project);
    return response;
  }

  Future<Response<int>> makeSelectionRelative() async {
    var project = _currentProject.value;
    var response = await _communicator.makeFilesRelative(project, selectedExplorer.toList());
    return response;
  }

  Future<Response<int>> makeAllRelative() async {
    var project = _currentProject.value;
    var response = await _communicator.makeAllRelative(project);
    return response;
  }

  Future<Response<List<String>>> renameFiles(List<String> oldFiles, List<String> newFiles) async {
    var project = _currentProject.value;
    var response = await _communicator.renameFiles(project, oldFiles, newFiles);
    if (response.success){
      var currentDoc = _currentDocument.value;
      var index = 0;
      for (var file in oldFiles){
        if (file == currentDoc){
          _currentDocument.add(newFiles[index]);
          break;
        }
        index++;
      }
      var structure = _projectStructure.value;
      structure.renameFiles(oldFiles, newFiles);
      structure.deselectAllDocsRecursive();
      _removeExplorerSelection();
      _projectStructure.add(structure);
    }
    return response;
  }

  Future<Response<List<String>>> moveFiles(String moveTo) async {
    var project = _currentProject.value;
    var files = selectedExplorer.toList();
    var response = await _communicator.moveFiles(project, files, moveTo);
    if (response.success){
      var structure = _projectStructure.value;
      var newFiles = List<String>();
      for (var file in files){
        if (response.value.contains(file)){
          continue;
        }
        var name = file.split("\\").last;
        var newFile = moveTo + "\\" + name;
        newFiles.add(newFile);
      }
      structure.renameFiles(files, newFiles);
      structure.deselectAllDocsRecursive();
      _removeExplorerSelection();
      _projectStructure.add(structure);
    }
    return response;
  }

  Future<Response<void>> renameFolder(String from, String to) async {
    var project = _currentProject.value;
    var response = await _communicator.renameFolder(project, from, to);
    if (!response.success){
      return response;
    }
    var newStructure = _projectStructure.value.renameFolder(from, to);
    if (project == from){
      _currentProject.add(newStructure.path);
    }
    _projectStructure.add(newStructure);
    var currentDoc = _currentDocument.value;
    if (currentDoc.startsWith(from)){
      _unloadDocument();
    }
    return response;
  }

  void clearFolder() async {
    _currentFolder.add("");
    _folders.add(null);
  }

  void selectExplorer(String item){
    selectedExplorer.add(item);
    _hasSelectedExplorer.add(true);
  }

  void deselectExplorer(String item){
    selectedExplorer.remove(item);
    _markIfSelectedExplorerIsEmpty();
  }

  void deselectAllExplorer(){
    var project = _projectStructure.value;
    if (project != null){
      project.deselectAllDocsRecursive();
    }
    _removeExplorerSelection();
    _allDeselected.add(null);
  }

  void selectExplorerList(Iterable<String> items){
    selectedExplorer.addAll(items);
    _hasSelectedExplorer.add(true);
  }

  void deselectExplorerList(Iterable<String> items){
    selectedExplorer.removeAll(items);
    _markIfSelectedExplorerIsEmpty();
  }

  void _removeExplorerSelection(){
    selectedExplorer.clear();
    _hasSelectedExplorer.add(false);
  }

  void _markIfSelectedExplorerIsEmpty(){
    if (selectedExplorer.length == 0) {
      _hasSelectedExplorer.add(false);
    }
  }

  void _unloadDocument(){
    if (_currentDocument.value == ""){
      return;
    }
    _currentDocument.add("");
    _documentStructure.add(null);
    _whereUsed.add([]);
  }

  Future<String> _processDoc(String project, String document) async {
    var getDoc = await _communicator.getDocumentStructure(project, document);
    if (!getDoc.success){
      return getDoc.error;
    }
    var isLoading = _decrementDocumentProcesses();
    if (isLoading){
      return loadingNew;
    }
    _documentStructure.add(getDoc.value);
    _currentDocument.add(document);
    return "";
  }

  Future<String> _processWhereUsed(String project, String document) async {
    var getWhereUsed = await _communicator.getWhereUsed(project, document);
    if (!getWhereUsed.success){
      return getWhereUsed.error;
    }
    _whereUsed.add(getWhereUsed.value);
    return "";
  }

  void _setLoadingDocStructure(bool value){
    if (value){
      _incrementWhereUsedProcesses();
      _incrementDocumentProcesses();
    } else {
      _decrementWhereUsedProcesses();
      _decrementDocumentProcesses();
    }
  }

  Future initialize() async {

  }

  void dispose() {
    _folders.close();
    _currentFolder.close();
    _currentProject.close();
    _projectStructure.close();
    _isLoadingProject.close();
    _currentDocument.close();
    _whereUsed.close();
    _isLoadingDocument.close();
    _isLoadingWhereUsed.close();
    _documentStructure.close();
    _toolData.close();
    _hasSelectedExplorer.close();
    _allDeselected.close();
  }
}
