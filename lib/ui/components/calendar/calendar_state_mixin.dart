// @dart=2.9

import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';

mixin CalendarStateMixin<T extends StatefulWidget> on State<T> {
  Future<void> refresh() {
    final pushBloc = context.read<PushBloc>();
    pushBloc.add(PushEvent('refresh'));
    return pushBloc.stream.firstWhere((s) => s is PushReceived);
  }

  bool onScrollNotification(_) {
    context.read<ScrollPositionBloc>().add(const ScrollPositionUpdated());
    return false;
  }
}
