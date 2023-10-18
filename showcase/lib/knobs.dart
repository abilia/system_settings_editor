import 'package:flutter/material.dart';
import 'package:ui/components/buttons/buttons.dart';
import 'package:ui/tokens/colors.dart';
import 'package:widgetbook/widgetbook.dart';

IconData iconKnob(BuildContext context) => context.knobs.list(
      label: 'Icon',
      options: [
        Icons.add,
        Icons.edit,
        Icons.delete,
        Icons.login,
      ],
      initialOption: Icons.add,
      labelBuilder: (icon) {
        if (icon == Icons.add) {
          return 'Add';
        }
        if (icon == Icons.edit) {
          return 'Edit';
        }
        if (icon == Icons.delete) {
          return 'Delete';
        }
        return 'Login';
      },
    );

String textKnob(BuildContext context) => context.knobs.string(
      label: 'Text',
      initialValue: 'Text',
    );

ButtonSize buttonSizeKnob(BuildContext context) => context.knobs.list(
      label: 'Size',
      options: [
        ButtonSize.small,
        ButtonSize.medium,
        ButtonSize.large,
      ],
      initialOption: ButtonSize.small,
      labelBuilder: (size) {
        if (size == ButtonSize.small) {
          return 'Small';
        }
        if (size == ButtonSize.medium) {
          return 'Medium';
        }
        return 'Large';
      },
    );

Color colorKnob(BuildContext context) => context.knobs.list(
      label: 'Color',
      options: [
        AbiliaColors.yellow,
        AbiliaColors.peach,
        AbiliaColors.greyscale,
      ],
      initialOption: AbiliaColors.yellow,
      labelBuilder: (color) {
        if (color == AbiliaColors.yellow) {
          return 'Yellow';
        }
        if (color == AbiliaColors.peach) {
          return 'Peach';
        }
        return 'Greyscale';
      },
    );
