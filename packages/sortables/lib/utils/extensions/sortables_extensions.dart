import 'package:collection/collection.dart';
import 'package:sortables/models/sortable/all.dart';

extension SortableExtension on Iterable<Sortable> {
  Sortable<ImageArchiveData>? getUploadFolder() {
    return whereType<Sortable<ImageArchiveData>>()
        .firstWhereOrNull((s) => s.data.upload);
  }

  Sortable<ImageArchiveData>? getMyPhotosFolder() =>
      whereType<Sortable<ImageArchiveData>>()
          .firstWhereOrNull((s) => s.data.myPhotos);
}
