import 'package:flutter/material.dart';
import 'package:showcase/knobs.dart';
import 'package:ui/components/tag.dart';
import 'package:widgetbook/widgetbook.dart';

class TagUseCase extends WidgetbookUseCase {
  TagUseCase()
      : super(
          name: 'Tag',
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: SeagullTag(
              size: context.knobs.list(
                label: 'Size',
                options: [
                  TagSize.size600,
                  TagSize.size700,
                ],
                initialOption: TagSize.size600,
                labelBuilder: (size) {
                  if (size == TagSize.size600) {
                    return 'Size 600';
                  }
                  return 'Size 700';
                },
              ),
              text: textKnob(context),
              icon: context.knobs.boolean(
                label: 'Icon',
                initialValue: true,
              )
                  ? Icons.add
                  : null,
              color: colorKnob(context),
            ),
          ),
        );
}
