import 'package:ryx_gui/communicator.dart';
import 'bloc_state.dart';
import 'package:rxdart/rxdart.dart';

class AppState extends BlocState{
  AppState(Io io){
    _communicator = Communicator(io);
  }

  Communicator _communicator;

  var _folders = BehaviorSubject<List<String>>.seeded(null);
  Stream<List<String>> get folders => _folders.stream;

  var _currentFolder = BehaviorSubject<String>.seeded("");
  Stream<String> get currentFolder => _currentFolder.distinct();

  Future<String> browseFolder(String root) async {
    var response = await _communicator.browseFolder(root);
    if (response.success){
      _currentFolder.add(root);
      _folders.add(response.value);
    }
    return response.error;
  }

  void clearFolder() async {
    _currentFolder.add("");
    _folders.add(null);
  }

  Future initialize() async {

  }

  void dispose() {
    _folders.close();
    _currentFolder.close();
  }
}
