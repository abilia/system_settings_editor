import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          DefaultTabController.of(context)
              .addListener(() => _onTabChanged(context));
          return Scaffold(
            appBar: AbiliaAppBar(
              iconData: AbiliaIcons.favoritesShow,
              title: translate.templates,
              bottom: AbiliaTabBar(
                tabs: <Widget>[
                  TabItem(translate.activities, AbiliaIcons.basicActivity),
                  TabItem(translate.timers, AbiliaIcons.stopWatch),
                ],
              ),
            ),
            body: TrackableTabBarView(
              analytics: GetIt.I<SeagullAnalytics>(),
              children: [
                ListLibrary<BasicActivityData>(
                  emptyLibraryMessage: translate.noTemplates,
                  libraryItemGenerator: TemplatePickField.new,
                  onTapEdit: _onEditTemplateActivity,
                ),
                ListLibrary<BasicTimerData>(
                  emptyLibraryMessage: translate.noTemplates,
                  libraryItemGenerator: TemplatePickField.new,
                  onTapEdit: (context, sortables) async => _onEditTemplateTimer(
                    context,
                    sortables,
                    translate.editTimerTemplate,
                  ),
                ),
              ],
            ),
            bottomNavigationBar: const BottomNavigation(
              backNavigationWidget: CloseButton(),
            ),
            floatingActionButton: AddTemplateButton(
              activityTemplateIndex: 0,
              onNewTimerTemplate: (context, sortables) async =>
                  _onEditTemplateTimer(
                context,
                sortables,
                translate.newTimerTemplate,
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTabChanged(BuildContext context) =>
      _unselectSortableArchives(context);

  void _unselectSortableArchives(BuildContext context) {
    context.read<SortableArchiveCubit<BasicTimerData>>().sortableSelected(null);
    context
        .read<SortableArchiveCubit<BasicActivityData>>()
        .sortableSelected(null);
  }

  Future<void> _onEditTemplateActivity(
      BuildContext context, Sortable<BasicActivityData> sortable) async {
    if (sortable is! Sortable<BasicActivityDataItem>) return;
    final authProviders = copiedAuthProviders(context);
    await Navigator.of(context).push(
      PersistentMaterialPageRoute(
        settings: (ActivityWizardPage).routeSetting(),
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

  Future<void> _onEditTemplateTimer(
    BuildContext context,
    Sortable<BasicTimerData> sortable,
    String title,
  ) async {
    final authProviders = copiedAuthProviders(context);
    final sortableBloc = context.read<SortableBloc>();

    final timer = await Navigator.of(context).push(
      PersistentMaterialPageRoute(
        settings: (EditBasicTimerPage).routeSetting(),
        builder: (_) => MultiBlocProvider(
          providers: [
            ...authProviders,
            BlocProvider<EditTimerCubit>(
              create: (_) => EditTimerCubit(
                timerCubit: context.read<TimerCubit>(),
                translate: Translator.of(context).translate,
                ticker: GetIt.I<Ticker>(),
                basicTimer: sortable.data as BasicTimerDataItem,
              ),
            ),
          ],
          child: EditBasicTimerPage(
            title: title,
          ),
        ),
      ),
    );
    if (timer != null) {
      sortableBloc.add(
        SortableUpdated(
          sortable.copyWith(
            data: timer.toBasicTimerDataItem(),
          ),
        ),
      );
    }
  }
}

class TemplatePickField<T extends SortableData> extends StatelessWidget {
  const TemplatePickField(
    this._sortable,
    this._onTap,
    this._trailing,
    this.selected, {
    Key? key,
    this.alwaysShowTrailing = false,
  }) : super(key: key);

  final Sortable<T> _sortable;
  final GestureTapCallback _onTap;
  final bool selected, alwaysShowTrailing;
  final Widget _trailing;

  @override
  Widget build(BuildContext context) {
    final text = Text(_sortable.data.title());
    final data = _sortable.data;

    if (_sortable.isGroup) {
      return PickField(
        key: data is BasicTimerDataFolder
            ? TestKey.basicTimerLibraryFolder
            : null,
        onTap: _onTap,
        text: text,
        padding: layout.pickField.imagePadding,
        leadingPadding: layout.listDataItem.folderPadding,
        leading: SizedBox.fromSize(
          size: layout.pickField.leadingSize,
          child: _PickFolder(
            sortableData: data,
          ),
        ),
      );
    }

    return ListDataItem(
      onTap: _onTap,
      text: text,
      secondaryText: data is BasicTimerDataItem
          ? Text(Duration(milliseconds: data.duration).toHMSorMS())
          : null,
      selected: selected,
      leading: SizedBox.fromSize(
        size: layout.pickField.leadingSize,
        child: data.hasImage()
            ? FadeInAbiliaImage(
                imageFileId: data.dataFileId(),
                imageFilePath: data.dataFilePath(),
                fit: BoxFit.cover,
              )
            : Icon(
                data is BasicActivityData
                    ? AbiliaIcons.basicActivity
                    : AbiliaIcons.stopWatch,
                color: AbiliaColors.white140,
              ),
      ),
      trailing: _trailing,
      alwaysShowTrailing: alwaysShowTrailing,
      semanticsLabel: data is BasicTimerDataItem
          ? Duration(milliseconds: data.duration).toDurationString(
              Translator.of(context).translate,
              shortMin: false)
          : null,
    );
  }
}

class _PickFolder extends StatelessWidget {
  final SortableData sortableData;

  const _PickFolder({
    required this.sortableData,
    Key? key,
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
  final Function onNewTimerTemplate;

  const AddTemplateButton({
    required this.activityTemplateIndex,
    required this.onNewTimerTemplate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return TextAndOrIconActionButtonBlack(
          Translator.of(context).translate.add,
          AbiliaIcons.plus,
          onPressed: tabController.index == activityTemplateIndex
              ? () async => _addNewActivityTemplate(context)
              : () {
                  final state = context
                      .read<SortableArchiveCubit<BasicTimerData>>()
                      .state;
                  onNewTimerTemplate(
                    context,
                    Sortable.createNew(
                      groupId: state.currentFolderId,
                      sortOrder: state.currentFolderSorted.firstSortOrder(),
                      data: BasicTimerDataItem.createNew(),
                    ),
                  );
                },
        );
      },
    );
  }

  Future<void> _addNewActivityTemplate(BuildContext context) {
    final authProviders = copiedAuthProviders(context);
    final sortableState =
        context.read<SortableArchiveCubit<BasicActivityData>>().state;

    return Navigator.of(context).push(
      PersistentMaterialPageRoute(
        settings: (ActivityWizardPage).routeSetting(),
        builder: (_) => MultiBlocProvider(
          providers: [
            ...authProviders,
            BlocProvider<EditActivityCubit>(
              create: (context) {
                final settings = context.read<MemoplannerSettingsBloc>().state;
                final defaultsSettings = settings.addActivity.defaults;
                return EditActivityCubit.newActivity(
                  day: context.read<DayPickerBloc>().state.day,
                  defaultsSettings: defaultsSettings,
                  calendarId: '',
                );
              },
            ),
            BlocProvider<WizardCubit>(
              create: (context) => TemplateActivityWizardCubit(
                editActivityCubit: context.read<EditActivityCubit>(),
                sortableBloc: context.read<SortableBloc>(),
                original: Sortable.createNew(
                  groupId: sortableState.currentFolderId,
                  sortOrder: sortableState.currentFolderSorted.firstSortOrder(),
                  data: BasicActivityDataItem.createNew(),
                ),
              ),
            ),
          ],
          child: const ActivityWizardPage(),
        ),
      ),
    );
  }
}
