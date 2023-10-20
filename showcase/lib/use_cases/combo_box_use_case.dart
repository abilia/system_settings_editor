import 'package:flutter/material.dart';
import 'package:ui/components/combo_box.dart';
import 'package:ui/states.dart';
import 'package:widgetbook/widgetbook.dart';

class ComboBoxUseCase extends WidgetbookUseCase {
  ComboBoxUseCase()
      : super(
          name: 'Combo Box',
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  width: context.knobs.boolean(
                    label: 'Expanded',
                    initialValue: false,
                  )
                      ? null
                      : 300,
                  child: SeagullComboBox(
                    controller: TextEditingController(),
                    label: context.knobs.string(
                      label: 'Label',
                      initialValue: 'Label',
                    ),
                    hintText: context.knobs.string(
                      label: 'Hint text',
                      initialValue: '',
                    ),
                    onChanged: (value) {},
                    leadingIcon: context.knobs.boolean(
                      label: 'Leading icon',
                      initialValue: false,
                    )
                        ? Icons.account_circle
                        : null,
                    trailingIcon: context.knobs.boolean(
                      label: 'Trailing icon',
                      initialValue: false,
                    )
                        ? Icons.visibility
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
                    message: context.knobs.string(
                      label: 'Message',
                    ),
                  ),
                ),
              ),
            );
          },
        );
}
