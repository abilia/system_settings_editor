import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';

mixin CalendarStateMixin<T extends StatefulWidget> on State<T> {
  Future<void> refresh() {
    context.bloc<PushBloc>().add(PushEvent('refresh'));
    return context
        .bloc<ActivitiesBloc>()
        .firstWhere((s) => s is! ActivitiesReloadning && s is ActivitiesLoaded);
  }

  bool onScrollNotification(ScrollNotification scrollNotification) {
    context
        .bloc<ScrollPositionBloc>()
        .add(ScrollPositionUpdated(scrollNotification.metrics.pixels));
    return false;
  }
}
