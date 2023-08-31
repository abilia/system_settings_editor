import 'package:flutter/services.dart';
import 'package:memoplanner/ui/all.dart';

class _AbiliaAppBarBackground extends StatelessWidget {
  final Widget child;
  final bool useVerticalSafeArea;
  final BorderRadiusGeometry? borderRadius;

  const _AbiliaAppBarBackground({
    required this.child,
    this.useVerticalSafeArea = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
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
          child: child,
        ),
      ),
    );
  }
}

class AbiliaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? label;
  final List<String> breadcrumbs;
  final IconData iconData;
  final Widget? trailing;
  final PreferredSizeWidget? bottom;
  final BorderRadiusGeometry? borderRadius;
  final bool useVerticalSafeArea;
  final double? height;

  @override
  final Size preferredSize;

  AbiliaAppBar({
    required this.title,
    required this.iconData,
    this.label,
    this.breadcrumbs = const [],
    this.bottom,
    this.trailing,
    this.borderRadius,
    this.useVerticalSafeArea = true,
    this.height,
    MainAxisAlignment? mainAxisAlignment,
    Key? key,
  })  : preferredSize = Size.fromHeight(height ??
            layout.appBar.smallHeight + (bottom?.preferredSize.height ?? 0.0)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    final bottom = this.bottom;
    final top = SizedBox(
      height: height ?? layout.appBar.smallHeight,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: AppBarHeading(
              text: title,
              label: label ?? '',
              breadcrumbs: breadcrumbs,
              iconData: iconData,
            ),
          ),
          if (trailing != null)
            Align(
              alignment: Alignment.centerRight,
              child: trailing,
            ),
        ],
      ),
    );
    return _AbiliaAppBarBackground(
      useVerticalSafeArea: useVerticalSafeArea,
      borderRadius: borderRadius,
      child: bottom == null
          ? top
          : Column(
              children: [
                top,
                SizedBox(
                  height: bottom.preferredSize.height,
                  child: bottom,
                ),
              ],
            ),
    );
  }
}

class AbiliaSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<String> breadcrumbs;
  final IconData iconData;

  @override
  final Size preferredSize;

  AbiliaSearchAppBar({
    required this.title,
    required this.iconData,
    this.breadcrumbs = const [],
    MainAxisAlignment? mainAxisAlignment,
    Key? key,
  })  : preferredSize = Size.fromHeight(layout.appBar.smallHeight),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: _AbiliaAppBarBackground(
        child: Padding(
          padding: layout.appBar.searchPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: AppBarHeading(
                  text: title,
                  breadcrumbs: breadcrumbs,
                  iconData: iconData,
                ),
              ),
              const SearchButton(),
            ],
          ),
        ),
      ),
    );
  }
}
