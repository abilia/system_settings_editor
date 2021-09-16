import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../fakes/fakes_blocs.dart';
import '../../../mocks/shared.mocks.dart';

void main() {
  late ScrollPositionBloc scrollPositionBloc;
  late MockScrollController mockScrollController;
  late MockScrollPosition mockScrollPosition;
  late StreamController<DateTime> ticker;
  final initialTime = DateTime(2020, 12, 24, 15, 00);

  setUp(() {
    ticker = StreamController<DateTime>();
    final clockBloc = ClockBloc(ticker.stream, initialTime: initialTime);
    final dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
    mockScrollController = MockScrollController();
    mockScrollPosition = MockScrollPosition();

    scrollPositionBloc = ScrollPositionBloc(
      dayPickerBloc: dayPickerBloc,
      clockBloc: clockBloc,
      timepillarBloc: FakeTimepillarBloc(),
    );
    when(mockScrollController.position).thenReturn(mockScrollPosition);
    when(mockScrollController.hasClients).thenReturn(true);
  });

  test('initial state is Unready', () {
    // Assert
    expect(scrollPositionBloc.state, Unready());
  });

  test(
      'after event ListViewRenderComplete still Unready if ScrollController has no Clients',
      () async {
    // Arrange
    when(mockScrollController.hasClients).thenReturn(false);
    // Act
    scrollPositionBloc.add(ScrollViewRenderComplete(mockScrollController));

    // Assert
    await expectLater(scrollPositionBloc.stream, emits(Unready()));
  });

  test('InView', () async {
    // Arrange
    when(mockScrollController.offset).thenReturn(0);
    when(mockScrollController.initialScrollOffset).thenReturn(0);
    when(mockScrollPosition.maxScrollExtent).thenReturn(800);

    // Act
    scrollPositionBloc.add(ScrollViewRenderComplete(mockScrollController));

    // Assert
    await expectLater(
      scrollPositionBloc.stream,
      emits(InView(mockScrollController)),
    );
  });

  test('OutOfView', () async {
    // Arrange
    when(mockScrollController.offset).thenReturn(600);
    when(mockScrollController.initialScrollOffset).thenReturn(200);
    when(mockScrollPosition.maxScrollExtent).thenReturn(800);

    // Act
    scrollPositionBloc.add(ScrollViewRenderComplete(mockScrollController));

    // Assert
    await expectLater(
      scrollPositionBloc.stream,
      emits(OutOfView(mockScrollController)),
    );
  });

  test('Just InView top', () async {
    // Arrange
    const init = 200.0;
    when(mockScrollController.offset)
        .thenReturn(init - scrollPositionBloc.nowMarginBottom);
    when(mockScrollController.initialScrollOffset).thenReturn(init);
    when(mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
    // Act
    scrollPositionBloc.add(ScrollViewRenderComplete(mockScrollController));

    // Assert
    await expectLater(
      scrollPositionBloc.stream,
      emits(InView(mockScrollController)),
    );
  });

  test('Just InView bottom', () async {
    // Arrange
    const init = 200.0;
    when(mockScrollController.offset)
        .thenReturn(init + scrollPositionBloc.nowMarginTop);
    when(mockScrollController.initialScrollOffset).thenReturn(init);
    when(mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
    // Act
    scrollPositionBloc.add(ScrollViewRenderComplete(mockScrollController));

    // Assert
    await expectLater(
      scrollPositionBloc.stream,
      emits(InView(mockScrollController)),
    );
  });

  test('Just OutView top', () async {
    // Arrange
    const init = 200.0;
    when(mockScrollController.offset)
        .thenReturn(init - scrollPositionBloc.nowMarginBottom - 1);
    when(mockScrollController.initialScrollOffset).thenReturn(init);
    when(mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
    // Act
    scrollPositionBloc.add(ScrollViewRenderComplete(mockScrollController));

    // Assert
    await expectLater(
      scrollPositionBloc.stream,
      emits(OutOfView(mockScrollController)),
    );
  });

  test('Just OutOfView bottom', () async {
    // Arrange
    const init = 200.0;
    when(mockScrollController.offset)
        .thenReturn(init + scrollPositionBloc.nowMarginTop + 1);
    when(mockScrollController.initialScrollOffset).thenReturn(init);
    when(mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
    // Act
    scrollPositionBloc.add(ScrollViewRenderComplete(mockScrollController));

    // Assert
    await expectLater(
      scrollPositionBloc.stream,
      emits(OutOfView(mockScrollController)),
    );
  });

  test(
    'InView then scroll down and then OutOfView',
    () async {
      // Arrange
      const activityAt = 200.0, max = 800.0;
      when(mockScrollController.offset).thenReturn(activityAt);
      when(mockScrollController.initialScrollOffset).thenReturn(activityAt);
      when(mockScrollPosition.maxScrollExtent).thenReturn(max);

      // Act
      scrollPositionBloc.add(ScrollViewRenderComplete(mockScrollController));

      // Assert
      await expectLater(
        scrollPositionBloc.stream,
        emits(InView(mockScrollController)),
      );

      // Act
      for (var i = activityAt; i < max; i++) {
        when(mockScrollController.offset).thenReturn(i);
        scrollPositionBloc.add(ScrollPositionUpdated());
      }

      // Assert
      await expectLater(
        scrollPositionBloc.stream,
        emits(OutOfView(mockScrollController)),
      );
    },
  );

  test('InView then scroll up and then OutOfView', () async {
    const activityAt = 200.0, max = 800.0;
    // Arrange
    when(mockScrollController.offset).thenReturn(activityAt);
    when(mockScrollController.initialScrollOffset).thenReturn(activityAt);
    when(mockScrollPosition.maxScrollExtent).thenReturn(max);

    // Act
    scrollPositionBloc.add(ScrollViewRenderComplete(mockScrollController));

    // Assert
    await expectLater(
      scrollPositionBloc.stream,
      emits(InView(mockScrollController)),
    );

    // Act
    for (var i = activityAt; i > 0; i--) {
      when(mockScrollController.offset).thenReturn(i);
      scrollPositionBloc.add(ScrollPositionUpdated());
    }

    // Assert
    await expectLater(
      scrollPositionBloc.stream,
      emits(OutOfView(mockScrollController)),
    );
  });

  test('Scrolls back', () async {
    // Arrange
    const initialOffset = 100.0;
    when(mockScrollController.initialScrollOffset).thenReturn(initialOffset);
    when(mockScrollController.offset).thenReturn(200);
    when(mockScrollPosition.maxScrollExtent).thenReturn(400);

    // Act
    scrollPositionBloc.add(ScrollViewRenderComplete(mockScrollController));
    scrollPositionBloc.add(GoToNow());

    // Assert
    await untilCalled(mockScrollController.animateTo(initialOffset,
        duration: anyNamed('duration'), curve: anyNamed('curve')));
  });

  group('go to now follows now', () {
    test('createdTime', () async {
      // Arrange
      when(mockScrollController.offset).thenReturn(0);
      when(mockScrollController.initialScrollOffset).thenReturn(0);
      when(mockScrollPosition.maxScrollExtent).thenReturn(400);

      // Act
      scrollPositionBloc.add(ScrollViewRenderComplete(mockScrollController,
          createdTime: initialTime));
      // ticker.add(createdTime.add(1.minutes()));

      // Assert
      await expectLater(
        scrollPositionBloc.stream,
        emits(InView(mockScrollController, initialTime)),
      );
    });

    test('after one hour', () async {
      // Arrange
      when(mockScrollController.offset).thenReturn(0);
      when(mockScrollController.initialScrollOffset).thenReturn(0);
      when(mockScrollPosition.maxScrollExtent).thenReturn(400);

      // Act
      scrollPositionBloc.add(ScrollViewRenderComplete(mockScrollController,
          createdTime: initialTime));
      ticker.add(initialTime.add(1.hours()));

      // Assert
      await expectLater(
        scrollPositionBloc.stream,
        emitsInOrder([
          InView(mockScrollController, initialTime),
          OutOfView(mockScrollController, initialTime),
        ]),
      );
    });

    test('Scrolls to correct offset', () async {
      // Arrange
      const initialOffset = 100.0;
      when(mockScrollController.initialScrollOffset).thenReturn(initialOffset);
      when(mockScrollController.offset).thenReturn(initialOffset);
      when(mockScrollPosition.maxScrollExtent).thenReturn(400);
      final ts = TimepillarState(
          TimepillarInterval(start: DateTime.now(), end: DateTime.now()), 1);
      final timePixelOffset = timeToPixels(
        1,
        30,
        ts.dotDistance,
      );
      final nowPos = initialOffset + timePixelOffset;

      // Act
      scrollPositionBloc.add(ScrollViewRenderComplete(mockScrollController,
          createdTime: initialTime));
      // Assert
      await expectLater(
        scrollPositionBloc.stream,
        emits(InView(mockScrollController, initialTime)),
      );

      // Act
      ticker.add(initialTime.add(1.hours() + 30.minutes()));
      // Assert
      await expectLater(
        scrollPositionBloc.stream,
        emits(OutOfView(mockScrollController, initialTime)),
      );

      // Act
      scrollPositionBloc.add(GoToNow());
      // Assert
      await untilCalled(mockScrollController.animateTo(nowPos,
          duration: anyNamed('duration'), curve: anyNamed('curve')));
    });
  });
}
