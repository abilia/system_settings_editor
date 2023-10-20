import 'package:flutter/material.dart';
import 'package:showcase/knobs.dart';
import 'package:ui/components/spinner.dart';
import 'package:widgetbook/widgetbook.dart';

class SpinnerUseCase extends WidgetbookUseCase {
  SpinnerUseCase()
      : super(
          name: 'Spinner',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: SeagullSpinner(
              size: mediumLargeSizeKnob(context),
              color: colorKnob(context),
            ),
          ),
        );
}
