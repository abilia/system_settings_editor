import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';

class MockScrollController extends Mock implements ScrollController {}

class MockScrollPosition extends Mock implements ScrollPosition {}

void main() {
  ScrollPositionBloc scrollPositionBloc;
  MockScrollController mockScrollController;
  MockScrollPosition mockScrollPosition;

  group(
    'ScrollPositionBloc',
    () {
      setUp(
        () {
          mockScrollController = MockScrollController();
          mockScrollPosition = MockScrollPosition();
          scrollPositionBloc = ScrollPositionBloc();
          when(mockScrollController.position).thenReturn(mockScrollPosition);
          when(mockScrollController.hasClients).thenReturn(true);
        },
      );

      test(
        'initial state is Unready',
        () {
          // Assert
          expect(scrollPositionBloc.initialState, Unready());
          expectLater(
            scrollPositionBloc,
            emitsInOrder([
              Unready(),
            ]),
          );
        },
      );

      test(
        'after event ListViewRenderComplete still Unready if ScrollController has no Clients',
        () async {
          // Arrange
          when(mockScrollController.hasClients).thenReturn(false);
          // Act
          scrollPositionBloc.add(ListViewRenderComplete(mockScrollController));

          // Assert
          await expectLater(
            scrollPositionBloc,
            emitsInOrder([
              Unready(),
            ]),
          );
        },
      );

      test(
        'InView',
        () async {
          // Arrange
          when(mockScrollController.offset).thenReturn(0);
          when(mockScrollController.initialScrollOffset).thenReturn(0);
          when(mockScrollPosition.maxScrollExtent).thenReturn(800);

          // Act
          scrollPositionBloc.add(ListViewRenderComplete(mockScrollController));

          // Assert
          await expectLater(
            scrollPositionBloc,
            emitsInOrder([
              Unready(),
              InView(mockScrollController),
            ]),
          );
        },
      );

      test(
        'OutOfView',
        () async {
          // Arrange
          when(mockScrollController.offset).thenReturn(600);
          when(mockScrollController.initialScrollOffset).thenReturn(200);
          when(mockScrollPosition.maxScrollExtent).thenReturn(800);

          // Act
          scrollPositionBloc.add(ListViewRenderComplete(mockScrollController));

          // Assert
          await expectLater(
            scrollPositionBloc,
            emitsInOrder([
              Unready(),
              OutOfView(mockScrollController),
            ]),
          );
        },
      );

      test(
        'Just InView top',
        () async {
          // Arrange
          final init = 200.0;
          when(mockScrollController.offset)
              .thenReturn(init - scrollPositionBloc.fromBotton);
          when(mockScrollController.initialScrollOffset).thenReturn(init);
          when(mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
          // Act
          scrollPositionBloc.add(ListViewRenderComplete(mockScrollController));

          // Assert
          await expectLater(
            scrollPositionBloc,
            emitsInOrder([
              Unready(),
              InView(mockScrollController),
            ]),
          );
        },
      );

      test(
        'Just InView bottom',
        () async {
          // Arrange
          final init = 200.0;
          when(mockScrollController.offset)
              .thenReturn(init + scrollPositionBloc.fromTop);
          when(mockScrollController.initialScrollOffset).thenReturn(init);
          when(mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
          // Act
          scrollPositionBloc.add(ListViewRenderComplete(mockScrollController));

          // Assert
          await expectLater(
            scrollPositionBloc,
            emitsInOrder([
              Unready(),
              InView(mockScrollController),
            ]),
          );
        },
      );

      test(
        'Just OutView top',
        () async {
          // Arrange
          final init = 200.0;
          when(mockScrollController.offset)
              .thenReturn(init - scrollPositionBloc.fromBotton - 1);
          when(mockScrollController.initialScrollOffset).thenReturn(init);
          when(mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
          // Act
          scrollPositionBloc.add(ListViewRenderComplete(mockScrollController));

          // Assert
          await expectLater(
            scrollPositionBloc,
            emitsInOrder([
              Unready(),
              OutOfView(mockScrollController),
            ]),
          );
        },
      );

      test(
        'Just OutOfView bottom',
        () async {
          // Arrange
          final init = 200.0;
          when(mockScrollController.offset)
              .thenReturn(init + scrollPositionBloc.fromTop + 1);
          when(mockScrollController.initialScrollOffset).thenReturn(init);
          when(mockScrollPosition.maxScrollExtent).thenReturn(init * 4);
          // Act
          scrollPositionBloc.add(ListViewRenderComplete(mockScrollController));

          // Assert
          await expectLater(
            scrollPositionBloc,
            emitsInOrder([
              Unready(),
              OutOfView(mockScrollController),
            ]),
          );
        },
      );

      test(
        'InView then scroll down and then OutOfView',
        () async {
          // Arrange
          final activityAt = 200.0, max = 800.0;
          when(mockScrollController.offset).thenReturn(activityAt);
          when(mockScrollController.initialScrollOffset).thenReturn(activityAt);
          when(mockScrollPosition.maxScrollExtent).thenReturn(max);

          // Act
          scrollPositionBloc.add(ListViewRenderComplete(mockScrollController));

          // Assert
          await expectLater(
            scrollPositionBloc,
            emitsInOrder([
              Unready(),
              InView(mockScrollController),
            ]),
          );

          // Act
          for (var i = activityAt; i < max; i++) {
            when(mockScrollController.offset).thenReturn(i);
            scrollPositionBloc.add(ScrollPositionUpdated(i));
          }

          // Assert
          await expectLater(
            scrollPositionBloc,
            emitsInOrder([
              InView(mockScrollController),
              OutOfView(mockScrollController),
            ]),
          );
        },
      );

      test(
        'InView then scroll up and then OutOfView',
        () async {
          final activityAt = 200.0, max = 800.0;
          // Arrange
          when(mockScrollController.offset).thenReturn(activityAt);
          when(mockScrollController.initialScrollOffset).thenReturn(activityAt);
          when(mockScrollPosition.maxScrollExtent).thenReturn(max);

          // Act
          scrollPositionBloc.add(ListViewRenderComplete(mockScrollController));

          // Assert
          await expectLater(
            scrollPositionBloc,
            emitsInOrder([
              Unready(),
              InView(mockScrollController),
            ]),
          );

          // Act
          for (var i = activityAt; i > 0; i--) {
            when(mockScrollController.offset).thenReturn(i);
            scrollPositionBloc.add(ScrollPositionUpdated(i));
          }

          // Assert
          await expectLater(
            scrollPositionBloc,
            emitsInOrder([
              InView(mockScrollController),
              OutOfView(mockScrollController),
            ]),
          );
        },
      );
    },
  );
}
