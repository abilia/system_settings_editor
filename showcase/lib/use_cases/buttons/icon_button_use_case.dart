import 'package:flutter/material.dart';
import 'package:showcase/knobs.dart';
import 'package:ui/components/buttons/buttons.dart';
import 'package:widgetbook/widgetbook.dart';

class IconButtonUseCase extends WidgetbookUseCase {
  IconButtonUseCase()
      : super(
          name: 'Icon Button',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SeagullIconButton(
                size: buttonSizeKnob(context),
                border: context.knobs.boolean(
                  label: 'Border',
                  initialValue: true,
                ),
                onPressed: context.knobs.boolean(
                  label: 'Enabled',
                  initialValue: true,
                )
                    ? () {}
                    : null,
                icon: iconKnob(context),
              ),
            ),
          ),
        );
}
