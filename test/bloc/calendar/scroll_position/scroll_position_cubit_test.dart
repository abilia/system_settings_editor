import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../fakes/fakes_blocs.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  late ScrollPositionCubit scrollPositionCubit;
  late MockScrollController mockScrollController;
  late MockScrollPosition mockScrollPosition;
  late StreamController<DateTime> ticker;
  final initialTime = DateTime(2020, 12, 24, 15, 00);

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    ticker = StreamController<DateTime>();
    final clockBloc = ClockBloc(ticker.stream, initialTime: initialTime);
    final dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
    mockScrollController = MockScrollController();
    mockScrollPosition = MockScrollPosition();

    scrollPositionCubit = ScrollPositionCubit(
      dayPickerBloc: dayPickerBloc,
      clockBloc: clockBloc,
      timepillarMeasuresCubit: FakeTimepillarMeasuresCubit(),
      inactivityCubit: FakeInactivityCubit(),
    );
    when(() => mockScrollController.position).thenReturn(mockScrollPosition);
    when(() => mockScrollController.hasClients).thenReturn(true);
    when(() => mockScrollController.animateTo(any(),
        duration: any(named: 'duration'),
        curve: any(named: 'curve'))).thenAnswer((_) => Future.value());
  });

  tearDown(() {
    ticker.close();
  });

  test('initial state is Unready', () {
    // Assert
    expect(scrollPositionCubit.state, Unready());
  });

  test(
      'after event ListViewRenderComplete still Unready if ScrollController has no Clients',
      () async {
    // Arrange
    when(() => mockScrollController.hasClients).thenReturn(false);
    final expect = expectLater(scrollPositionCubit.stream, emits(Unready()));
    // Act
    scrollPositionCubit.scrollViewRenderComplete(mockScrollController);

    // Assert
    await expect;
  });

  test('InView', () async {
    // Arrange
    when(() => mockScrollController.offset).thenReturn(0);
    when(() => mockScrollController.initialScrollOffset).thenReturn(0);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(800);
    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(InView(mockScrollController)),
    );

    // Act
    scrollPositionCubit.scrollViewRenderComplete(mockScrollController);

    // Assert
    await expect;
  });

  test('OutOfView', () async {
    // Arrange
    when(() => mockScrollController.offset).thenReturn(600);
    when(() => mockScrollController.initialScrollOffset).thenReturn(200);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(800);
    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(OutOfView(mockScrollController)),
    );

    // Act
    scrollPositionCubit.scrollViewRenderComplete(mockScrollController);

    // Assert
    await expect;
  });

  test('Just InView top', () async {
    // Arrange
    const init = 200.0;
    when(() => mockScrollController.offset)
        .thenReturn(init - scrollPositionCubit.nowMarginBottom);
    when(() => mockScrollController.initialScrollOffset).thenReturn(init);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(InView(mockScrollController)),
    );
    // Act
    scrollPositionCubit.scrollViewRenderComplete(mockScrollController);

    // Assert
    await expect;
  });

  test('Just InView bottom', () async {
    // Arrange
    const init = 200.0;
    when(() => mockScrollController.offset)
        .thenReturn(init + scrollPositionCubit.nowMarginTop);
    when(() => mockScrollController.initialScrollOffset).thenReturn(init);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(InView(mockScrollController)),
    );
    // Act
    scrollPositionCubit.scrollViewRenderComplete(mockScrollController);

    // Assert
    await expect;
  });

  test('Just OutView top', () async {
    // Arrange
    const init = 200.0;
    when(() => mockScrollController.offset)
        .thenReturn(init - scrollPositionCubit.nowMarginBottom - 1);
    when(() => mockScrollController.initialScrollOffset).thenReturn(init);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(OutOfView(mockScrollController)),
    );
    // Act
    scrollPositionCubit.scrollViewRenderComplete(mockScrollController);

    // Assert
    await expect;
  });

  test('Just OutOfView bottom', () async {
    // Arrange
    const init = 200.0;
    when(() => mockScrollController.offset)
        .thenReturn(init + scrollPositionCubit.nowMarginTop + 1);
    when(() => mockScrollController.initialScrollOffset).thenReturn(init);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(OutOfView(mockScrollController)),
    );
    // Act
    scrollPositionCubit.scrollViewRenderComplete(mockScrollController);

    // Assert
    await expect;
  });

  test(
    'InView then scroll down and then OutOfView',
    () async {
      // Arrange
      const activityAt = 200.0, max = 800.0;
      when(() => mockScrollController.offset).thenReturn(activityAt);
      when(() => mockScrollController.initialScrollOffset)
          .thenReturn(activityAt);
      when(() => mockScrollPosition.maxScrollExtent).thenReturn(max);

      final expect = expectLater(
        scrollPositionCubit.stream,
        emits(InView(mockScrollController)),
      );
      // Act
      scrollPositionCubit.scrollViewRenderComplete(mockScrollController);

      // Assert
      await expect;

      final expect2 = expectLater(
        scrollPositionCubit.stream,
        emits(OutOfView(mockScrollController)),
      );
      // Act
      for (var i = activityAt; i < max; i++) {
        when(() => mockScrollController.offset).thenReturn(i);
        scrollPositionCubit.scrollPositionUpdated();
      }

      // Assert
      await expect2;
    },
  );

  test('InView then scroll up and then OutOfView', () async {
    const activityAt = 200.0, max = 800.0;
    // Arrange
    when(() => mockScrollController.offset).thenReturn(activityAt);
    when(() => mockScrollController.initialScrollOffset).thenReturn(activityAt);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(max);

    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(InView(mockScrollController)),
    );
    // Act
    scrollPositionCubit.scrollViewRenderComplete(mockScrollController);

    // Assert
    await expect;

    final expect2 = expectLater(
      scrollPositionCubit.stream,
      emits(OutOfView(mockScrollController)),
    );
    // Act
    for (var i = activityAt; i > 0; i--) {
      when(() => mockScrollController.offset).thenReturn(i);
      scrollPositionCubit.scrollPositionUpdated();
    }

    // Assert
    await expect2;
  });

  test('Scrolls back', () async {
    // Arrange
    const initialOffset = 100.0;
    when(() => mockScrollController.initialScrollOffset)
        .thenReturn(initialOffset);
    when(() => mockScrollController.offset).thenReturn(200);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(400);
    final expect = untilCalled(() => mockScrollController.animateTo(
        initialOffset,
        duration: any(named: 'duration'),
        curve: any(named: 'curve')));

    // Act
    scrollPositionCubit.scrollViewRenderComplete(mockScrollController);
    scrollPositionCubit.goToNow();

    // Assert
    await expect;
  });

  test('Bug SGC-1701 Now button not working correctly', () async {
    // Arrange
    when(() => mockScrollController.offset).thenReturn(0);
    when(() => mockScrollController.initialScrollOffset).thenReturn(0);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(800);

    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(InView(mockScrollController)),
    );

    final expect2 = expectLater(
      scrollPositionCubit.stream,
      neverEmits(Unready()),
    );

    // Act
    scrollPositionCubit.scrollViewRenderComplete(mockScrollController);
    await scrollPositionCubit.goToNow();
    scrollPositionCubit.close();
    // Assert
    await expect;
    await expect2;
  });

  group('go to now follows now', () {
    test('createdTime', () async {
      // Arrange
      when(() => mockScrollController.offset).thenReturn(0);
      when(() => mockScrollController.initialScrollOffset).thenReturn(0);
      when(() => mockScrollPosition.maxScrollExtent).thenReturn(400);
      final expect = expectLater(
        scrollPositionCubit.stream,
        emits(InView(mockScrollController, initialTime)),
      );

      // Act
      scrollPositionCubit.scrollViewRenderComplete(mockScrollController,
          createdTime: initialTime);

      // Assert
      await expect;
    });

    test('after one hour', () async {
      // Arrange
      when(() => mockScrollController.offset).thenReturn(0);
      when(() => mockScrollController.initialScrollOffset).thenReturn(0);
      when(() => mockScrollPosition.maxScrollExtent).thenReturn(400);

      final expeted = expectLater(
        scrollPositionCubit.stream,
        emitsInOrder([
          InView(mockScrollController, initialTime),
          OutOfView(mockScrollController, initialTime),
        ]),
      );

      // Act
      scrollPositionCubit.scrollViewRenderComplete(mockScrollController,
          createdTime: initialTime);

      ticker.add(initialTime.add(1.hours()).add(5.minutes()));

      // Assert
      await expeted;
    });

    test('Scrolls to correct offset', () async {
      // Arrange
      const initialOffset = 100.0;
      when(() => mockScrollController.initialScrollOffset)
          .thenReturn(initialOffset);
      when(() => mockScrollController.offset).thenReturn(initialOffset);
      when(() => mockScrollPosition.maxScrollExtent).thenReturn(400);
      final measures = TimepillarMeasures(
          TimepillarInterval(start: initialTime, end: initialTime), 1);
      final timePixelOffset = timeToPixels(
        1,
        30,
        measures.dotDistance,
      );
      final nowPos = initialOffset + timePixelOffset;
      final expect1 = expectLater(
        scrollPositionCubit.stream,
        emits(InView(mockScrollController, initialTime)),
      );

      // Act
      scrollPositionCubit.scrollViewRenderComplete(mockScrollController,
          createdTime: initialTime);
      // Assert
      await expect1;

      final expect2 = expectLater(
        scrollPositionCubit.stream,
        emits(OutOfView(mockScrollController, initialTime)),
      );
      // Act
      ticker.add(initialTime.add(1.hours() + 30.minutes()));
      // Assert
      await expect2;

      final expect3 = untilCalled(() => mockScrollController.animateTo(nowPos,
          duration: any(named: 'duration'), curve: any(named: 'curve')));
      // Act
      scrollPositionCubit.goToNow();
      // Assert
      await expect3;
    });
  });
}
