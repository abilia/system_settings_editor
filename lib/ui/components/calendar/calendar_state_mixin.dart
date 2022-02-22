import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';

mixin CalendarStateMixin<T extends StatefulWidget> on State<T> {
  Future<void> refresh() {
    context.read<PushCubit>().update('refresh');
    return Future.delayed(const Duration(milliseconds: 500));
  }

  bool onScrollNotification(_) {
    context.read<ScrollPositionBloc>().scrollPositionUpdated();
    return false;
  }
}
