import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';

abstract class Event extends Equatable implements Comparable {
  const Event();
  String get title;
  DateTime get start;
  DateTime get end;
  int get category;
  String get id;
  EventOccasion toOccasion(DateTime now);
  AbiliaFile get image;
  bool get hasImage => image.isNotEmpty;

  @override
  int compareTo(other) {
    final starTimeComparing = start.compareTo(other.start);
    if (starTimeComparing != 0) return starTimeComparing;
    return end.compareTo(other.end);
  }
}
