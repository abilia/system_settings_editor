import 'package:flutter/widgets.dart';
import 'package:ui/tokens/colors.dart';

const FontWeight weightMedium = FontWeight.w400;
const int weightSemiBold = 500;
const int weightRegular = 400;

const _primaryMedium = TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w500,
    color: FontColors.primary);
final _primarySemiBold = _primaryMedium.copyWith(fontWeight: FontWeight.w600);
final _primaryRegular = _primaryMedium.copyWith(fontWeight: FontWeight.w400);

final primary125 = _primaryMedium.copyWith(fontSize: 11, height: 12 / 11);
final primary225 = _primaryMedium.copyWith(fontSize: 12, height: 16 / 12);
final primary250 = _primarySemiBold.copyWith(fontSize: 12, height: 16 / 12);
final primary300 = _primaryRegular.copyWith(fontSize: 14, height: 24 / 14);
final primary350 = _primarySemiBold.copyWith(fontSize: 14, height: 16 / 14);
final primary400 = _primaryRegular.copyWith(fontSize: 16, height: 24 / 16);
final primary425 = _primaryMedium.copyWith(fontSize: 16, height: 24 / 16);
final primary450 = _primarySemiBold.copyWith(fontSize: 16, height: 24 / 16);
final primary525 = _primaryMedium.copyWith(fontSize: 20, height: 24 / 20);
final primary600 = _primaryRegular.copyWith(fontSize: 24, height: 36 / 24);
final primary725 = _primaryMedium.copyWith(fontSize: 32, height: 40 / 32);
final primary950 = _primaryMedium.copyWith(fontSize: 64, height: 72 / 64);
