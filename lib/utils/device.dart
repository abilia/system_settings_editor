import 'dart:ui' as ui;

class Device {
  static const minSupportedHeight = 540;
  static const largeScaleFactor = 3.0;
  static const mpLargeTrueDevicePixelRatio = 0.75;
  static double? devicePixelRatioCorrection;

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
      if (devicePixelRatio < 1) return largeScaleFactor;
      devicePixelRatioCorrection = mpLargeTrueDevicePixelRatio;
      return largeScaleFactor * mpLargeTrueDevicePixelRatio;
    }
    if (max >= 1000) return 1.5;
    if (max < minSupportedHeight) return 0.75;
    return 1.0;
  }
}
