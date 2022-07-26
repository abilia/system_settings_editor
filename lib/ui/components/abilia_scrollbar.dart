import 'package:flutter/cupertino.dart';

class AbiliaScrollBar extends StatelessWidget {
  final Widget child;
  final ScrollController? controller;
  final bool thumbVisibility;

  const AbiliaScrollBar({
    Key? key,
    this.controller,
    required this.child,
    this.thumbVisibility = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => CupertinoScrollbar(
        controller: controller,
        thumbVisibility: thumbVisibility,
        child: child,
      );
}
