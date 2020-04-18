import 'dart:async';
import 'dart:collection';

import 'package:ryx_gui/communicator.dart';
import 'package:ryx_gui/communicator_data.dart';
import 'package:ryx_gui/bloc_state.dart';
import 'package:rxdart/rxdart.dart';

const String loadingNew = "Another doc is loading";
enum CenterPage{
  MacrosInProject,
  SelectedWorkflow,
}

class Document {
  Document(this.path, this.structure);
  final String path;
  final DocumentStructure structure;
}

class Project {
  Project(this.path, this.structure);
  final String path;
  final ProjectStructure structure;
}

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

  var _currentProject = BehaviorSubject<Project>.seeded(null);
  Stream<Project> get currentProject => _currentProject.stream;

  var _currentProjectMacros = BehaviorSubject<List<MacroNameInfo>>.seeded([]);
  Stream<List<MacroNameInfo>> get currentProjectMacros => _currentProjectMacros.stream;

  var _isLoadingProject = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoadingProject => _isLoadingProject.stream;

  var _currentDocument = BehaviorSubject<Document>.seeded(null);
  Stream<Document> get currentDocument => _currentDocument.stream;

  var _whereUsed = BehaviorSubject<List<String>>.seeded([]);
  Stream<List<String>> get whereUsed => _whereUsed.stream;

  var _centerPage = BehaviorSubject<CenterPage>.seeded(CenterPage.MacrosInProject);
  Stream<CenterPage> get centerPage => _centerPage.stream.distinct();

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

    var getStructure = _communicator.getProjectStructure(project);
    var getMacros = _communicator.listMacrosInProject(project);
    var structureResponse = await getStructure;
    if (structureResponse.success){
      structureResponse.value.toggleExpanded();
      _currentProject.add(Project(project, structureResponse.value));
    }
    var macros = await getMacros;
    if (macros.success){
      _currentProjectMacros.add(macros.value);
    }
    _isLoadingProject.add(false);
    return structureResponse.error;
  }

  Future<String> getDocumentStructure(String document) async {
    _currentDocument.add(null);
    _setLoadingDocStructure(true);
    var project = _currentProject.value;
    if (project == null){
      _setLoadingDocStructure(false);
      return "no project was open";
    }
    var error = await _processDoc(project.path, document);
    if (error == loadingNew){
      _decrementWhereUsedProcesses();
      return '';
    }
    if (error != ""){
      _whereUsed.add([]);
      _setLoadingDocStructure(false);
      return error;
    }
    error = await _processWhereUsed(project.path, document);
    _decrementWhereUsedProcesses();
    return error;
  }

  Future<Response<int>> makeSelectionAbsolute() async {
    var project = _currentProject.value;
    var response = await _communicator.makeFilesAbsolute(project.path, selectedExplorer.toList());
    await _updateMacrosInProject();
    return response;
  }

  Future<Response<int>> makeAllAbsolute() async {
    var project = _currentProject.value;
    var response = await _communicator.makeAllAbsolute(project.path);
    await _updateMacrosInProject();
    return response;
  }

  Future<Response<int>> makeSelectionRelative() async {
    var project = _currentProject.value;
    var response = await _communicator.makeFilesRelative(project.path, selectedExplorer.toList());
    await _updateMacrosInProject();
    return response;
  }

  Future<Response<int>> makeAllRelative() async {
    var project = _currentProject.value;
    var response = await _communicator.makeAllRelative(project.path);
    await _updateMacrosInProject();
    return response;
  }

  Future<Response<List<String>>> renameFiles(List<String> oldFiles, List<String> newFiles) async {
    var project = _currentProject.value;
    var response = await _communicator.renameFiles(project.path, oldFiles, newFiles);
    if (response.success){
      var getMacros = _updateMacrosInProject();
      var currentDoc = _currentDocument.value;
      var index = 0;
      for (var file in oldFiles){
        if (file == currentDoc.path){
          _currentDocument.add(Document(newFiles[index], currentDoc.structure));
          break;
        }
        index++;
      }
      var structure = project.structure;
      structure.renameFiles(oldFiles, newFiles);
      structure.deselectAllDocsRecursive();
      _removeExplorerSelection();
      _currentProject.add(Project(project.path,  structure));
      await getMacros;
    }
    return response;
  }

  Future<Response<List<String>>> moveFiles(String moveTo) async {
    var project = _currentProject.value;
    var files = selectedExplorer.toList();
    var response = await _communicator.moveFiles(project.path, files, moveTo);
    if (response.success){
      var getMacros = _updateMacrosInProject();
      var structure = project.structure;
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
      _currentProject.add(Project(project.path, structure));
      await getMacros;
    }
    return response;
  }

  Future<Response<void>> renameFolder(String from, String to) async {
    var project = _currentProject.value;
    var response = await _communicator.renameFolder(project.path, from, to);
    if (!response.success){
      return response;
    }
    var getMacros = _updateMacrosInProject();
    var newStructure = project.structure.renameFolder(from, to);
    _currentProject.add(Project(newStructure.path, newStructure));
    var currentDoc = _currentDocument.value;
    if (currentDoc != null && currentDoc.path.startsWith(from)){
      _unloadDocument();
    }
    await getMacros;
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
    var project = _currentProject.value.structure;
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

  void showMacrosInProject(){
    _centerPage.add(CenterPage.MacrosInProject);
  }

  void showSelectedWorkflow(){
    _centerPage.add(CenterPage.SelectedWorkflow);
  }

  void closeDocument(){
    _unloadDocument();
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
    if (_currentDocument.value == null){
      return;
    }
    _currentDocument.add(null);
    _whereUsed.add([]);
    _centerPage.add(CenterPage.MacrosInProject);
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
    _currentDocument.add(Document(document, getDoc.value));
    _centerPage.add(CenterPage.SelectedWorkflow);
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

  Future _updateMacrosInProject() async {
    var project = _currentProject.value;
    var macros = await _communicator.listMacrosInProject(project.path);
    if (macros.success){
      _currentProjectMacros.add(macros.value);
    } else {
      _currentProjectMacros.add([]);
    }
  }

  Future initialize() async {

  }

  void dispose() {
    _folders.close();
    _currentFolder.close();
    _currentProject.close();
    _isLoadingProject.close();
    _currentDocument.close();
    _whereUsed.close();
    _isLoadingDocument.close();
    _isLoadingWhereUsed.close();
    _toolData.close();
    _hasSelectedExplorer.close();
    _allDeselected.close();
    _currentProjectMacros.close();
    _centerPage.close();
  }
}
