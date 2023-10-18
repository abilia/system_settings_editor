import 'package:flutter/material.dart';
import 'package:showcase/knobs.dart';
import 'package:ui/components/helper_box.dart';
import 'package:widgetbook/widgetbook.dart';

class HelperBoxUseCase extends WidgetbookUseCase {
  HelperBoxUseCase()
      : super(
          name: 'Helper Box',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SeagullHelperBox(
                size: context.knobs.list(
                  label: 'Size',
                  options: [
                    HelperBoxSize.medium,
                    HelperBoxSize.large,
                  ],
                  initialOption: HelperBoxSize.medium,
                  labelBuilder: (size) {
                    if (size == HelperBoxSize.medium) {
                      return 'Medium';
                    }
                    return 'Large';
                  },
                ),
                text: textKnob(context),
                icon: iconKnob(context),
                state: context.knobs.list(
                  label: 'State',
                  options: [
                    HelperBoxState.caution,
                    HelperBoxState.error,
                    HelperBoxState.info,
                    HelperBoxState.success,
                  ],
                  initialOption: HelperBoxState.caution,
                  labelBuilder: (state) {
                    if (state == HelperBoxState.caution) {
                      return 'Caution';
                    }
                    if (state == HelperBoxState.error) {
                      return 'Error';
                    }
                    if (state == HelperBoxState.info) {
                      return 'Info';
                    }
                    return 'Success';
                  },
                ),
              ),
            ),
          ),
        );
}
