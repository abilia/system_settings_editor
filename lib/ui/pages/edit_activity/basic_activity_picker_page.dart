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
      builder: (innerContext, state) {
        final selected = state.selected;
        return Scaffold(
          appBar: AbiliaAppBar(
            iconData: AbiliaIcons.basicActivity,
            title:
                state.allById[state.currentFolderId]?.data.title(translate) ??
                    translate.basicActivities,
          ),
          body: SortableLibrary<BasicActivityData>(
            (Sortable<BasicActivityData> s) =>
                s is Sortable<BasicActivityDataItem>
                    ? BasicLibraryItem<BasicActivityData>(sortable: s)
                    : CrossOver(
                        fallbackHeight: BasicLibraryItem.imageHeight,
                        fallbackWidth: BasicLibraryItem.imageWidth,
                      ),
            translate.noBasicActivities,
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: PreviousButton(
              onPressed: state.isAtRoot
                  ? Navigator.of(context).maybePop
                  : () => context
                      .read<SortableArchiveCubit<BasicActivityData>>()
                      .navigateUp(),
            ),
            forwardNavigationWidget: NextButton(
              onPressed: selected != null
                  ? () => Navigator.of(context)
                      .pop<BasicActivityData>(selected.data)
                  : null,
            ),
          ),
        );
      },
    );
  }
}
