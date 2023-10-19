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
            child: Center(
              child: SeagullSpinner(
                size: context.knobs.list(
                  label: 'Size',
                  options: [
                    SpinnerSize.small,
                    SpinnerSize.medium,
                  ],
                  initialOption: SpinnerSize.small,
                  labelBuilder: (size) {
                    if (size == SpinnerSize.small) {
                      return 'Small';
                    }
                    return 'Medium';
                  },
                ),
                color: colorKnob(context),
              ),
            ),
          ),
        );
}
