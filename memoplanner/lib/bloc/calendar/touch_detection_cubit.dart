import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

enum Touch { down }

class TouchDetectionCubit extends StateStreamableSource<Touch> {
  final _streamController = StreamController<Touch>();
  late final Stream<Touch> _stream =
      _streamController.stream.asBroadcastStream();

  void onPointerDown([_]) => _streamController.add(Touch.down);

  @override
  FutureOr<void> close() => _streamController.close();

  @override
  bool get isClosed => _streamController.isClosed;

  @override
  Touch get state => Touch.down;

  @override
  Stream<Touch> get stream => _stream;
}
