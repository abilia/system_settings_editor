// @dart=2.9

part of 'license_bloc.dart';

abstract class LicenseEvent extends Equatable {
  const LicenseEvent();

  @override
  List<Object> get props => [];
}

class ReloadLicenses extends LicenseEvent {}
