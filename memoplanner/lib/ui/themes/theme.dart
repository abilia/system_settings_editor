import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/components/abilia_icons.dart';
import 'package:memoplanner/ui/themes/all.dart';

// Form paddings
final dividerPadding = EdgeInsets.only(
  top: layout.formPadding.groupBottomDistance,
);
final m1ItemPadding = EdgeInsets.fromLTRB(
  layout.templates.m1.left,
  layout.formPadding.verticalItemDistance,
  layout.templates.m1.right,
  0,
);

final abiliaTheme = ThemeData(
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
    size: layout.icon.normal,
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
  switchTheme: SwitchThemeData(
    thumbColor: toggleableActiveColor,
    trackColor: toggleableActiveColor,
  ),
  radioTheme: RadioThemeData(fillColor: toggleableActiveColor),
  checkboxTheme: CheckboxThemeData(fillColor: toggleableActiveColor),
  dividerTheme: DividerThemeData(
    color: AbiliaColors.white120,
    endIndent: layout.templates.m1.right,
    thickness: layout.borders.thin,
    space: 0,
  ),
);

final abiliaWhiteTheme =
    abiliaTheme.copyWith(scaffoldBackgroundColor: AbiliaColors.white);

final inputDecorationTheme = InputDecorationTheme(
    contentPadding: layout.theme.inputPadding,
    focusedBorder: inputBorder,
    enabledBorder: inputBorder,
    errorBorder: redOutlineInputBorder,
    focusedErrorBorder: redOutlineInputBorder,
    filled: true,
    // Unfortunatly, can't use the validation without showing some error text, set the font size 0
    errorStyle: const TextStyle(height: 0),
    fillColor: AbiliaColors.white);

final outerRadius = layout.radius;
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

final circleRadius =
    BorderRadius.all(Radius.circular(layout.theme.circleRadius));

// Borders

final Border selectedActivityBorder = Border.fromBorderSide(
  BorderSide(
      color: AbiliaColors.black,
      width: layout.monthCalendar.dayBorderWidthHighlighted),
);
final Border currentBorder = Border.fromBorderSide(
  BorderSide(
      color: AbiliaColors.red,
      width: layout.monthCalendar.dayBorderWidthHighlighted),
);
final Border errorBorder = Border.fromBorderSide(
  BorderSide(color: AbiliaColors.red, width: layout.borders.thin),
);
final Border transparentBlackBorder = Border.fromBorderSide(
  BorderSide(
      color: AbiliaColors.transparentBlack30,
      width: layout.monthCalendar.dayBorderWidth),
);

final border = Border.fromBorderSide(
  BorderSide(color: AbiliaColors.white140, width: layout.borders.thin),
);

final ligthShapeBorder = RoundedRectangleBorder(
  borderRadius: borderRadius,
  side: BorderSide(
      color: AbiliaColors.transparentWhite30, width: layout.borders.thin),
);
final darkShapeBorder = RoundedRectangleBorder(
  borderRadius: borderRadius,
  side: BorderSide(
      color: AbiliaColors.transparentBlack30, width: layout.borders.thin),
);
final menuButtonBorder = darkShapeBorder.copyWith(
  borderRadius: BorderRadius.circular(layout.menuPage.buttons.borderRadius),
);
final inputBorder = OutlineInputBorder(
  borderSide:
      BorderSide(color: AbiliaColors.white140, width: layout.borders.thin),
  borderRadius: borderRadius,
);
final redOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: AbiliaColors.red, width: layout.borders.thin),
  borderRadius: borderRadius,
);
final greenOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: AbiliaColors.green, width: layout.borders.thin),
  borderRadius: borderRadius,
);
final transparentOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Colors.transparent, width: layout.borders.thin),
  borderRadius: borderRadius,
);
final blueBorder = Border.fromBorderSide(
  BorderSide(
    color: AbiliaColors.transparentBlack30,
    width: layout.borders.thin,
  ),
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
final whiteBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: border,
);
final blueBoxDecoration = BoxDecoration(
  color: AbiliaColors.blue120,
  borderRadius: borderRadius,
  border: blueBorder,
);
final selectedBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: Border.fromBorderSide(
      BorderSide(color: AbiliaColors.green, width: layout.borders.medium)),
);
final greySelectedBoxDecoration = BoxDecoration(
  color: AbiliaColors.white120,
  borderRadius: borderRadius,
  border: Border.fromBorderSide(
    BorderSide(
      color: AbiliaColors.white140,
      width: layout.borders.thin,
    ),
  ),
);
final whiteNoBorderBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
);
final warningBoxDecoration = BoxDecoration(
  color: AbiliaColors.white,
  borderRadius: borderRadius,
  border: Border.fromBorderSide(
    BorderSide(
      color: AbiliaColors.orange40,
      width: layout.borders.medium,
    ),
  ),
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
  double zoom = 1.0,
  BorderRadius? radius,
}) =>
    BoxDecoration(
      color: inactive ? AbiliaColors.white110 : AbiliaColors.white,
      borderRadius: radius ?? borderRadius,
      border: getCategoryBorder(
        inactive: inactive,
        current: current,
        showCategoryColor: showCategoryColor,
        category: category,
        zoom: zoom,
      ),
    );

Border getCategoryBorder({
  required bool inactive,
  required bool current,
  required bool showCategoryColor,
  required int category,
  double? borderWidth,
  double? currentBorderWidth,
  double zoom = 1.0,
}) =>
    current
        ? Border.fromBorderSide(
            BorderSide(
              color: AbiliaColors.red,
              width:
                  (currentBorderWidth ?? layout.eventCard.currentBorderWidth) *
                      zoom,
            ),
          )
        : Border.fromBorderSide(
            BorderSide(
              color: categoryColor(
                category: category,
                inactive: inactive,
                showCategoryColor: showCategoryColor,
              ),
              width: (borderWidth ?? layout.eventCard.borderWidth) * zoom,
            ),
          );

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
    padding: EdgeInsetsDirectional.only(
        end: layout.formPadding.groupHorizontalDistance),
    child: Icon(
      AbiliaIcons.irError,
      color: AbiliaColors.red,
      size: layout.icon.small,
    ),
  ),
);

final inputDisabledDecoration = InputDecoration(
  fillColor: AbiliaColors.transparentWhite40,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: borderRadius,
  ),
);

// Icon theme
final lightIconThemeData = IconThemeData(
  size: layout.icon.button,
  color: AbiliaColors.white,
);

final toggleableActiveColor =
    MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
  if (states.contains(MaterialState.disabled)) {
    return null;
  }
  if (states.contains(MaterialState.selected)) {
    return AbiliaColors.green;
  }
  return null;
});
