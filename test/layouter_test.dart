import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/layouter.dart';

main(){
  GetWidth getWidth = ()=>500;
  var minContentWidth = 100.0;
  var minSidebarWidth = 10.0;
  Layouter stdLayouter() => Layouter(getWidth: getWidth, minContentWidth: minContentWidth, minSidebarWidth: minSidebarWidth, leftWidth: 100, rightWidth: 100);

  test("All parameters are required", (){
    expect(()=>Layouter(minContentWidth: minContentWidth, leftWidth: 100, rightWidth: 100), throwsAssertionError);
    expect(()=>Layouter(getWidth: getWidth, leftWidth: 100, rightWidth: 100), throwsAssertionError);
    expect(()=>Layouter(minContentWidth: minContentWidth, getWidth: getWidth, rightWidth: 100), throwsAssertionError);
    expect(()=>Layouter(minContentWidth: minContentWidth, leftWidth: 100, getWidth: getWidth), throwsAssertionError);
  });

  test("tryLeftWidth with room to grow returns true", (){
    var layouter = stdLayouter();
    expect(layouter.tryLeftWidth(200), isTrue);
  });

  test("tryLeftWidth with no room to grow returns false", (){
    var layouter = stdLayouter();
    expect(layouter.tryLeftWidth(500), isFalse);
  });

  test("tryRightWidth with room to grow returns true", (){
    var layouter = stdLayouter();
    expect(layouter.tryRightWidth(200), isTrue);
  });

  test("tryRightWidth with no room to grow returns false", (){
    var layouter = stdLayouter();
    expect(layouter.tryRightWidth(500), isFalse);
  });

  test("Create new layouter with new getWidth, but retaining all other values", (){
    var layouter = stdLayouter();
    var oldTry = layouter.tryLeftWidth(300);

    GetWidth newGetWidth = () => 300.0;
    var newLayouter = layouter.copy(newGetWidth);
    var newTry = newLayouter.tryLeftWidth(300);

    expect(oldTry, isTrue);
    expect(newTry, isFalse);
  });

  test("hide left bar", (){
    var layouter = stdLayouter();
    layouter.hideLeft();
    var ok = layouter.tryRightWidth(390);
    expect(ok, isTrue);
  });

  test("hide right bar", (){
    var layouter = stdLayouter();
    layouter.hideRight();
    var ok = layouter.tryLeftWidth(390);
    expect(ok, isTrue);
  });

  test("Unhide left bar when space constrained",(){
    var layouter = stdLayouter();
    layouter.hideLeft();
    layouter.tryRightWidth(390);
    var newSize = layouter.unhideLeft();
    expect(newSize, equals(10));
  });

  test("Unhide right bar when space constrained",(){
    var layouter = stdLayouter();
    layouter.hideRight();
    layouter.tryLeftWidth(390);
    var newSize = layouter.unhideRight();
    expect(newSize, equals(10));
  });

  test("Unhide left bar when partially space constrained",(){
    var layouter = stdLayouter();
    layouter.hideLeft();
    layouter.tryRightWidth(350);
    var newSize = layouter.unhideLeft();
    expect(newSize, equals(50));
  });

  test("Unhide right bar when partially space constrained",(){
    var layouter = stdLayouter();
    layouter.hideRight();
    layouter.tryLeftWidth(350);
    var newSize = layouter.unhideRight();
    expect(newSize, equals(50));
  });
}
