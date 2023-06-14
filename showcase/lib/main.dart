import 'package:flutter/material.dart';
import 'package:ui/buttons/link_button.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(const HotreloadWidgetbook());
}

class HotreloadWidgetbook extends StatelessWidget {
  const HotreloadWidgetbook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      addons: [
        DeviceFrameAddon(
          devices: [
            ...Devices.ios.all,
          ],
        ),
        TextScaleAddon(scales: [3.0, 2.0, 1.0, .8, .5], initialScale: 1.0),
      ],
      directories: [
        WidgetbookComponent(
          name: 'Buttons',
          useCases: [
            WidgetbookUseCase(
              name: 'Link Button',
              builder: (context) => Center(
                child: LinkButton(
                  onPressed: context.knobs
                          .boolean(label: 'Enabled', initialValue: true)
                      ? () {}
                      : null,
                  title: context.knobs.string(
                    label: 'Button title',
                    initialValue: 'Title',
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
