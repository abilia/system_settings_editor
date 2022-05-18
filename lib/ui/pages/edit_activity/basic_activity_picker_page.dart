import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class BasicActivityPickerPage extends StatelessWidget {
  const BasicActivityPickerPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocBuilder<SortableArchiveCubit<BasicActivityData>,
        SortableArchiveState<BasicActivityData>>(
      builder: (context, state) {
        return Scaffold(
          appBar: AbiliaAppBar(
            iconData: AbiliaIcons.basicActivity,
            title:
                state.allById[state.currentFolderId]?.data.title(translate) ??
                    translate.selectBasicActivity,
          ),
          body: ListLibrary<BasicActivityData>(
            emptyLibraryMessage: translate.noBasicActivities,
            libraryItemGenerator: (sortable, onTap, _, __) {
              return BasicTemplatePickField<BasicActivityData>(
                  sortable,
                  () => sortable.isGroup
                      ? context
                          .read<SortableArchiveCubit<BasicActivityData>>()
                          .folderChanged(sortable.id)
                      : Navigator.of(context)
                          .pop<BasicActivityData>(sortable.data),
                  _,
                  __);
            },
            onSelected: (Sortable<BasicActivityData> selected) =>
                Navigator.of(context).pop<BasicActivityData>(selected.data),
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: PreviousButton(
              onPressed: state.isAtRoot
                  ? Navigator.of(context).maybePop
                  : () => context
                      .read<SortableArchiveCubit<BasicActivityData>>()
                      .navigateUp(),
            ),
          ),
        );
      },
    );
  }
}
