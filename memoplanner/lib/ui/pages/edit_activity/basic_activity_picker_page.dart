import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

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
              iconData: AbiliaIcons.basicActivities,
              title: translate.fromTemplate),
          body: ListLibrary<BasicActivityData>(
            emptyLibraryMessage: translate.noTemplates,
            selectableItems: false,
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
