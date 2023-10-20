part of 'agenda_cubit.dart';

sealed class AgendaState extends Equatable {
  const AgendaState();

  @override
  List<Object?> get props => [];
}

class AgendaLoading extends AgendaState {
  const AgendaLoading();
}

class AgendaLoaded extends AgendaState {
  final DateTime day;
  final List<ActivityDay> activities;

  const AgendaLoaded({
    required this.activities,
    required this.day,
  });

  @override
  List<Object?> get props => [activities, day];
}
