import 'package:flutter/material.dart';
import 'package:ui/components/combo_box.dart';
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
                    message: context.knobs.stringOrNull(
                      label: 'Error message',
                    ),
                    hintText: context.knobs.string(
                      label: 'Hint text',
                      initialValue: '',
                    ),
                    label: context.knobs.string(
                      label: 'Label',
                      initialValue: 'Label',
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
                  ),
                ),
              ),
            );
          },
        );
}
