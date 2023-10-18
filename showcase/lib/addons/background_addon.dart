import 'package:flutter/material.dart';
import 'package:ui/tokens/colors.dart';
import 'package:widgetbook/widgetbook.dart';

class BackgroundAddon extends WidgetbookAddon<Color> {
  BackgroundAddon()
      : super(
          name: 'Background',
          initialSetting: AbiliaColors.greyscale.shade900,
        );

  static final _colors = {
    AbiliaColors.greyscale.shade900: 'Black',
    AbiliaColors.greyscale.shade500: 'Grey',
    AbiliaColors.greyscale.shade200: 'White',
  };

  @override
  List<Field<Color>> get fields {
    return [
      ListField<Color>(
        name: 'background',
        initialValue: initialSetting,
        values: _colors.keys.toList(),
        labelBuilder: (value) => _colors[value].toString(),
      )
    ];
  }

  @override
  Color valueFromQueryGroup(Map<String, String> group) {
    return valueOf<Color>('background', group)!;
  }

  @override
  Widget buildUseCase(BuildContext context, Widget child, Color setting) {
    return ColoredBox(
      color: setting,
      child: child,
    );
  }
}
