class Path{
  Path({this.path, this.name}):assert(path != null && name != null);
  final String path;
  final String name;
}

List<Path> splitPath(String path){
  List<Path> splitPaths = [Path(name: 'root',path: '')];
  if (path == ''){
    return splitPaths;
  }
  var split = path.split("\\");
  var splitPath = "${split[0]}\\";
  splitPaths.add(Path(path: splitPath, name: splitPath));
  var index = 1;
  while (index < split.length){
    var folder = split[index];
    if (folder == ""){
      break;
    }
    if (!splitPath.endsWith("\\")) {
      splitPath = "$splitPath\\";
    }
    splitPath = "$splitPath$folder";
    splitPaths.add(Path(path: splitPath, name: folder));
    index++;
  }
  return splitPaths;
}
