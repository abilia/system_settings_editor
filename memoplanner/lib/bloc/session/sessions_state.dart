part of 'sessions_cubit.dart';

class SessionsState extends Equatable {
  final bool hasMP4Session;

  const SessionsState(this.hasMP4Session);

  @override
  List<Object> get props => [hasMP4Session];
}
