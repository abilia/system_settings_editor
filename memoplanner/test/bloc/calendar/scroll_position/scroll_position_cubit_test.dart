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
    final clockCubit = ClockCubit(ticker.stream, initialTime: initialTime);
    final dayPickerBloc = DayPickerBloc(clockCubit: clockCubit);
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
    expect(scrollPositionCubit.state, ScrollPositionUnready());
  });

  test(
      'after event ListViewRenderComplete still ScrollPositionUnready '
      'if ScrollController has no Clients', () async {
    // Arrange
    when(() => mockScrollController.positions).thenReturn([]);
    final expect =
        expectLater(scrollPositionCubit.stream, emits(ScrollPositionUnready()));
    // Act
    scrollPositionCubit.updateState(
      scrollController: mockScrollController,
      nowOffset: 0,
    );

    // Assert
    await expect;
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
    scrollPositionCubit
      ..updateState(
        scrollController: mockScrollController,
        nowOffset: initialOffset,
      )
      ..goToNow();

    // Assert
    await expect;
  });

  test('SGC-1701 - Go to now is working correctly', () async {
    const initialOffset = 0.0;

    // Arrange
    when(() => mockScrollController.offset).thenReturn(initialOffset);
    when(() => mockScrollController.initialScrollOffset)
        .thenReturn(initialOffset);
    when(() => mockScrollPosition.maxScrollExtent).thenReturn(800);

    final expect = expectLater(
      scrollPositionCubit.stream,
      emits(ScrollPositionReady(mockScrollController, initialOffset)),
    );

    final expect2 = expectLater(
      scrollPositionCubit.stream,
      neverEmits(ScrollPositionUnready()),
    );

    // Act
    scrollPositionCubit.updateState(
      scrollController: mockScrollController,
      nowOffset: initialOffset,
    );
    await scrollPositionCubit.goToNow();
    scrollPositionCubit.close();
    // Assert
    await expect;
    await expect2;
  });
}
