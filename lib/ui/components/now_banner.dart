import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/theme.dart';

class NowBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 24.0,
        decoration: BoxDecoration(
          color: AbiliaColors.red,
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 4.0,
          ),
          child: Text(
            Translator.of(context).translate.now,
            style: Theme.of(context)
                .textTheme
                .caption
                .copyWith(color: AbiliaColors.white),
          ),
        ),
      );
}
