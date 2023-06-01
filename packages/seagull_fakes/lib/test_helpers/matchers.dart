import 'package:calendar_events/calendar_events.dart';
import 'package:collection/collection.dart';
import 'package:test/test.dart';

Function unorderedDeepEq = const DeepCollectionEquality.unordered().equals;

class MatchActivitiesWithoutId extends Matcher {
  final Iterable<Activity> _expected;
  const MatchActivitiesWithoutId(Iterable<Activity> expected)
      : _expected = expected;

  @override
  bool matches(item, Map matchState) {
    Iterable<Activity>? activities;
    if (item is Iterable<Activity>) activities = item;
    if (activities == null) return false;
    final actual = activities.map((a) => a.props.sublist(1));
    final exptected = _expected.map((a) => a.props.sublist(1));
    return unorderedDeepEq(actual, exptected);
  }

  @override
  Description describe(Description description) => description
      .add('same ActivitiesLoaded but ignores all Activity.id ')
      .addDescriptionOf(_expected);

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription.add(' is not same');
  }
}

Function deepEq = const DeepCollectionEquality().equals;

class MatchActivityWithoutId extends Matcher {
  final Activity _expected;
  const MatchActivityWithoutId(Activity expected) : _expected = expected;

  @override
  bool matches(item, Map matchState) {
    if (item is Activity) {
      return deepEq(item.props.sublist(2), _expected.props.sublist(2));
    }
    return false;
  }

  @override
  Description describe(Description description) => description
      .add('Check activity is same expect Activity.id ')
      .addDescriptionOf(_expected);

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is Activity) {
      final props = item.props.sublist(2).toSet();
      final exptectedProps = _expected.props.sublist(2).toSet();
      final diff = exptectedProps.difference(props);
      final diff2 = props.difference(exptectedProps);

      return mismatchDescription.add('exptexted: $diff is not same as  $diff2');
    }

    return mismatchDescription.add('${item.runtimeType} is not activity');
  }
}
