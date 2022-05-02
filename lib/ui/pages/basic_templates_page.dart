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
  Widget build(BuildContext context) => Scaffold(
        body: ListLibrary<T>(
          emptyLibraryMessage: noTemplateText,
          libraryItemGenerator: BasicTemplatePickField.new,
        ),
        bottomNavigationBar: BlocSelector<SortableArchiveCubit<T>,
            SortableArchiveState<T>, bool>(
          selector: (state) => state.isAtRoot,
          builder: (context, isAtRoot) => BottomNavigation(
              backNavigationWidget:
                  CloseButton(onPressed: Navigator.of(context).maybePop)),
        ),
      );
}

class BasicTemplatePickField<T extends SortableData> extends StatelessWidget {
  const BasicTemplatePickField(
    this._sortable,
    this._onTap,
    this._toolBar, {
    Key? key,
    this.trailing,
    this.subtitleText,
  })  : assert(_toolBar == null || trailing == null),
        super(key: key);

  final Sortable<T> _sortable;
  final SortableToolbar? _toolBar;
  final Function() _onTap;
  final Widget? trailing;
  final String? subtitleText;

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
            )),
        leadingPadding: layout.pickField.imagePadding,
      );
    }
    return PickField(
      onTap: _onTap,
      padding: trailing != null || _toolBar != null
          ? layout.pickField.imagePadding.copyWith(right: 0)
          : layout.pickField.imagePadding,
      text: text,
      subtitleText: subtitleText,
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
      trailing: trailing ?? _toolBar,
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
