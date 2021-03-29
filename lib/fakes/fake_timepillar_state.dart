import 'package:seagull/bloc/all.dart';

class FakeTimepillarState {
  static TimepillarState withZoom({double zoom}) => TimepillarState(
      TimepillarInterval(start: DateTime.now(), end: DateTime.now()), zoom);
}
