import 'dart:math' as math;

import 'package:memoplanner/ui/all.dart';

class AbiliaSlider extends StatelessWidget {
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final Widget? leading;
  final double? height, width;
  final double value;
  final int? divisions;
  final double min, max;
  static final defaultHeight = layout.slider.defaultHeight;

  const AbiliaSlider({
    Key? key,
    this.onChanged,
    this.onChangeEnd,
    this.leading,
    this.height,
    this.width,
    this.value = 1.0,
    this.divisions,
    this.min = 0,
    this.max = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    return Container(
      height: height ?? defaultHeight,
      width: width,
      decoration:
          onChanged != null ? whiteBoxDecoration : disabledBoxDecoration,
      padding: EdgeInsets.only(
        left: layout.slider.leftPadding,
        right: layout.slider.rightPadding,
      ),
      child: Row(
        children: <Widget>[
          if (leading != null)
            Padding(
              padding: EdgeInsets.only(right: layout.slider.iconRightPadding),
              child: leading,
            ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: AbiliaThumbShape(
                  enabledThumbRadius: layout.slider.thumbRadius,
                  elevation: layout.slider.elevation,
                  pressedElevation: layout.slider.pressedElevation,
                  outerBorder: layout.slider.outerBorder,
                ),
                trackHeight: layout.slider.trackHeight,
                inactiveTrackColor: AbiliaColors.white120,
              ),
              child: Slider(
                divisions: divisions,
                onChanged: onChanged,
                onChangeEnd: onChangeEnd,
                value: value,
                min: min,
                max: max,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Copied from [RoundSliderThumbShape]. Just added parameters for border

/// The default shape of a [Slider]'s thumb.
///
/// There is a shadow for the resting, pressed, hovered, and focused state.
///
/// ![A slider widget, consisting of 5 divisions and showing the round slider thumb shape.]
/// (https://flutter.github.io/assets-for-api-docs/assets/material/round_slider_thumb_shape.png)
///
/// See also:
///
///  * [Slider], which includes a thumb defined by this shape.
///  * [SliderTheme], which can be used to configure the thumb shape of all
///    sliders in a widget subtree.
class AbiliaThumbShape extends SliderComponentShape {
  /// Create a slider thumb that draws a circle.
  const AbiliaThumbShape({
    this.enabledThumbRadius = 10.0,
    this.disabledThumbRadius,
    this.elevation = 1.0,
    this.pressedElevation = 6.0,
    this.outerBorder = 0.0,
    this.borderColor = Colors.white,
  });

  /// The preferred radius of the round thumb shape when the slider is enabled.
  ///
  /// If it is not provided, then the material default of 10 is used.
  final double enabledThumbRadius;

  /// The preferred radius of the round thumb shape when the slider is disabled.
  ///
  /// If no disabledRadius is provided, then it is equal to the
  /// [enabledThumbRadius]
  final double? disabledThumbRadius;

  double get _disabledThumbRadius => disabledThumbRadius ?? enabledThumbRadius;

  /// The resting elevation adds shadow to the unpressed thumb.
  ///
  /// The default is 1.
  ///
  /// Use 0 for no shadow. The higher the value, the larger the shadow. For
  /// example, a value of 12 will create a very large shadow.
  ///
  final double elevation;

  /// The pressed elevation adds shadow to the pressed thumb.
  ///
  /// The default is 6.
  ///
  /// Use 0 for no shadow. The higher the value, the larger the shadow. For
  /// example, a value of 12 will create a very large shadow.
  final double pressedElevation;

  /// Size of the outer border of the shape
  ///
  /// The default is 0.
  ///
  /// Use 0 for no border
  final double outerBorder;

  /// Color of the outer border of the shape
  ///
  /// The default is white.
  final Color borderColor;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(
        isEnabled == true ? enabledThumbRadius : _disabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    assert(sliderTheme.disabledThumbColor != null);
    assert(sliderTheme.thumbColor != null);

    final Canvas canvas = context.canvas;
    final Tween<double> radiusTween = Tween<double>(
      begin: _disabledThumbRadius,
      end: enabledThumbRadius,
    );
    final ColorTween colorTween = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    );

    final Color color = colorTween.evaluate(enableAnimation)!;
    final double radius = radiusTween.evaluate(enableAnimation);

    final Tween<double> elevationTween = Tween<double>(
      begin: elevation,
      end: pressedElevation,
    );

    final double evaluatedElevation =
        elevationTween.evaluate(activationAnimation);

    canvas.drawCircle(
      center,
      radius + outerBorder,
      Paint()..color = borderColor,
    );

    final Path path = Path()
      ..addArc(
          Rect.fromCenter(
              center: center, width: 2 * radius, height: 2 * radius),
          0,
          math.pi * 2);
    canvas
      ..drawShadow(path, Colors.black, evaluatedElevation, true)
      ..drawCircle(
        center,
        radius,
        Paint()..color = color,
      );
  }
}
