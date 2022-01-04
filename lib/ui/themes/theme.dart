import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/abilia_icons.dart';
import 'package:seagull/ui/themes/all.dart';
import 'package:seagull/utils/all.dart';

final verticalPadding = 24.s,
    horizontalPadding = 16.s,
    rightPadding = horizontalPadding,
    leftPadding = 12.s,
    seperatorPadding = 16.s;
final ordinaryPadding = EdgeInsets.fromLTRB(
  leftPadding,
  verticalPadding,
  rightPadding,
  verticalPadding,
);

final topPadding = EdgeInsets.fromLTRB(layout.formPadding.left,
    layout.formPadding.top, layout.formPadding.right, 0);
final formItemPadding = EdgeInsets.fromLTRB(layout.formPadding.left,
    layout.formPadding.verticalItemDistance, layout.formPadding.right, 0);
final formTopSpacer = SizedBox(
    height: layout.formPadding.top - layout.formPadding.verticalItemDistance);

final abiliaTheme = ThemeData(
  primaryColorBrightness: Brightness.light,
  scaffoldBackgroundColor: AbiliaColors.white110,
  colorScheme: const ColorScheme.light(
    primary: AbiliaColors.black,
    onSurface: AbiliaColors.black,
    background: AbiliaColors.white110,
    error: AbiliaColors.red,
  ),
  unselectedWidgetColor: AbiliaColors.white140,
  fontFamily: 'Roboto',
  inputDecorationTheme: inputDecorationTheme,
  textTheme: abiliaTextTheme,
  highlightColor: AbiliaColors.transparentBlack40,
  iconTheme: IconThemeData(
    size: layout.iconSize.normal,
    color: AbiliaColors.black,
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: AbiliaColors.black,
    selectionHandleColor: AbiliaColors.black,
    selectionColor: AbiliaColors.white120,
  ),
  appBarTheme: const AppBarTheme(backgroundColor: AbiliaColors.black80),
  bottomAppBarTheme: const BottomAppBarTheme(color: AbiliaColors.black80),
  cupertinoOverrideTheme: const CupertinoThemeData(
    primaryColor: AbiliaColors.black,
  ),
  toggleableActiveColor: AbiliaColors.green,
  dividerTheme: DividerThemeData(
    color: AbiliaColors.white120,
    endIndent: 12.s,
    thickness: 1.s,
    space: 0,
  ),
);

final inputDecorationTheme = InputDecorationTheme(
    contentPadding: EdgeInsets.symmetric(vertical: 14.s, horizontal: 16.s),
    focusedBorder: inputBorder,
    enabledBorder: inputBorder,
    errorBorder: redOutlineInputBorder,
    focusedErrorBorder: redOutlineInputBorder,
    filled: true,
    // Unfortunatly, can't use the validation without showing some error text, set the font size 0
    errorStyle: const TextStyle(height: 0),
    fillColor: AbiliaColors.white);

final outerRadius = 12.s;
Radius innerRadiusFromBorderSize(double borderSize) =>
    Radius.circular(outerRadius - borderSize);
final radius = Radius.circular(outerRadius);
final borderRadius = BorderRadius.all(radius);
final borderRadiusRight = BorderRadius.only(
  topRight: radius,
  bottomRight: radius,
);
final borderRadiusLeft = BorderRadius.only(
  topLeft: radius,
  bottomLeft: radius,
);
final borderRadiusTop = BorderRadius.only(
  topLeft: radius,
  topRight: radius,
);

final circleRadius = BorderRadius.all(Radius.circular(24.s));

// Borders

final Border selectedActivityBorder = Border.fromBorderSide(
  BorderSide(color: AbiliaColors.black, width: 2.s),
);
final Border currentBorder =
    Border.fromBorderSide(BorderSide(color: AbiliaColors.red, width: 2.0.s));
final Border errorBorder = Border.fromBorderSide(
  BorderSide(color: AbiliaColors.red, width: 1.s),
);
final Border transparentBlackBorder = Border.fromBorderSide(
  BorderSide(color: AbiliaColors.transparentBlack30, width: 1.s),
);

