import 'dart:ui' as ui;

class Device {
  static final double devicePixelRatio = ui.window.devicePixelRatio;
  static final ui.Size size = ui.window.physicalSize;
  static final double width = size.width;
  static final double height = size.height;
  static final double screenWidth = width / devicePixelRatio;
  static final double screenHeight = height / devicePixelRatio;
  static final ui.Size screenSize = ui.Size(screenWidth, screenHeight);

  static final double scaleFactor = _getScale(screenSize.longestSide);

  static double _getScale(double max) {
    if (max > 1500) {
      return 3 / devicePixelRatio;
    } else if (max >= 1000) {
      return 1.5 / devicePixelRatio;
    }
    return 1;
  }
}
