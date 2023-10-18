part of 'button_styles.dart';

final iconButton1000 = ButtonStyle(
  iconSize: MaterialStateProperty.all(numerical800),
  backgroundColor: _backgroundLightGrey,
  foregroundColor: _foregroundColorDarkGrey,
  elevation: MaterialStateProperty.all(numerical1000),
  shape: _borderShape200,
  padding: _padding300,
);

final iconButton900 = iconButton1000.copyWith(
  iconSize: MaterialStateProperty.all(numerical600),
  padding: _padding300,
);

final iconButton800 = iconButton900.copyWith(
  padding: _padding200,
  shape: _borderShape300,
);

final iconButtonNoBorder1000 = iconButton1000.copyWith(
  shape: _noBorderShape200,
  backgroundColor: _backgroundLightGreyTransparent,
);

final iconButtonNoBorder900 = iconButton900.copyWith(
  shape: _noBorderShape200,
  backgroundColor: _backgroundLightGreyTransparent,
);

final iconButtonNoBorder800 = iconButton800.copyWith(
  shape: _noBorderShape300,
  backgroundColor: _backgroundLightGreyTransparent,
);
