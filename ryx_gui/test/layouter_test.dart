import 'package:flutter_test/flutter_test.dart';
import 'package:ryx_gui/layouter.dart';

main(){
  GetWidth getWidth = ()=>500;
  var minContentWidth = 100.0;
  var minSidebarWidth = 10.0;
  Layouter stdLayouter() => Layouter(getWidth: getWidth, minContentWidth: minContentWidth, minSidebarWidth: minSidebarWidth, sidebarWidth: 100);

  test("All parameters are required", (){
    expect(()=>Layouter(minContentWidth: minContentWidth, minSidebarWidth: minSidebarWidth, sidebarWidth: 100), throwsAssertionError);
    expect(()=>Layouter(getWidth: getWidth, minSidebarWidth: minSidebarWidth, sidebarWidth: 100), throwsAssertionError);
    expect(()=>Layouter(getWidth: getWidth, minContentWidth: minContentWidth, sidebarWidth: 100), throwsAssertionError);
    expect(()=>Layouter(getWidth: getWidth, minContentWidth: minContentWidth, minSidebarWidth: minSidebarWidth), throwsAssertionError);
  });

  test("trySidebarWidth with room to grow returns true", (){
    var layouter = stdLayouter();
    expect(layouter.trySidebarWidth(200), isTrue);
  });

  test("trySidebarWidth with no room to grow returns false", (){
    var layouter = stdLayouter();
    expect(layouter.trySidebarWidth(500), isFalse);
  });

  test("Create new layouter with new getWidth, but retaining all other values", (){
    var layouter = stdLayouter();
    var oldTry = layouter.trySidebarWidth(300);

    GetWidth newGetWidth = () => 300.0;
    var newLayouter = layouter.copy(newGetWidth);
    var newTry = newLayouter.trySidebarWidth(300);

    expect(oldTry, isTrue);
    expect(newTry, isFalse);
  });

  test("hide sidebar", (){
    var layouter = stdLayouter();
    layouter.hideSidebar();
  });
}
