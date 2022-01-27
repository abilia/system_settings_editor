import 'package:equatable/equatable.dart';
import 'package:seagull/models/occasion/all.dart';

abstract class Event extends Equatable {
  const Event();
  DateTime get start;
  DateTime get end;
  int get category;
  EventOccasion toOccasion(DateTime now);
}
