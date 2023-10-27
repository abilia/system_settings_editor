import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ui/components/buttons/buttons.dart';
import 'package:ui/themes/abilia_theme.dart';
import 'package:ui/utils/sizes.dart';
import 'package:ui/utils/states.dart';
import 'package:widgetbook/widgetbook.dart';

IconData? nullableIconKnob(BuildContext context) => context.knobs.boolean(
      label: 'Show icon',
      initialValue: true,
    )
        ? iconKnob(context)
        : null;

IconData iconKnob(BuildContext context) => context.knobs.list(
      label: 'Icon',
      options: [
        Symbols.add,
        Symbols.edit,
        Symbols.delete,
        Symbols.login,
      ],
      initialOption: Symbols.add,
      labelBuilder: (icon) {
        if (icon == Symbols.add) {
          return 'Add';
        }
        if (icon == Symbols.edit) {
          return 'Edit';
        }
        if (icon == Symbols.delete) {
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

MessageState messageStateKnob(BuildContext context) {
  return context.knobs.list(
    label: 'State',
    options: [
      MessageState.caution,
      MessageState.error,
      MessageState.info,
      MessageState.success,
    ],
    initialOption: MessageState.caution,
    labelBuilder: (state) {
      if (state == MessageState.caution) {
        return 'Caution';
      }
      if (state == MessageState.error) {
        return 'Error';
      }
      if (state == MessageState.info) {
        return 'Info';
      }
      return 'Success';
    },
  );
}
