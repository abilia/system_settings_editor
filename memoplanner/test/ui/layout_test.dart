import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/ui/all.dart';

void main() {
  group('Small layout', () {
    testWidgets('Normal size screen', (WidgetTester tester) async {
      screenSize = const Size(400, 600);
      expect(layout.small, isTrue);
    });

    testWidgets('Square screen', (WidgetTester tester) async {
      screenSize = const Size(400, 400);
      expect(layout.small, isTrue);
    });

    testWidgets('Tiny screen', (WidgetTester tester) async {
      screenSize = const Size(1, 1);
      expect(layout.small, isTrue);
    });

    testWidgets('Long screen', (WidgetTester tester) async {
      screenSize = const Size(200, 10000);
      expect(layout.small, isTrue);
    });

    testWidgets('Wide screen', (WidgetTester tester) async {
      screenSize = const Size(10000, 200);
      expect(layout.small, isTrue);
    });
  });

  group('Medium layout', () {
    testWidgets('Normal size tablet', (WidgetTester tester) async {
      screenSize = const Size(800, 1000);
      expect(layout.medium, isTrue);
    });

    testWidgets('Square tablet', (WidgetTester tester) async {
      screenSize = const Size(800, 800);
      expect(layout.medium, isTrue);
    });

    testWidgets('Small tablet', (WidgetTester tester) async {
      screenSize = const Size(601, 800);
      expect(layout.medium, isTrue);
    });

    testWidgets('Wide tablet', (WidgetTester tester) async {
      screenSize = const Size(10000, 800);
      expect(layout.medium, isTrue);
    });

    testWidgets('Long tablet', (WidgetTester tester) async {
      screenSize = const Size(800, 10000);
      expect(layout.medium, isTrue);
    });
  });

  group('Large layout', () {
    testWidgets('Large screen', (WidgetTester tester) async {
      screenSize = const Size(1600, 2000);
      expect(layout.large, isTrue);
    });

    testWidgets('Square large screen', (WidgetTester tester) async {
      screenSize = const Size(1600, 1600);
      expect(layout.large, isTrue);
    });

    testWidgets('Enormous screen', (WidgetTester tester) async {
      screenSize = const Size(10000, 10000);
      expect(layout.large, isTrue);
    });

    testWidgets('Large and wide screen', (WidgetTester tester) async {
      screenSize = const Size(10000, 1200);
      expect(layout.large, isTrue);
    });

    testWidgets('Large and long screen', (WidgetTester tester) async {
      screenSize = const Size(1200, 10000);
      expect(layout.large, isTrue);
    });
  });
}
