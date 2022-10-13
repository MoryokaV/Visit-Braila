import 'package:flutter/widgets.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;

  static late double screenWidth;
  static late double screenHeight;

  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static late double safePaddingTop;

  void init() {
    _mediaQueryData = MediaQueryData.fromWindow(WidgetsBinding.instance.window);

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    
    safeBlockHorizontal = (screenWidth - (_mediaQueryData.padding.left + _mediaQueryData.padding.right)) / 100;
    safeBlockVertical = (screenHeight - (_mediaQueryData.padding.top + _mediaQueryData.padding.bottom)) / 100;

    safePaddingTop = _mediaQueryData.padding.top;
  }
}