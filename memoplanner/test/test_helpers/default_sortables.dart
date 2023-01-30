import 'package:memoplanner/models/sortable/data/image_archive_data.dart';
import 'package:memoplanner/models/sortable/sortable.dart';

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
