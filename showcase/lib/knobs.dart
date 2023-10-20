import 'package:flutter/material.dart';
import 'package:ui/components/buttons/buttons.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/utils/sizes.dart';
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

Color colorKnob(BuildContext context) {
  final abiliaColors = AbiliaTheme.of(context).colors;
  return context.knobs.list(
    label: 'Color',
    options: [
      abiliaColors.yellow,
      abiliaColors.peach,
      abiliaColors.greyscale,
    ],
    initialOption: abiliaColors.yellow,
    labelBuilder: (color) {
      if (color == abiliaColors.yellow) {
        return 'Yellow';
      }
      if (color == abiliaColors.peach) {
        return 'Peach';
      }
      return 'Greyscale';
    },
  );
}

MediumLargeSize mediumLargeSizeKnob(BuildContext context) {
  return context.knobs.list(
    label: 'Size',
    options: [
      MediumLargeSize.medium,
      MediumLargeSize.large,
    ],
    initialOption: MediumLargeSize.medium,
    labelBuilder: (size) {
      if (size == MediumLargeSize.medium) {
        return 'Medium';
      }
      return 'Large';
    },
  );
}
