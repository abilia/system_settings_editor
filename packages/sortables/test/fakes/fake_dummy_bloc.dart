
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:repository_base/bloc/sync/sync_event.dart';

class FakeDummyBloc extends Fake implements Bloc<SyncEvent, FakeDummyState> {

  @override
  Stream<FakeDummyState> get stream => const Stream.empty();

  @override
  void add(SyncEvent event) {}

}

class FakeDummyState extends Equatable {
  const FakeDummyState();
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;

}
