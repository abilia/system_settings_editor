import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:ui/components/combobox/combobox.dart';
import 'package:ui/themes/combobox/combobox_theme.dart';
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
                  themeBuilder: (themebuilder) => ComboboxTheme.medium()
                      .copyWith(
                          leading: context.knobs.boolean(
                                  label: 'Leading', initialValue: false)
                              ? const Icon(
                                  Symbols.search,
                                  size: numerical600,
                                )
                              : null,
                          trailing: context.knobs.boolean(
                                  label: 'Trailing', initialValue: false)
                              ? const Icon(
                                  Symbols.expand_more,
                                  size: numerical600,
                                )
                              : null),
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
                  controller: TextEditingController(
                    text: context.knobs.string(
                      label: 'Input',
                      initialValue: '',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
}
