import 'package:flutter/services.dart';
import 'package:memoplanner/ui/all.dart';

class AbiliaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? label;
  final String? breadcrumbs;
  final IconData iconData;
  final Widget? trailing;
  final PreferredSizeWidget? bottom;
  final BorderRadiusGeometry? borderRadius;
  final bool useVerticalSafeArea;

  @override
  final Size preferredSize;

  AbiliaAppBar({
    required this.title,
    required this.iconData,
    this.label,
    this.breadcrumbs,
    this.bottom,
    this.trailing,
    this.borderRadius,
    this.useVerticalSafeArea = true,
    double? height,
    Key? key,
  })  : preferredSize = Size.fromHeight(height ??
            layout.appBar.smallHeight + (bottom?.preferredSize.height ?? 0.0)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBarHeading = AppBarHeading(
      text: title,
      label: label ?? '',
      breadcrumbs: breadcrumbs ?? '',
      iconData: iconData,
      hasTrailing: trailing != null,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).appBarTheme.backgroundColor,
          borderRadius: borderRadius,
        ),
        child: SafeArea(
          top: useVerticalSafeArea,
          bottom: useVerticalSafeArea,
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
