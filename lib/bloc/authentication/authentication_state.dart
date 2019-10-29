import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthenticationUninitialized extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final String token;
  final int userId;
  Authenticated({@required this.token, @required this.userId});
  @override
  List<Object> get props => [token, userId];
}

class Unauthenticated extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}
