import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

typedef ItemSelected<T extends SortableData> = void Function(
    BuildContext t, Sortable<T>);

class ListLibrary<T extends SortableData> extends StatelessWidget {
  final BasicTemplateItemGenerator<T> libraryItemGenerator;
  final String emptyLibraryMessage;
  final ItemSelected<T>? onTapEdit;

  const ListLibrary({
    Key? key,
    required this.emptyLibraryMessage,
    required this.libraryItemGenerator,
    this.onTapEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _controller = ScrollController();
    return BlocBuilder<SortableArchiveCubit<T>, SortableArchiveState<T>>(
      builder: (context, archiveState) {
        final onTapEdit = this.onTapEdit;
        final content = archiveState.currentFolderSorted;
        return Column(
          children: [
            if (!archiveState.isAtRoot)
              LibraryHeading<T>(
                sortableArchiveState: archiveState,
                rootHeading: '',
                showOnlyFolders: true,
              ),
            Expanded(
              child: content.isEmpty
                  ? EmptyLibraryMessage(
                      emptyLibraryMessage: emptyLibraryMessage,
                      rootFolder: archiveState.isAtRoot,
                    )
                  : ScrollArrows.vertical(
                      controller: _controller,
                      child: ListView.separated(
                        controller: _controller,
                        padding: m1WithZeroBottom,
                        itemCount: content.length,
                        separatorBuilder: (context, index) => SizedBox(
                          height: layout.formPadding.verticalItemDistance,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          final Sortable<T> sortable = content[index];
                          final bool selected =
                              archiveState.selected?.id == sortable.id;
                          return libraryItemGenerator(
                            sortable,
                            () => sortable.isGroup
                                ? context
                                    .read<SortableArchiveCubit<T>>()
                                    .folderChanged(sortable.id)
                                : context
                                    .read<SortableArchiveCubit<T>>()
                                    .sortableSelected(
                                        selected ? null : sortable),
                            SortableToolbar(
                              disableUp: index == 0,
                              disableDown: index == content.length - 1,
                              onTapEdit: onTapEdit != null
                                  ? () => onTapEdit(context, sortable)
                                  : null,
                              onTapDelete: () =>
                                  _onDeleteItem(context, sortable),
                              onTapReorder: (direction) => context
                                  .read<SortableArchiveCubit<T>>()
                                  .reorder(direction),
                            ),
                            selected,
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onDeleteItem(
    BuildContext context,
    Sortable sortable,
  ) async {
    final translate = Translator.of(context).translate;
    final result = await showViewDialog<bool>(
      context: context,
      builder: (_) => YesNoDialog(
        heading: translate.delete,
        headingIcon: AbiliaIcons.deleteAllClear,
        text: sortable.data is BasicTimerData
            ? translate.timerDelete
            : translate.deleteActivity,
      ),
    );

    if (result == true) {
      context.read<SortableArchiveCubit<T>>().delete();
    }
  }
}