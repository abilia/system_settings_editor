import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';

mixin CalendarStateMixin<T extends StatefulWidget> on State<T> {
  Future<void> refresh() {
    final pushBloc = context.bloc<PushBloc>();
    pushBloc.add(PushEvent('refresh'));
    return pushBloc.firstWhere((s) => s is PushReceived);
  }

  bool onScrollNotification(ScrollNotification scrollNotification) {
    context
        .bloc<ScrollPositionBloc>()
        .add(ScrollPositionUpdated(scrollNotification.metrics.pixels));
    return false;
  }
}
