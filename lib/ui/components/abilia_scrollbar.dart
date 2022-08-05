import 'package:flutter/cupertino.dart';

class AbiliaScrollBar extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final bool thumbVisibility;

  const AbiliaScrollBar({
    required this.child,
    Key? key,
    this.controller,
    this.thumbVisibility = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => CupertinoScrollbar(
        controller: controller,
        thumbVisibility: thumbVisibility,
        child: child,
      );
}
