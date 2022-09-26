import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/ui/widget_test_keys.dart';

Finder fullDayContainerDescendantFinder(Finder matching) => find.descendant(
      of: find.byKey(TestKey.fullDayContainer),
      matching: matching,
    );
