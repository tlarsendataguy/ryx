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

  Future<int> makeMacroAbsolute(String macro) async {
    var project = _currentProject.value;
    var response = await _communicator.makeMacroAbsolute(project, macro);
    return response.value;
  }

  Future<int> makeAllAbsolute() async {
    var project = _currentProject.value;
    var response = await _communicator.makeAllAbsolute(project);
    return response.value;
  }

  Future<int> makeMacroRelative(String macro) async {
    var project = _currentProject.value;
    var response = await _communicator.makeMacroRelative(project, macro);
    return response.value;
  }

  Future<int> makeAllRelative() async {
    var project = _currentProject.value;
    var response = await _communicator.makeAllRelative(project);
    return response.value;
  }

  Future<String> renameFile(String newFile) async {
    var project = _currentProject.value;
    var oldFile = _currentDocument.value;
    var response = await _communicator.renameFile(project, oldFile, newFile);
    if (response.success){
      _currentDocument.add(newFile);
      var structure = _projectStructure.value;
      structure.renameFile(oldFile, newFile);
      _projectStructure.add(structure);
    }
    return response.error;
  }

  void clearFolder() async {
    _currentFolder.add("");
    _folders.add(null);
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
  }
}
