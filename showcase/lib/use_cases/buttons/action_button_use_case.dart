import 'package:flutter/material.dart';
import 'package:showcase/knobs.dart';
import 'package:ui/components/buttons/buttons.dart';
import 'package:widgetbook/widgetbook.dart';

class ActionButtonUseCase extends WidgetbookUseCase {
  ActionButtonUseCase()
      : super(
          name: 'Action Button',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                width: context.knobs.boolean(
                  label: 'Expanded',
                  initialValue: false,
                )
                    ? double.infinity
                    : null,
                child: SeagullActionButton(
                  type: context.knobs.list(
                    label: 'Type',
                    options: [
                      ActionButtonType.primary,
                      ActionButtonType.secondary,
                      ActionButtonType.tertiary,
                      ActionButtonType.tertiaryNoBorder,
                    ],
                    initialOption: ActionButtonType.primary,
                    labelBuilder: (style) {
                      if (style == ActionButtonType.primary) {
                        return 'Primary';
                      }
                      if (style == ActionButtonType.secondary) {
                        return 'Secondary';
                      }
                      if (style == ActionButtonType.tertiary) {
                        return 'Tertiary';
                      }
                      return 'Tertiary no border';
                    },
                  ),
                  size: buttonSizeKnob(context),
                  text: textKnob(context),
                  isLoading: context.knobs.boolean(
                    label: 'Loading',
                    initialValue: false,
                  ),
                  onPressed: context.knobs.boolean(
                    label: 'Enabled',
                    initialValue: true,
                  )
                      ? () {}
                      : null,
                  leadingIcon: context.knobs.boolean(
                    label: 'Leading icon',
                    initialValue: true,
                  )
                      ? Icons.login
                      : null,
                  trailingIcon: context.knobs.boolean(
                    label: 'Trailing icon',
                    initialValue: false,
                  )
                      ? Icons.login
                      : null,
                ),
              ),
            ),
          ),
        );
}
