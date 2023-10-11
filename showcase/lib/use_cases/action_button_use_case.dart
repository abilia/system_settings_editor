import 'package:flutter/material.dart';
import 'package:ui/components/action_button/action_button.dart';
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
                child: _actionButtonFromType(
                  type: context.knobs.list(
                    label: 'Button style',
                    options: [
                      ActionButtonPrimary,
                      ActionButtonSecondary,
                      ActionButtonTertiary,
                    ],
                    initialOption: ActionButtonPrimary,
                    labelBuilder: (style) {
                      if (style == ActionButtonPrimary) {
                        return 'Primary';
                      }
                      if (style == ActionButtonSecondary) {
                        return 'Secondary';
                      }
                      return 'Tertiary';
                    },
                  ),
                  text: context.knobs.string(
                    label: 'Button title',
                    initialValue: 'Title',
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

  static Widget _actionButtonFromType({
    required Type type,
    required String text,
    required IconData? leadingIcon,
    required IconData? trailingIcon,
    required VoidCallback? onPressed,
  }) {
    if (type == ActionButtonPrimary) {
      return ActionButtonPrimary(
        text: text,
        onPressed: onPressed,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
      );
    }
    if (type == ActionButtonSecondary) {
      return ActionButtonSecondary(
        text: text,
        onPressed: onPressed,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
      );
    }
    return ActionButtonTertiary(
      text: text,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
    );
  }
}
