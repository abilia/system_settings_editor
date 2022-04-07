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
    double? height,
  })  : preferredSize = Size.fromHeight(height ??
            AbiliaAppBar.height + (bottom?.preferredSize.height ?? 0.0)),
        super(key: key);

  static final Size size = Size.fromHeight(height);
  static final double height = layout.appBar.height;

  @override
  Widget build(BuildContext context) {
    final appBarHeading = AppBarHeading(
      text: title,
      label: label ?? '',
      iconData: iconData,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
        ),
        child: SafeArea(
          child: (trailing != null || bottom != null)
              ? Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: appBarHeading,
                          ),
                          if (trailing != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: trailing,
                            ),
                        ],
                      ),
                    ),
                    if (bottom != null)
                      Expanded(
                        child: bottom ?? const SizedBox.shrink(),
                      ),
                  ],
                )
              : Center(child: appBarHeading),
        ),
      ),
    );
  }
}
