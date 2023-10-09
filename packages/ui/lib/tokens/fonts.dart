import 'package:flutter/widgets.dart';

class AbiliaFonts {
  final FontWeight weightMedium = FontWeight.w400;
  final int weightSemiBold = 500;
  final int weightRegular = 400;

  static const _primaryMedium = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
  );
  static final _primarySemiBold = _primaryMedium.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final _primaryRegular = _primaryMedium.copyWith(
    fontWeight: FontWeight.w400,
  );

  static final primary125 = _primaryMedium.copyWith(
    fontSize: 11,
    height: 12 / 11,
  );
  static final primary225 = _primaryMedium.copyWith(
    fontSize: 12,
    height: 16 / 12,
  );
  static final primary250 = _primarySemiBold.copyWith(
    fontSize: 12,
    height: 16 / 12,
  );
  static final primary300 = _primaryRegular.copyWith(
    fontSize: 14,
    height: 24 / 14,
  );
  static final primary350 = _primarySemiBold.copyWith(
    fontSize: 14,
    height: 16 / 14,
  );
  static final primary400 = _primaryRegular.copyWith(
    fontSize: 16,
    height: 24 / 16,
  );
  static final primary425 = _primaryMedium.copyWith(
    fontSize: 16,
    height: 24 / 16,
  );
  static final primary450 = _primarySemiBold.copyWith(
    fontSize: 16,
    height: 24 / 16,
  );
  static final primary525 = _primaryMedium.copyWith(
    fontSize: 20,
    height: 24 / 20,
  );
  static final primary600 = _primaryRegular.copyWith(
    fontSize: 24,
    height: 36 / 24,
  );
  static final primary725 = _primaryMedium.copyWith(
    fontSize: 32,
    height: 40 / 32,
  );
  static final primary950 = _primaryMedium.copyWith(
    fontSize: 64,
    height: 72 / 64,
  );
}
