import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/models/all.dart';

class ActionIntentCubit extends StateStreamableSource<String> {
  final ActionIntentStream _stream;
  ActionIntentCubit(ActionIntentStream stream) : _stream = stream;

  @override
  FutureOr<void> close() {}

  @override
  bool get isClosed => false;

  @override
  String get state => '';

  @override
  Stream<String> get stream => _stream;
}
