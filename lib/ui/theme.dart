import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/abilia_icons.dart';
import 'package:seagull/utils/all.dart';

import 'colors.dart';

final smallIconSize = 24.s,
    buttonIconSize = 28.s,
    defaultIconSize = 32.s,
    hugeIconSize = 96.s;

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

final abiliaTheme = ThemeData(
  primaryColorBrightness: Brightness.light,
  scaffoldBackgroundColor: AbiliaColors.white110,
  primaryColor: AbiliaColors.black,
  accentColor: AbiliaColors.black,
  unselectedWidgetColor: AbiliaColors.white140,
  fontFamily: 'Roboto',
  inputDecorationTheme: inputDecorationTheme,
  textTheme: abiliaTextTheme,
  highlightColor: AbiliaColors.transparentBlack40,
  iconTheme: IconThemeData(
    size: defaultIconSize,
    color: AbiliaColors.black,
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: AbiliaColors.black,
    selectionHandleColor: AbiliaColors.black,
    selectionColor: AbiliaColors.white120,
  ),
  appBarTheme: const AppBarTheme(color: AbiliaColors.black80),
  errorColor: AbiliaColors.red,
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
    errorStyle: TextStyle(height: 0),
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
      color: AbiliaColors.white,
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

final rightCategoryActiveColor = AbiliaColors.green,
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
      AbiliaIcons.ir_error,
      color: AbiliaColors.red,
      size: smallIconSize,
    ),
  ),
);

// Icon theme
final lightIconThemeData = IconThemeData(
  size: buttonIconSize,
  color: AbiliaColors.white,
);

// Text theme
final abiliaTextTheme = GoogleFonts.robotoTextTheme(
  TextTheme(
    headline1: TextStyle(
      color: AbiliaColors.black,
      fontSize: 96.s,
      fontWeight: light,
    ),
    headline2: TextStyle(
      color: AbiliaColors.black,
      fontSize: 60.s,
      fontWeight: light,
      height: 72.0 / 60.0,
    ),
    headline3: TextStyle(
      color: AbiliaColors.black,
      fontSize: 48.s,
      fontWeight: regular,
      height: 56.0 / 48.0,
    ),
    headline4: TextStyle(
      color: AbiliaColors.black,
      fontSize: 34.s,
      fontWeight: regular,
    ),
    headline5: TextStyle(
      color: AbiliaColors.black,
      fontSize: 24.s,
      fontWeight: regular,
    ),
    headline6: TextStyle(
      color: AbiliaColors.black,
      fontSize: 20.s,
      fontWeight: medium,
    ),
    subtitle1: TextStyle(
      color: AbiliaColors.black,
      fontSize: 16.s,
      fontWeight: medium,
      height: 24.0 / 16.0,
    ),
    subtitle2: TextStyle(
      color: AbiliaColors.black,
      fontSize: 14.s,
      fontWeight: medium,
      height: 24.0 / 14.0,
    ),
    bodyText1: TextStyle(
      color: AbiliaColors.black,
      fontSize: 16.s,
      fontWeight: regular,
      height: 28.0 / 16.0,
    ),
    bodyText2: TextStyle(
      color: AbiliaColors.black,
      fontSize: 14.s,
      fontWeight: regular,
      height: 20.0 / 14.0,
    ),
    caption: TextStyle(
      color: AbiliaColors.black,
      fontSize: 12.s,
      fontWeight: regular,
      height: 16.0 / 12.0,
    ),
    button: TextStyle(
      color: AbiliaColors.white,
      fontSize: 16.s,
      fontWeight: regular,
      height: 1,
    ),
    overline: TextStyle(
      fontSize: 10.s,
      fontWeight: medium,
      height: 16.0 / 10.0,
    ),
  ),
);

const FontWeight light = FontWeight.w300;
const FontWeight regular = FontWeight.w400;
const FontWeight medium = FontWeight.w500;
