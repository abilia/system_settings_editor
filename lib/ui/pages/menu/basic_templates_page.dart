import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

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
            ListLibrary<BasicActivityData>(
              emptyLibraryMessage: translate.noBasicActivities,
              libraryItemGenerator: _BasicTemplatePickField.new,
              onTapEdit: _onEditTemplateActivity,
            ),
            ListLibrary<BasicTimerData>(
              emptyLibraryMessage: translate.noBasicTimers,
              libraryItemGenerator: _BasicTemplatePickField.new,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigation(
          backNavigationWidget:
              CloseButton(onPressed: Navigator.of(context).maybePop),
        ),
        floatingActionButton: const AddTemplateButton(
          activityTemplateIndex: 0,
        ),
      ),
    );
  }

  void _onEditTemplateActivity(
    BuildContext context,
    Sortable<BasicActivityData> sortable,
  ) {
    if (sortable is! Sortable<BasicActivityDataItem>) return;
    final authProviders = copiedAuthProviders(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            ...authProviders,
            BlocProvider<EditActivityCubit>(
              create: (_) => EditActivityCubit.editTemplate(
                sortable.data,
                context.read<DayPickerBloc>().state.day,
              ),
            ),
            BlocProvider<WizardCubit>(
              create: (context) => TemplateActivityWizardCubit(
                editActivityCubit: context.read<EditActivityCubit>(),
                sortableBloc: context.read<SortableBloc>(),
                original: sortable,
              ),
            ),
          ],
          child: const ActivityWizardPage(),
        ),
      ),
    );
  }
}

class _BasicTemplatePickField<T extends SortableData> extends StatelessWidget {
  const _BasicTemplatePickField(
      this._sortable, this._onTap, this._toolBar, this.selected,
      {Key? key})
      : super(key: key);

  final Sortable<T> _sortable;
  final SortableToolbar _toolBar;
  final GestureTapCallback _onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final text = Text(_sortable.data.title(Translator.of(context).translate));
    if (_sortable.isGroup) {
      return PickField(
        onTap: _onTap,
        text: text,
        padding: layout.pickField.imagePadding,
        leading: SizedBox.fromSize(
          size: layout.pickField.leadingSize,
          child: _PickFolder(
            sortableData: _sortable.data,
          ),
        ),
      );
    }

    final data = _sortable.data;
    return ListDataItem(
      onTap: _onTap,
      text: text,
      secondaryText: data is BasicTimerDataItem
          ? Text(Duration(milliseconds: data.duration).toHMSorMS())
          : null,
      selected: selected,
      leading: SizedBox.fromSize(
        size: layout.pickField.leadingSize,
        child: _sortable.data.hasImage()
            ? FadeInAbiliaImage(
                imageFileId: _sortable.data.dataFileId(),
                imageFilePath: _sortable.data.dataFilePath(),
                fit: BoxFit.cover,
              )
            : Icon(
                _sortable.data is BasicActivityData
                    ? AbiliaIcons.basicActivity
                    : AbiliaIcons.stopWatch,
                color: AbiliaColors.white140,
              ),
      ),
      trailing: _toolBar,
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

class AddTemplateButton extends StatelessWidget {
  final int activityTemplateIndex;
  const AddTemplateButton({
    Key? key,
    required this.activityTemplateIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    if (tabController == null) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return IconActionButtonBlack(
          onPressed: tabController.index == activityTemplateIndex
              ? () => _addNewActivityTemplate(context)
              : null,
          child: const Icon(AbiliaIcons.plus),
        );
      },
    );
  }

  void _addNewActivityTemplate(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final currentFolderId = context
        .read<SortableArchiveCubit<BasicActivityData>>()
        .state
        .currentFolderId;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            ...authProviders,
            BlocProvider<EditActivityCubit>(
              create: (_) => EditActivityCubit.newActivity(
                day: context.read<DayPickerBloc>().state.day,
                defaultAlarmTypeSetting: context
                    .read<MemoplannerSettingBloc>()
                    .state
                    .defaultAlarmTypeSetting,
              ),
            ),
            BlocProvider<WizardCubit>(
              create: (context) => TemplateActivityWizardCubit(
                editActivityCubit: context.read<EditActivityCubit>(),
                sortableBloc: context.read<SortableBloc>(),
                folderId: currentFolderId,
              ),
            ),
          ],
          child: const ActivityWizardPage(),
        ),
      ),
    );
  }
}
