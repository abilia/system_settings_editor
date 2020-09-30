import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    Key key,
    @required this.text,
  }) : super(key: key);

  final Text text;

  @override
  Widget build(BuildContext context) => Tts(
        data: text.data,
        child: Container(
          decoration: BoxDecoration(
            color: AbiliaColors.orange[40],
            borderRadius: borderRadius,
          ),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: text,
          ),
        ),
      );
}
