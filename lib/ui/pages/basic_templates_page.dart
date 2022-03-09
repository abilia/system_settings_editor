import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class BasicTemplatesPage extends StatelessWidget {
  const BasicTemplatesPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return DefaultTabController(
      initialIndex: 0,
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
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _BasicTemplateTab<BasicActivityData>(
              translate: translate,
              noTemplateText: translate.noBasicActivities,
            ),
            _BasicTemplateTab<BasicTimerData>(
              translate: translate,
              noTemplateText: translate.noBasicTimers,
            ),
          ],
        ),
      ),
    );
  }
}

class _BasicTemplateTab<T extends SortableData> extends StatelessWidget {
  const _BasicTemplateTab(
      {Key? key, required this.translate, required this.noTemplateText})
      : super(key: key);

  final Translated translate;
  final String noTemplateText;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SortableArchiveCubit<T>, SortableArchiveState<T>>(
        builder: (context, state) => Scaffold(
          body: ListLibrary<T>(
            (Sortable<T> s) =>
                _BasicTemplatePickField(translate: translate, sortable: s),
            noTemplateText,
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: state.isAtRoot
                ? CloseButton(
                    onPressed: Navigator.of(context).maybePop,
                  )
                : PreviousButton(
                    onPressed: () =>
                        context.read<SortableArchiveCubit<T>>().navigateUp(),
                  ),
          ),
        ),
      );
}

class _BasicTemplatePickField extends StatelessWidget {
  const _BasicTemplatePickField({
    Key? key,
    required this.translate,
    required this.sortable,
  }) : super(key: key);
  final Sortable sortable;
  final Translated translate;

  @override
  Widget build(BuildContext context) {
    final BasicTemplatesPageLayout pageLayout = layout.basicTemplatesPage;
    return PickField(
      height: pageLayout.pickFieldHeight,
      text: Text(sortable.data.title(translate)),
      leading: sortable.data.hasImage()
          ? sortable.isGroup
              ? FittedBox(
                  child: LibraryFolder(
                    sortableData: sortable.data,
                    showTitle: false,
                  ),
                )
              : FadeInAbiliaImage(
                  imageFileId: sortable.data.dataFileId(),
                  imageFilePath: sortable.data.dataFilePath(),
                  fit: BoxFit.contain,
                )
          : Icon(
              AbiliaIcons.basicActivity,
              size: pageLayout.basicActivityIconSize,
              color: AbiliaColors.white140,
            ),
      trailing: sortable.isGroup ? null : Container(),
      padding: pageLayout.pickFieldPadding,
      customDecoration: BoxDecoration(
        color: AbiliaColors.white,
        borderRadius: borderRadius,
        border: Border.fromBorderSide(
          BorderSide(
              color: AbiliaColors.white140, width: pageLayout.pickFieldBorder),
        ),
      ),
    );
  }
}
