import 'package:ryx_gui/communicator.dart';
import 'package:ryx_gui/communicator_data.dart';
import 'package:ryx_gui/bloc_state.dart';
import 'package:rxdart/rxdart.dart';

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

  var _isLoadingDocument = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoadingDocument => _isLoadingDocument.stream;

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
      _projectStructure.add(structureResponse.value);
      _currentProject.add(project);
    }
    _isLoadingProject.add(false);
    return structureResponse.error;
  }

  Future<String> getDocumentStructure(String document) async {
    _setLoadingDocStructure(true);
    var project = _currentProject.value;
    if (project == ''){
      _setLoadingDocStructure(false);
      return "no project was open";
    }
    var error = await _processDoc(project, document);
    if (error != ""){
      _whereUsed.add([]);
      _setLoadingDocStructure(false);
      return error;
    }
    error = await _processWhereUsed(document);
    _setLoadingDocStructure(false);
    return error;
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
    _documentStructure.add(getDoc.value);
    _currentDocument.add(document);
    return "";
  }

  Future<String> _processWhereUsed(String document) async {
    var getWhereUsed = await _communicator.getWhereUsed(document);
    if (!getWhereUsed.success){
      return getWhereUsed.error;
    }
    _whereUsed.add(getWhereUsed.value);
    return "";
  }

  void _setLoadingDocStructure(bool value){
    _isLoadingDocument.add(value);
    _isLoadingWhereUsed.add(value);
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
