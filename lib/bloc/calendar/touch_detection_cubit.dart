import 'package:flutter_bloc/flutter_bloc.dart';

class TouchDetectionCubit extends Cubit<PointerDown> {
  TouchDetectionCubit() : super(const PointerDown());

  void onPointerDown([_]) => emit(const PointerDown());
}

class PointerDown {
  const PointerDown();
}
