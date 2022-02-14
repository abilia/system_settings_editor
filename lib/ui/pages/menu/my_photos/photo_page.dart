import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class PhotoPage extends StatelessWidget {
  const PhotoPage({
    Key? key,
    required this.sortable,
  }) : super(key: key);

  final Sortable<ImageArchiveData> sortable;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;

    return BlocProvider<SortableArchiveBloc<ImageArchiveData>>(
      create: (_) => SortableArchiveBloc<ImageArchiveData>(
        sortableBloc: BlocProvider.of<SortableBloc>(context),
      ),
      child: BlocBuilder<SortableArchiveBloc<ImageArchiveData>,
          SortableArchiveState<ImageArchiveData>>(
        builder: (context, archiveState) {
          final allById = archiveState.allById;
          final updatedSortable = allById[sortable.id];
          final bool isInPhotoCalendar =
              updatedSortable?.data.isInPhotoCalendar() ??
                  sortable.data.isInPhotoCalendar();

          return Scaffold(
            appBar: AbiliaAppBar(
              title: updatedSortable?.data.name ?? sortable.data.name,
              label: translate.myPhotos,
              iconData: AbiliaIcons.myPhotos,
            ),
            body: Padding(
              padding: layout.myPhotos.fullScreenImagePadding,
              child: Center(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        layout.myPhotos.fullScreenImageBorderRadius,
                      ),
                      child: FullScreenImage(
                        backgroundDecoration: const BoxDecoration(),
                        fileId: updatedSortable?.data.fileId ??
                            sortable.data.fileId,
                        filePath:
                            updatedSortable?.data.file ?? sortable.data.file,
                        tightMode: true,
                      ),
                    ),
                    if (isInPhotoCalendar)
                      const Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: PhotoCalendarSticker(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: SizedBox(
                height: layout.toolbar.height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (isInPhotoCalendar)
                      TextAndOrIconActionButtonLight(
                        translate.remove,
                        AbiliaIcons.noPhotoCalendar,
                        onPressed: () {
                          _addOrRemovePhotoFromPhotoCalendar(
                            context,
                            remove: isInPhotoCalendar,
                            sortable: updatedSortable ?? sortable,
                          );
                        },
                      ),
                    if (!isInPhotoCalendar)
                      TextAndOrIconActionButtonLight(
                        isInPhotoCalendar ? translate.remove : translate.add,
                        isInPhotoCalendar
                            ? AbiliaIcons.noPhotoCalendar
                            : AbiliaIcons.photoCalendar,
                        onPressed: () {
                          _addOrRemovePhotoFromPhotoCalendar(
                            context,
                            remove: isInPhotoCalendar,
                            sortable: updatedSortable ?? sortable,
                          );
                        },
                      ),
                    TextAndOrIconActionButtonLight(
                      translate.delete,
                      AbiliaIcons.deleteAllClear,
                      onPressed: () {},
                    ),
                    TextAndOrIconActionButtonLight(
                      translate.close,
                      AbiliaIcons.navigationPrevious,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _addOrRemovePhotoFromPhotoCalendar(
    BuildContext context, {
    required bool remove,
    required Sortable<ImageArchiveData> sortable,
  }) async {
    final translate = Translator.of(context).translate;

    final result = await showViewDialog<bool>(
      context: context,
      builder: (_) => ViewDialog(
        heading: AppBarHeading(
          text: translate.photoCalendar,
          iconData: AbiliaIcons.photoCalendar,
        ),
        body: Tts(
          child: Text(
            remove
                ? translate.removeFromPhotoCalendarQuestion
                : translate.addToPhotoCalendarQuestion,
          ),
        ),
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: GreenButton(
          text: remove ? translate.remove : translate.add,
          icon: AbiliaIcons.ok,
          onPressed: () => Navigator.of(context).maybePop(true),
        ),
      ),
    );
    if (result == true) {
      Set<String> updatedTags = {};
      if (remove) {
        updatedTags
          ..addAll([...sortable.data.tags])
          ..remove(ImageArchiveData.photoCalendarTag);
      } else {
        updatedTags.addAll(
          [...sortable.data.tags, ImageArchiveData.photoCalendarTag],
        );
      }
      final updatedSortable = sortable.copyWith(
          data: sortable.data.copyWith(tags: updatedTags.toList()));
      BlocProvider.of<SortableBloc>(context)
          .add(SortableUpdated(updatedSortable));
    }
  }
}
