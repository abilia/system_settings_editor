import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

import '../../mocks/mock_bloc.dart';

void main() {
  final soundBloc = MockSoundBloc();
  final navKey = GlobalKey<NavigatorState>();
  final soundFile = UnstoredAbiliaFile.forTest(
    'id',
    'path',
    File('test.mp3'),
  );

  setUp(() {
    when(() => soundBloc.state).thenReturn(
      SoundPlaying(soundFile),
    );
  });

  Future<void> pumpSoundButton(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [routeObserver],
        navigatorKey: navKey,
        home: BlocProvider<SoundBloc>(
          create: (context) => soundBloc,
          child: PlaySoundButton(
            sound: soundFile,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets(
      'SGC-2189, SGC 2190 - Stop sound when a page is pushed on top of PlaySoundButton',
      (WidgetTester tester) async {
    // Arrange - Set up Sound button
    await pumpSoundButton(tester);

    // Expect - Sound button is visible
    expect(find.byType(PlaySoundButton), findsOneWidget);

    // Act - Push any page or widget
    navKey.currentState?.push(
      MaterialPageRoute(builder: (context) => Container()),
    );

    // Expect - StopSound is called
    verify(() => soundBloc.add(const StopSound())).called(1);
  });
}
