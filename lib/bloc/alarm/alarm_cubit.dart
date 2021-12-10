import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class AlarmCubit extends Cubit<NotificationAlarm?> {
  late final StreamSubscription _clockSubscription;
  final ActivitiesBloc activitiesBloc;
  AlarmCubit({
    required this.activitiesBloc,
    required ClockBloc clockBloc,
  }) : super(null) {
    _clockSubscription = clockBloc.stream.listen((now) => _newMinute(now));
  }

  void _newMinute(DateTime now) {
    final state = activitiesBloc.state;
    if (state is ActivitiesLoaded) {
      final alarmsAndReminders = state.activities.alarmsOnExactMinute(now);
      for (final alarm in alarmsAndReminders) {
        emit(alarm);
      }
    }
  }

  @override
  Future<void> close() async {
    await _clockSubscription.cancel();
    return super.close();
  }
}
