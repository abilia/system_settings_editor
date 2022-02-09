import 'package:flutter/services.dart';
import 'package:seagull/ui/all.dart';

class AbiliaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? label;
  final IconData iconData;
  final Widget? trailing;
  final PreferredSizeWidget? bottom;

  @override
  final Size preferredSize;

  AbiliaAppBar({
    Key? key,
    required this.title,
    this.label,
    required this.iconData,
    this.bottom,
    this.trailing,
  })  : preferredSize =
            Size.fromHeight(height + (bottom?.preferredSize.height ?? 0.0)),
        super(key: key);

  static final Size size = Size.fromHeight(height);
  static final double height = layout.appBar.height;

  @override
  Widget build(BuildContext context) {
    Widget content = AppBarHeading(
      text: title,
      label: label ?? '',
      iconData: iconData,
    );
    if (trailing != null || bottom != null) {
      content = Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Align(alignment: Alignment.center, child: content),
                if (trailing != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: trailing,
                  ),
              ],
            ),
          ),
          if (bottom != null)
            Expanded(child: bottom ?? const SizedBox.shrink()),
        ],
      );
    } else {
      content = Center(child: content);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
        ),
        child: SafeArea(
          child: content,
        ),
      ),
    );
  }
}
