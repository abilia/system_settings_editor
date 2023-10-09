import 'package:flutter/material.dart';
import 'package:ui/components/buttons/action_button.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(const WidgetBook());
}

class WidgetBook extends StatelessWidget {
  const WidgetBook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      addons: [
        DeviceFrameAddon(
          devices: [
            ...Devices.ios.all,
            ...Devices.android.all,
          ],
        ),
        TextScaleAddon(scales: [3.0, 2.0, 1.0, .8, .5], initialScale: 1.0),
      ],
      directories: [
        WidgetbookComponent(
          name: 'Buttons',
          useCases: [
            WidgetbookUseCase(
              name: 'Action Button',
              builder: (context) => Center(
                child: SizedBox(
                  width: context.knobs.boolean(
                    label: 'Expanded',
                    initialValue: false,
                  )
                      ? double.infinity
                      : null,
                  child: ActionButton(
                    text: context.knobs.string(
                      label: 'Button title',
                      initialValue: 'Title',
                    ),
                    actionButtonStyle: context.knobs.list(
                      label: 'Button style',
                      options: ActionButtonStyle.values,
                      initialOption: ActionButtonStyle.primary,
                      labelBuilder: (style) => style.name,
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
                        ? Icons.add
                        : null,
                    trailingIcon: context.knobs.boolean(
                      label: 'Trailing icon',
                      initialValue: false,
                    )
                        ? Icons.add
                        : null,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
