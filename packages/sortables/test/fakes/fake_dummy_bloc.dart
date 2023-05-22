import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDummyBloc extends Fake implements Bloc<Object, FakeDummyState> {
  @override
  Stream<FakeDummyState> get stream => const Stream.empty();

  @override
  void add(Object event) {}
}

class FakeDummyState extends Equatable {
  const FakeDummyState();
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}
