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
        builder: (context, state) => Scaffold(
          body: ListLibrary<T>(_BasicTemplatePickField.new, noTemplateText),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: state.isAtRoot
                ? CloseButton(onPressed: Navigator.of(context).maybePop)
                : PreviousButton(
                    onPressed:
                        context.read<SortableArchiveCubit<T>>().navigateUp,
                  ),
          ),
        ),
      );
}

class _BasicTemplatePickField<T extends SortableData> extends StatelessWidget {
  const _BasicTemplatePickField(this.sortable, {Key? key}) : super(key: key);
  final Sortable<T> sortable;

  @override
  Widget build(BuildContext context) {
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
      onTap: () {},
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
      trailing: null,
    );
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
