// @dart=2.9

import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    Key key,
    @required this.text,
  }) : super(key: key);

  final Text text;

  @override
  Widget build(BuildContext context) => Tts.data(
        data: text.data,
        child: Container(
          decoration: BoxDecoration(
            color: AbiliaColors.orange40,
            borderRadius: borderRadius,
          ),
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 20.s),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.bodyText2,
              child: text,
            ),
          ),
        ),
      );
}
