import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';

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

    scrollPositionCubit = ScrollPositionCubit(dayPickerBloc: dayPickerBloc);
    when(() => mockScrollController.position).thenReturn(mockScrollPosition);
    when(() => mockScrollController.positions).thenReturn([mockScrollPosition]);
    when(() => mockScrollController.hasClients).thenReturn(true);
    when(() => mockScrollPosition.minScrollExtent).thenReturn(0.0);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(800.0);
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
    when(() => mockScrollController.positions).thenReturn([]);
    final expect = expectLater(scrollPositionCubit.stream, emits(Unready()));
    // Act
    scrollPositionCubit.updateState(
      scrollController: mockScrollController,
      nowOffset: 0,
      inViewMargin: 0,
    );

    // Assert
    await expect;
  });

  test('InView', () async {
    // Arrange
    when(() => mockScrollController.offset).thenReturn(0.0);
    when(() => mockScrollController.initialScrollOffset).thenReturn(0.0);
    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(InView(mockScrollController, 0.0, 100.0)),
    );

    // Act
    scrollPositionCubit.updateState(
      scrollController: mockScrollController,
      nowOffset: 0,
      inViewMargin: 100,
    );

    // Assert
    await expect;
  });

  test('OutOfView', () async {
    // Arrange
    when(() => mockScrollController.offset).thenReturn(600);
    when(() => mockScrollController.initialScrollOffset).thenReturn(200);
    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(OutOfView(mockScrollController, 200, 100)),
    );

    // Act
    scrollPositionCubit.updateState(
      scrollController: mockScrollController,
      nowOffset: 200,
      inViewMargin: 100,
    );

    // Assert
    await expect;
  });

  test('Just InView top', () async {
    // Arrange
    const init = 200.0;
    const inViewMargin = 20.0;
    when(() => mockScrollController.offset).thenReturn(init - inViewMargin);
    when(() => mockScrollController.initialScrollOffset).thenReturn(init);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(InView(mockScrollController, init, inViewMargin)),
    );
    // Act
    scrollPositionCubit.updateState(
      scrollController: mockScrollController,
      nowOffset: init,
      inViewMargin: inViewMargin,
    );

    // Assert
    await expect;
  });

  test('Just InView bottom', () async {
    // Arrange
    const init = 200.0;
    const inViewMargin = 20.0;
    when(() => mockScrollController.offset).thenReturn(init + inViewMargin);
    when(() => mockScrollController.initialScrollOffset).thenReturn(init);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(InView(mockScrollController, init, inViewMargin)),
    );
    // Act
    scrollPositionCubit.updateState(
      scrollController: mockScrollController,
      nowOffset: init,
      inViewMargin: inViewMargin,
    );

    // Assert
    await expect;
  });

  test('Just OutOfView top', () async {
    // Arrange
    const init = 200.0;
    const inViewMargin = 20.0;
    when(() => mockScrollController.offset).thenReturn(init - inViewMargin - 1);
    when(() => mockScrollController.initialScrollOffset).thenReturn(init);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(OutOfView(mockScrollController, init, inViewMargin)),
    );
    // Act
    scrollPositionCubit.updateState(
      scrollController: mockScrollController,
      nowOffset: init,
      inViewMargin: inViewMargin,
    );

    // Assert
    await expect;
  });

  test('Just OutOfView bottom', () async {
    // Arrange
    const init = 200.0;
    const inViewMargin = 20.0;
    when(() => mockScrollController.offset).thenReturn(init - inViewMargin - 1);
    when(() => mockScrollController.initialScrollOffset).thenReturn(init);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(OutOfView(mockScrollController, init, inViewMargin)),
    );
    // Act
    scrollPositionCubit.updateState(
      scrollController: mockScrollController,
      nowOffset: init,
      inViewMargin: inViewMargin,
    );

    // Assert
    await expect;
  });

  test(
    'InView then scroll down and then OutOfView',
    () async {
      // Arrange
      const nowOffset = 200.0, max = 800.0, inViewMargin = 20.0;
      when(() => mockScrollController.offset).thenReturn(nowOffset);
      when(() => mockScrollController.initialScrollOffset)
          .thenReturn(nowOffset);
      when(() => mockScrollPosition.maxScrollExtent).thenReturn(max);

      final expect = expectLater(
        scrollPositionCubit.stream,
        emits(InView(mockScrollController, nowOffset, inViewMargin)),
      );

      // Act
      scrollPositionCubit.updateState(
        scrollController: mockScrollController,
        nowOffset: nowOffset,
        inViewMargin: inViewMargin,
      );

      // Assert
      await expect;

      final expect2 = expectLater(
        scrollPositionCubit.stream,
        emits(
          OutOfView(
            mockScrollController,
            nowOffset,
            inViewMargin,
          ),
        ),
      );
      // Act
      for (var i = nowOffset; i < max; i++) {
        when(() => mockScrollController.offset).thenReturn(i);
        scrollPositionCubit.scrollPositionUpdated();
      }

      // Assert
      await expect2;
    },
  );

  test('InView then scroll up and then OutOfView', () async {
    const nowOffset = 200.0, max = 800.0, inViewMargin = 20.0;
    // Arrange
    when(() => mockScrollController.offset).thenReturn(nowOffset);
    when(() => mockScrollController.initialScrollOffset).thenReturn(nowOffset);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(max);

    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(InView(mockScrollController, nowOffset, inViewMargin)),
    );
    // Act
    scrollPositionCubit.updateState(
      scrollController: mockScrollController,
      nowOffset: nowOffset,
      inViewMargin: inViewMargin,
    );

    // Assert
    await expect;

    final expect2 = expectLater(
      scrollPositionCubit.stream,
      emits(
        OutOfView(
          mockScrollController,
          nowOffset,
          inViewMargin,
        ),
      ),
    );
    // Act
    for (var i = nowOffset; i > 0; i--) {
      when(() => mockScrollController.offset).thenReturn(i);
      scrollPositionCubit.scrollPositionUpdated();
    }

    // Assert
    await expect2;
  });

  test('Scrolls back', () async {
    // Arrange
    const initialOffset = 100.0, inViewMargin = 20.0;
    when(() => mockScrollController.initialScrollOffset)
        .thenReturn(initialOffset);
    when(() => mockScrollController.offset).thenReturn(200);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(400);
    final expect = untilCalled(() => mockScrollController.animateTo(
        initialOffset,
        duration: any(named: 'duration'),
        curve: any(named: 'curve')));

    // Act
    scrollPositionCubit.updateState(
      scrollController: mockScrollController,
      nowOffset: initialOffset,
      inViewMargin: inViewMargin,
    );
    scrollPositionCubit.goToNow();

    // Assert
    await expect;
  });

  test('Bug SGC-1701 Now button not working correctly', () async {
    const initialOffset = 0.0, inViewMargin = 20.0;

    // Arrange
    when(() => mockScrollController.offset).thenReturn(initialOffset);
    when(() => mockScrollController.initialScrollOffset)
        .thenReturn(initialOffset);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(800);

    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(InView(mockScrollController, initialOffset, inViewMargin)),
    );

    final expect2 = expectLater(
      scrollPositionCubit.stream,
      neverEmits(Unready()),
    );

    // Act
    scrollPositionCubit.updateState(
      scrollController: mockScrollController,
      nowOffset: initialOffset,
      inViewMargin: inViewMargin,
    );
    await scrollPositionCubit.goToNow();
    scrollPositionCubit.close();
    // Assert
    await expect;
    await expect2;
  });
}
