import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:showcase/knobs.dart';
import 'package:ui/components/combo_box.dart';
import 'package:ui/utils/states.dart';
import 'package:widgetbook/widgetbook.dart';

class ComboBoxUseCase extends WidgetbookUseCase {
  ComboBoxUseCase({
    required TextEditingController controller,
  }) : super(
          name: 'Combo Box',
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: context.knobs.boolean(
                  label: 'Expanded',
                  initialValue: false,
                )
                    ? null
                    : 300,
                child: SeagullComboBox(
                  controller: controller,
                  enabled: context.knobs.boolean(
                    label: 'Enabled',
                    initialValue: true,
                  ),
                  label: context.knobs.string(
                    label: 'Label',
                    initialValue: 'Label',
                  ),
                  size: mediumLargeSizeKnob(context),
                  hintText: context.knobs.string(
                    label: 'Hint text',
                    initialValue: '',
                  ),
                  onChanged: (value) {},
                  leadingIcon: context.knobs.boolean(
                    label: 'Leading icon',
                    initialValue: false,
                  )
                      ? Symbols.account_circle
                      : null,
                  trailingIcon: context.knobs.boolean(
                    label: 'Trailing icon',
                    initialValue: false,
                  )
                      ? Symbols.visibility
                      : null,
                  messageState: context.knobs.list(
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
                  ),
                  helperBoxIcon: context.knobs.boolean(
                    label: 'Show helper box',
                    initialValue: false,
                  )
                      ? Symbols.info
                      : null,
                  helperBoxMessage: context.knobs.string(
                    label: 'Message',
                  ),
                ),
              ),
            );
          },
        );
}
