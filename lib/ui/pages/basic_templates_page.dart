import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class BasicTemplatesPage extends StatelessWidget {
  const BasicTemplatesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AbiliaAppBar(
          iconData: AbiliaIcons.favoritesShow,
          title: translate.basicTemplates,
          bottom: AbiliaTabBar(
            tabs: <Widget>[
              TabItem(translate.basicActivities, AbiliaIcons.basicActivity),
              TabItem(translate.basicTimers, AbiliaIcons.stopWatch),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BasicTemplateTab<BasicActivityData>(
              noTemplateText: translate.noBasicActivities,
            ),
            _BasicTemplateTab<BasicTimerData>(
              noTemplateText: translate.noBasicTimers,
            ),
          ],
        ),
      ),
    );
  }
}

class _BasicTemplateTab<T extends SortableData> extends StatelessWidget {
  const _BasicTemplateTab({
    required this.noTemplateText,
    Key? key,
  }) : super(key: key);

  final String noTemplateText;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SortableArchiveCubit<T>, SortableArchiveState<T>>(
          builder: (context, archiveState) {
        return Scaffold(
          body: ListLibrary<T>(
            emptyLibraryMessage: noTemplateText,
            libraryItemGenerator: _BasicTemplatePickField.new,
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: archiveState.isAtRoot
                ? CloseButton(onPressed: Navigator.of(context).maybePop)
                : PreviousButton(
                    onPressed:
                        context.read<SortableArchiveCubit<T>>().navigateUp,
                  ),
          ),
        );
      });
}

class _BasicTemplatePickField<T extends SortableData> extends StatefulWidget {
  const _BasicTemplatePickField(this.sortable, this.onTapReorder, {Key? key})
      : super(key: key);

  final Sortable<T> sortable;
  final Function(Sortable, ChecklistReorderDirection, BuildContext)?
      onTapReorder;

  @override
  State<StatefulWidget> createState() {
    return _BasicTemplatePickFieldState();
  }
}

class _BasicTemplatePickFieldState<T extends SortableData>
    extends State<_BasicTemplatePickField<T>> {
  bool selected = false;
  int? selectedQuestion;

  @override
  Widget build(BuildContext context) {
    final Sortable<T> sortable = widget.sortable;

    final text = Text(sortable.data.title(Translator.of(context).translate));

    if (sortable.isGroup) {
      return PickField(
        onTap: () =>
            context.read<SortableArchiveCubit<T>>().folderChanged(sortable.id),
        text: text,
        leading: _PickFolder(sortableData: sortable.data),
        leadingPadding: layout.listFolder.margin,
      );
    }
    return PickField(
      onTap: () => setState(() {
        selected = !selected;
      }),
      padding: selected
          ? layout.pickField.padding.copyWith(right: 0)
          : layout.pickField.padding,
      text: text,
      leading: sortable.data.hasImage()
          ? FadeInAbiliaImage(
              imageFileId: sortable.data.dataFileId(),
              imageFilePath: sortable.data.dataFilePath(),
              fit: BoxFit.contain,
            )
          : const Icon(
              AbiliaIcons.basicActivity,
              color: AbiliaColors.white140,
            ),
      trailing: selected
          ? ChecklistToolbar(
              onTapEdit: () {
                _deselect();
                // TODO: edit
              },
              onTapDelete: () {
                _deselect();
                // TODO: delete
              },
              onTapReorder: (direction) {
                widget.onTapReorder?.call(sortable, direction, context);
                // final selectedIndex = selectedQuestion;
                //
                // if (widget.onTapReorder != null && selectedIndex != null) {
                //   final newSelectedIndex =
                //       direction == ChecklistReorderDirection.up
                //           ? selectedIndex - 1
                //           : selectedIndex + 1;
                //   if (newSelectedIndex >= 0 &&
                //       newSelectedIndex < widget.checklist.questions.length) {
                //     selectedQuestion = newSelectedIndex;
                //   }
                // }
              },
            )
          : null,
    );
  }

  _deselect() {
    // setState() => selected = false;
  }
}

class _PickFolder extends StatelessWidget {
  final SortableData sortableData;

  const _PickFolder({
    Key? key,
    required this.sortableData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final folderLayout = layout.listFolder;
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          AbiliaIcons.folder,
          size: folderLayout.iconSize,
          color: AbiliaColors.orange,
        ),
        if (sortableData.hasImage())
          Padding(
            padding: layout.listFolder.imagePadding,
            child: AspectRatio(
              aspectRatio: 1.75,
              child: FadeInAbiliaImage(
                imageFileId: sortableData.dataFileId(),
                imageFilePath: sortableData.dataFilePath(),
                fit: BoxFit.fitWidth,
                borderRadius: BorderRadius.circular(
                  folderLayout.imageBorderRadius,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
