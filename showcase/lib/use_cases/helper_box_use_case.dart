import 'package:flutter/material.dart';
import 'package:showcase/knobs.dart';
import 'package:ui/components/helper_box.dart';
import 'package:widgetbook/widgetbook.dart';

class HelperBoxUseCase extends WidgetbookUseCase {
  HelperBoxUseCase()
      : super(
          name: 'Helper Box',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: SeagullHelperBox(
              size: mediumLargeSizeKnob(context),
              text: textKnob(context),
              icon: nullableIconKnob(context),
              state: messageStateKnob(context),
            ),
          ),
        );
}
