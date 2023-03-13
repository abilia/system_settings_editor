import 'package:auth/repository/user_repository.dart';
import 'package:calendar/all.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarCubit extends Cubit<String?> {
  final CalendarRepository calendarRepository;
  final UserRepository userRepository;
  CalendarCubit({
    required this.calendarRepository,
    required this.userRepository,
  }) : super(null);

  Future<void> loadCalendarId() async {
    final user = await userRepository.getUserFromDb();
    final calendarId = await calendarRepository.fetchAndSetCalendar(user.id);
    emit(calendarId);
  }
}
