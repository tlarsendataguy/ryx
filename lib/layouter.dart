import 'dart:math';

typedef double GetWidth();


class Layouter {
  Layouter({this.getWidth, this.minContentWidth, this.minSidebarWidth, double leftWidth, double rightWidth})
  : assert(getWidth != null && minContentWidth != null && minSidebarWidth != null && leftWidth != null && rightWidth != null){
    _leftWidth = leftWidth;
    _rightWidth = rightWidth;
  }

  final GetWidth getWidth;
  final double minContentWidth;
  final double minSidebarWidth;

  double _leftWidth;
  double _rightWidth;
  bool _leftHidden = false;
  bool _rightHidden = false;

  void _setLeftWidth(double width) => _leftWidth = width;
  void _setLeftHidden(bool hidden) => _leftHidden = hidden;
  void _setRightWidth(double width) => _rightWidth = width;
  void _setRightHidden(bool hidden) => _rightHidden = hidden;

  bool tryLeftWidth(double leftWidth) {
    return _tryWidth(leftWidth, _rightWidth, _rightHidden, _setLeftWidth);
  }

  bool tryRightWidth(double rightWidth) {
    return _tryWidth(rightWidth, _leftWidth, _leftHidden, _setRightWidth);
  }

  bool _tryWidth(double newWidth, double otherWidth, bool otherHidden, void setWidth(double width)){
    var width = getWidth();
    otherWidth = otherHidden ? minSidebarWidth : otherWidth;
    if (newWidth + otherWidth + minContentWidth > width) {
      return false;
    }
    setWidth(newWidth);
    return true;
  }

  void hideLeft(){
    _setLeftHidden(true);
  }

  void hideRight(){
    _setRightHidden(true);
  }

  double unhideLeft(){
    return _unhide(_leftWidth, _rightWidth, _setLeftWidth, _setLeftHidden);
  }

  double unhideRight(){
    return _unhide(_rightWidth, _leftWidth, _setRightWidth, _setRightHidden);
  }

  double _unhide(double thisWidth, double otherWidth, void setWidth(double width), void setHidden(bool hidden)){
    var width = getWidth();
    if (thisWidth + minContentWidth + otherWidth > width){
      thisWidth = max(minSidebarWidth, width - minContentWidth - otherWidth);
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
      leftWidth: _leftWidth,
      rightWidth: _rightWidth,
    );
  }
}