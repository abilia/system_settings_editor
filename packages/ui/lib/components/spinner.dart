import 'package:flutter/material.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/themes/spinner/spinner_themes.dart';

enum SpinnerSize { small, medium }

class SeagullSpinner extends StatelessWidget {
  final SpinnerSize size;
  final Color? color;

  const SeagullSpinner({
    required this.size,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final seagullSpinnerTheme = _getTheme(context);
    return Padding(
      padding: EdgeInsets.all(seagullSpinnerTheme.padding),
      child: SizedBox.square(
        dimension: seagullSpinnerTheme.size,
        child: CircularProgressIndicator(
          strokeWidth: seagullSpinnerTheme.thickness,
          color: color,
        ),
      ),
    );
  }

  SeagullSpinnerTheme _getTheme(BuildContext context) {
    final abiliaTheme = AbiliaTheme.of(context);
    switch (size) {
      case SpinnerSize.small:
        return abiliaTheme.spinner.small;
      case SpinnerSize.medium:
        return abiliaTheme.spinner.medium;
    }
  }
}
