import 'package:carymessenger/ui/themes/theme.dart';
import 'package:flutter/material.dart';

class CaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CaryAppBar({
    required this.topPadding,
    required this.title,
    required this.icon,
    super.key,
  });

  final double topPadding;
  final String title;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: heading,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(16.0) + EdgeInsets.only(top: topPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size(0, 64 + topPadding);
}
