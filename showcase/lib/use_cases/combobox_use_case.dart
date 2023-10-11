import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ui/components/combobox/combobox.dart';
import 'package:ui/tokens/numericals.dart';
import 'package:widgetbook/widgetbook.dart';

class ComboboxUseCase extends WidgetbookUseCase {
  ComboboxUseCase()
      : super(
          name: 'Combobox',
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
                child: Combobox(
                    errorMessage: context.knobs.stringOrNull(
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
                    controller: TextEditingController(
                      text: context.knobs.string(
                        label: 'Input',
                        initialValue: '',
                      ),
                    ),
                    leading: context.knobs
                            .boolean(label: 'Leading', initialValue: false)
                        ? Icon(
                            MdiIcons.searchWeb,
                            size: numerical600,
                          )
                        : null,
                    trailing: context.knobs
                            .boolean(label: 'Trailing', initialValue: false)
                        ? Icon(
                            MdiIcons.arrowExpandDown,
                            size: numerical600,
                          )
                        : null),
              ),
            ),
          ),
        );
}
