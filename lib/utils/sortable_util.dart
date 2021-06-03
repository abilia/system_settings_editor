import 'package:seagull/models/all.dart';

extension SortableExtension on Iterable<Sortable> {
  Sortable getUploadFolder() {
    return whereType<Sortable<ImageArchiveData>>()
        .firstWhere((s) => s.data.upload ?? false);
  }

  Sortable<ImageArchiveData> getMyPhotosFolder() {
    return whereType<Sortable<ImageArchiveData>>()
        .firstWhere((s) => s.data.myPhotos ?? false, orElse: () => null);
  }
}
