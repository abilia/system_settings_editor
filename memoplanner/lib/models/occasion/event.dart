import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

abstract class Event extends Equatable {
  const Event();
  String get title;
  DateTime get start;
  DateTime get end;
  int get category;
  String get id;
  EventOccasion toOccasion(DateTime now);
  AbiliaFile get image;
  bool get hasImage => image.isNotEmpty;
}
