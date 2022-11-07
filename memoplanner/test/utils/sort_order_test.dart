import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/utils/all.dart';

void main() {
  group('Test sort order algorithm', () {
    void expectNext(String start, int step, String expectedNext) =>
        expect(calculateNextSortOrder(start, step), expectedNext);

    test('Stepping to next', () {
      expectNext('A', 1, 'B');
      expectNext('B', 1, 'C');
      expectNext('ABCD', 1, 'ABCE');
      expectNext('}', 1, '}"');
      expectNext('A', -1, '@');
      expectNext('ABCD', 1, 'ABCE');
      expectNext('!', 1, '"');
      expectNext('"', -1, '!}');
      expectNext('!}', 1, '"');
    });
  });
}