final borderOrange = Border.fromBorderSide(
  BorderSide(color: AbiliaColors.orange40, width: 2.s),
);
final border = Border.fromBorderSide(
  BorderSide(color: AbiliaColors.white140, width: 1.s),
);

final ligthShapeBorder = RoundedRectangleBorder(
  borderRadius: borderRadius,
  side: BorderSide(color: AbiliaColors.transparentWhite30, width: 1.s),
);
final darkShapeBorder = RoundedRectangleBorder(
  borderRadius: borderRadius,
  side: BorderSide(color: AbiliaColors.transparentBlack30, width: 1.s),
);
final inputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: AbiliaColors.white140, width: 1.s),
  borderRadius: borderRadius,
);
final redOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: AbiliaColors.red, width: 1.s),
  borderRadius: borderRadius,
);
final transparentOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.transparent, width: 1.s),
  borderRadius: borderRadius,
);

// Box decorations
final boxDecoration = BoxDecoration(
  borderRadius: borderRadius,
  border: border,
);
final disabledBoxDecoration = BoxDecoration(
  borderRadius: borderRadius,
  color: AbiliaColors.transparentWhite40,
);
final currentBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: Border.fromBorderSide(
    BorderSide(color: AbiliaColors.red, width: 3.s),
  ),
);
final whiteBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: border,
);
final selectedBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: Border.fromBorderSide(
    BorderSide(color: AbiliaColors.green, width: 2.s),
  ),
);
final whiteNoBorderBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
);
final warningBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: borderOrange,
);
const inactiveGrey = AbiliaColors.white110;
final errorBoxDecoration = BoxDecoration(
  borderRadius: borderRadius,
  border: errorBorder,
);
final whiteErrorBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: errorBorder,
);

BoxDecoration getCategoryBoxDecoration({
  required bool inactive,
  required bool current,
  required bool showCategoryColor,
  required int category,
}) =>
    BoxDecoration(
      color: inactive ? AbiliaColors.white110 : AbiliaColors.white,
      borderRadius: borderRadius,
      border: getCategoryBorder(
        inactive: inactive,
        current: current,
        showCategoryColor: showCategoryColor,
        category: category,
      ),
    );

Border getCategoryBorder({
  required bool inactive,
  required bool current,
  required bool showCategoryColor,
  required int category,
}) =>
    current
        ? Border.fromBorderSide(
            BorderSide(color: AbiliaColors.red, width: 3.s),
          )
        : Border.fromBorderSide(
            BorderSide(
              color: categoryColor(
                category: category,
                inactive: inactive,
                showCategoryColor: showCategoryColor,
              ),
              width: 1.5.s,
            ),
          );

BoxDecoration selectableBoxDecoration(bool selected) =>
    selected ? selectedBoxDecoration : whiteBoxDecoration;

const rightCategoryActiveColor = AbiliaColors.green,
    rightCategoryInactiveColor = AbiliaColors.green40,
    leftCategoryActiveColor = AbiliaColors.black60,
    noCategoryColor = AbiliaColors.white140;

Color categoryColor({
  required int category,
  bool inactive = false,
  bool showCategoryColor = true,
}) {
  if (!showCategoryColor) return noCategoryColor;
  if (category == Category.right) {
    return inactive ? rightCategoryInactiveColor : rightCategoryActiveColor;
  }
  return inactive ? noCategoryColor : leftCategoryActiveColor;
}

final inputErrorDecoration = InputDecoration(
  suffixIcon: Padding(
    padding: EdgeInsetsDirectional.only(end: 16.s),
    child: Icon(
      AbiliaIcons.irError,
      color: AbiliaColors.red,
      size: layout.iconSize.small,
    ),
  ),
);

// Icon theme
final lightIconThemeData = IconThemeData(
  size: layout.iconSize.button,
  color: AbiliaColors.white,
);
