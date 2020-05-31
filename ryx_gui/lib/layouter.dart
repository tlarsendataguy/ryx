import 'dart:math';

typedef double GetWidth();


class Layouter {
  Layouter({this.getWidth, this.minContentWidth, this.minSidebarWidth, double sidebarWidth})
  : assert(getWidth != null && minContentWidth != null && minSidebarWidth != null && sidebarWidth != null){
    _sidebarWidth = sidebarWidth;
  }

  final GetWidth getWidth;
  final double minContentWidth;
  final double minSidebarWidth;

  double _sidebarWidth;
  bool _sidebarHidden = false;

  void _setSidebarWidth(double width) => _sidebarWidth = width;
  void _setSidebarHidden(bool hidden) => _sidebarHidden = hidden;

  bool trySidebarWidth(double sidebarWidth) {
    return _tryWidth(sidebarWidth, _setSidebarWidth);
  }

  bool _tryWidth(double newWidth, void setWidth(double width)){
    var width = getWidth();
    if (newWidth + minContentWidth > width) {
      return false;
    }
    setWidth(newWidth);
    return true;
  }

  void hideSidebar(){
    _setSidebarHidden(true);
  }

  double unhideSidebar(){
    return _unhide(_sidebarWidth, _setSidebarWidth, _setSidebarHidden);
  }

  double _unhide(double thisWidth, void setWidth(double width), void setHidden(bool hidden)){
    var width = getWidth();
    if (thisWidth + minContentWidth > width){
      thisWidth = max(minSidebarWidth, width - minContentWidth);
      setWidth(thisWidth);
    }
    setHidden(false);
    return thisWidth;
  }

  Layouter copy(GetWidth newGetWidth) {
    return Layouter(
      getWidth: newGetWidth,
      minContentWidth: minContentWidth,
      minSidebarWidth: minSidebarWidth,
      sidebarWidth: _sidebarWidth,
    );
  }
}