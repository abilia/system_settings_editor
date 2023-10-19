import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

class BackgroundAddon extends WidgetbookAddon<Color> {
  BackgroundAddon()
      : super(
          name: 'Background',
          initialSetting: Colors.black87,
        );

  static final _colors = {
    Colors.black87: 'Black',
    Colors.grey: 'Grey',
    Colors.white: 'White',
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
