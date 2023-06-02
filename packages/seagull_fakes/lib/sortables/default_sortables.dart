import 'package:sortables/sortables.dart';

final defaultSortables = [
  Sortable.createNew(
    data: const ImageArchiveData(myPhotos: true),
    fixed: true,
  ),
  Sortable.createNew(
    data: const ImageArchiveData(upload: true),
    fixed: true,
  ),
];
