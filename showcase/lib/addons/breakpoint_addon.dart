import 'package:flutter/material.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:widgetbook/widgetbook.dart';

class BreakpointAddon extends WidgetbookAddon<double> {
  BreakpointAddon({
    double breakpoint = 300,
  }) : super(
          name: 'Breakpoint',
          initialSetting: breakpoint,
        );

  static final _breakpoints = {
    300.0: 'Mobile',
    500.0: 'Tablet',
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
