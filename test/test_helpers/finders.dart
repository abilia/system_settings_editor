import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/ui/all.dart';

Finder fullDayContainerDescendantFinder(Finder matching) => find.descendant(
      of: find.byType(FullDayContainer),
      matching: matching,
    );
