import 'package:flutter/rendering.dart';
import 'package:meta/meta.dart';

import '../all.dart';

/// Immutable layout constraints for overlay
class OverlayConstraints extends BoxConstraints {
  OverlayConstraints({
    @required this.state,
    @required BoxConstraints boxConstraints,
  })  : assert(state != null),
        assert(boxConstraints != null),
        super(
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
  bool operator ==(dynamic other) {
    assert(debugAssertIsValid());
    if (identical(this, other)) return true;
    if (other is! OverlayConstraints) return false;
    final OverlayConstraints typedOther = other;
    assert(typedOther.debugAssertIsValid());
    return state == typedOther.state &&
        minWidth == typedOther.minWidth &&
        maxWidth == typedOther.maxWidth &&
        minHeight == typedOther.minHeight &&
        maxHeight == typedOther.maxHeight;
  }

  @override
  int get hashCode {
    assert(debugAssertIsValid());
    return hashValues(minWidth, maxWidth, minHeight, maxHeight, state);
  }
}
