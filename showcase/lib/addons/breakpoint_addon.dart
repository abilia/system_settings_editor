import 'package:flutter/material.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:widgetbook/widgetbook.dart';

class BreakpointAddon extends WidgetbookAddon<double> {
  BreakpointAddon()
      : super(
          name: 'Breakpoint',
          initialSetting: 350,
        );

  static final _breakpoints = {
    350.0: 'Mobile',
    700.0: 'Tablet',
    1400.0: 'Desktop small',
    2000.0: 'Desktop large',
  };

  @override
  List<Field<double>> get fields {
    return [
      ListField<double>(
        name: 'breakpoint',
        initialValue: initialSetting,
        values: _breakpoints.keys.toList(),
        labelBuilder: (value) => _breakpoints[value].toString(),
      )
    ];
  }

  @override
  double valueFromQueryGroup(Map<String, String> group) {
    return valueOf<double>('breakpoint', group)!;
  }

  @override
  Widget buildUseCase(BuildContext context, Widget child, double setting) {
    return MaterialApp(
      theme: AbiliaTheme.getThemeData(setting),
      home: child,
    );
  }
}
