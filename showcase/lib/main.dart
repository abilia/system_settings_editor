import 'package:flutter/material.dart';
import 'package:showcase/addons/breakpoint_addon.dart';
import 'package:showcase/use_cases/action_button_use_case.dart';
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
        BreakpointAddon(),
      ],
      directories: [
        WidgetbookComponent(
          name: 'Buttons',
          useCases: [
            ActionButtonUseCase(),
          ],
        )
      ],
    );
  }
}
