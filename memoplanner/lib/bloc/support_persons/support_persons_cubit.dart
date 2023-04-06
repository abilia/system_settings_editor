import 'dart:async';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/models/support_person.dart';
import 'package:memoplanner/repository/data_repository/support_persons_repository.dart';

class SupportPersonsCubit extends Cubit<SupportPersonsState> {
  final SupportPersonsRepository supportPersonsRepository;

  SupportPersonsCubit({required this.supportPersonsRepository})
      : super(const SupportPersonsState(UnmodifiableSetView.empty()));

  void loadSupportPersons() => unawaited(_loadSupportPersons());

  Future<void> _loadSupportPersons() async {
    final supportPersons = await supportPersonsRepository.load();
    emit(SupportPersonsState(UnmodifiableSetView(supportPersons)));
  }
}

class SupportPersonsState extends Equatable {
  const SupportPersonsState(this.supportPersons);

  final UnmodifiableSetView<SupportPerson> supportPersons;

  bool get showAvailableFor => supportPersons.isNotEmpty;

  @override
  List<Object?> get props => [supportPersons];
}
