import 'package:flutter/rendering.dart';
import 'package:memoplanner/ui/components/calendar/timepillar/overlay/all.dart';

/// Immutable layout constraints for overlay
class OverlayConstraints extends BoxConstraints {
  OverlayConstraints({
    required this.state,
    required BoxConstraints boxConstraints,
  }) : super(
          minWidth: boxConstraints.minWidth,
          maxWidth: boxConstraints.maxWidth,
          minHeight: boxConstraints.minHeight,
          maxHeight: boxConstraints.maxHeight,
        );

  final SliverOverlayState state;

  @override
  bool get isNormalized =>
      state.scrollPercentage >= 0.0 &&
      state.scrollPercentage <= 1.0 &&
      super.isNormalized;

  @override
  bool operator ==(other) {
    assert(debugAssertIsValid());
    if (identical(this, other)) return true;
    if (other is! OverlayConstraints) return false;
    assert(other.debugAssertIsValid());
    return state == other.state &&
        minWidth == other.minWidth &&
        maxWidth == other.maxWidth &&
        minHeight == other.minHeight &&
        maxHeight == other.maxHeight;
  }

  @override
  int get hashCode {
    assert(debugAssertIsValid());
    return Object.hash(minWidth, maxWidth, minHeight, maxHeight, state);
  }
}
