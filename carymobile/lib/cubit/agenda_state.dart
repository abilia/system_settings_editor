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
  final Map<Occasion, List<ActivityDay>> occasions;

  const AgendaLoaded({
    required this.occasions,
    required this.day,
  });

  List<ActivityDay> get pastActivities => occasions[Occasion.past] ?? [];

  List<ActivityDay> get notPastActivities => [
        ...occasions[Occasion.current] ?? [],
        ...occasions[Occasion.future] ?? []
      ];

  @override
  List<Object?> get props => [occasions, day];
}
