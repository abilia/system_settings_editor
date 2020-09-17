import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

part 'generic_event.dart';
part 'generic_state.dart';

class GenericBloc extends Bloc<GenericEvent, GenericState> {
  final GenericRepository genericRepository;
  StreamSubscription pushSubscription;
  final SyncBloc syncBloc;

  GenericBloc({
    @required this.genericRepository,
    @required PushBloc pushBloc,
    @required this.syncBloc,
  }) : super(GenericsNotLoaded()) {
    pushSubscription = pushBloc.listen((state) {
      if (state is PushReceived) {
        add(LoadGenerics());
      }
    });
  }

  @override
  Stream<GenericState> mapEventToState(
    GenericEvent event,
  ) async* {
    if (event is LoadGenerics) {
      yield* _mapLoadGenericsToState();
    }
  }

  Stream<GenericState> _mapLoadGenericsToState() async* {
    try {
      final generics = await genericRepository.load();
      yield GenericsLoaded(generics: generics.toList());
    } catch (e) {
      yield GenericsLoadedFailed();
    }
  }

  @override
  Future<void> close() async {
    if (pushSubscription != null) {
      await pushSubscription.cancel();
    }
    return super.close();
  }
}
