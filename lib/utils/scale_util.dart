import 'package:seagull/utils/device.dart';

extension ScaleUtil on num {
  double get s => this * Device.scaleFactor;
}
