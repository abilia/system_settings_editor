import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/abilia_timer.dart';
import 'package:seagull/models/occasion/event_occasion.dart';
import 'package:seagull/models/occasion/timer_occasion.dart';
import 'package:seagull/repository/ticker.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';

void main() {
  final nowTime = DateTime(2022, 01, 29, 13, 37);

  setUp(() async {
    GetItInitializer()
      ..ticker = Ticker.fake(initialTime: nowTime)
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..init();
  });

  Widget wrap(final TimerCard timerCard) => Directionality(
        textDirection: TextDirection.ltr,
        child: timerCard,
      );

  testWidgets('timer card duration before tick is correct', (tester) async {
    const timerTitle = 'timer title';
    final timerOccasion = TimerOccasion(
      AbiliaTimer(
        id: 'id',
        title: timerTitle,
        startTime: nowTime.subtract(const Duration(minutes: 30)),
        duration: const Duration(hours: 1),
      ),
      Occasion.current,
    );
    await tester.pumpWidget(
      wrap(TimerCard(timerOccasion: timerOccasion, day: nowTime)),
    );

    expect(find.text(timerTitle), findsOneWidget);
    expect(find.text('01:00:00'), findsNothing);
    expect(find.text('30:00'), findsOneWidget);
  });
}
