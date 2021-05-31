// @dart=2.9

part of 'license_bloc.dart';

abstract class LicenseState extends Equatable {
  const LicenseState();
  @override
  List<Object> get props => [];
}

class LicensesNotLoaded extends LicenseState {}

class ValidLicense extends LicenseState {}

class NoValidLicense extends LicenseState {}
