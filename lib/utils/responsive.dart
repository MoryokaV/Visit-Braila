import 'dart:async';

import 'package:flutter/widgets.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;

  static late double screenWidth;
  static late double screenHeight;

  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static late double safePaddingTop;
  static late double safePaddingBottom;

  static late double pixelRatio;

  void getMediaQueryData() {
    _mediaQueryData = MediaQueryData.fromWindow(WidgetsBinding.instance.window);

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    safeBlockHorizontal = (screenWidth - (_mediaQueryData.padding.left + _mediaQueryData.padding.right)) / 100;
    safeBlockVertical = (screenHeight - (_mediaQueryData.padding.top + _mediaQueryData.padding.bottom)) / 100;

    safePaddingTop = _mediaQueryData.padding.top;
    safePaddingBottom = _mediaQueryData.padding.bottom;

    pixelRatio = _mediaQueryData.devicePixelRatio;
  }

  Future<void> init() async {
    getMediaQueryData();

    while (screenHeight == 0) {
      await Future.delayed(const Duration(milliseconds: 750), () => getMediaQueryData());
    }
  }
}
