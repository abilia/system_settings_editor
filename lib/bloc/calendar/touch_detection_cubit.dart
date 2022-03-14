import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/logging.dart';

class TouchDetectionCubit extends Cubit<PointerDown> with Silent {
  TouchDetectionCubit() : super(PointerDown());
  void onPointerDown([_]) => emit(PointerDown());
}

class PointerDown {}
