import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

import '../../fakes/all.dart';

void main() {
  setUp(TestWidgetsFlutterBinding.ensureInitialized);
  final time = DateTime(2022, 01, 01);
  final activityDay = ActivityDay(Activity.createNew(startTime: time), time);

  test('initial state', () {
    final fullScreenActivityCubit = FullScreenActivityCubit(
      activitiesCubit: FakeActivitiesCubit(),
      activityRepository: FakeActivityRepository(),
      clockCubit: ClockCubit.fixed(time),
      alarmCubit: FakeAlarmCubit(),
      startingActivity: activityDay,
    );
    expect(
        fullScreenActivityCubit.state,
        FullScreenActivityState(
          selected: activityDay,
          eventsList: null,
        ));
  });
}
