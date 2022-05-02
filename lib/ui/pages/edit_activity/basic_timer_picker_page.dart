import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class BasicTimerPickerPage extends StatelessWidget {
  const BasicTimerPickerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return BlocListener<EditTimerCubit, EditTimerState>(
      listener: (context, state) {
        if (state is SavedTimerState) {
          return Navigator.pop(context, state.savedTimer);
        }
      },
      child: BlocBuilder<SortableArchiveCubit<BasicTimerData>,
          SortableArchiveState<BasicTimerData>>(
        builder: (context, state) {
          return Scaffold(
            appBar: AbiliaAppBar(
              iconData: AbiliaIcons.basicTimers,
              title:
                  state.allById[state.currentFolderId]?.data.title(translate) ??
                      translate.fromBasicTimer,
            ),
            body: ListLibrary<BasicTimerData>(
              emptyLibraryMessage: translate.noBasicTimers,
              selectableItems: false,
              libraryItemGenerator: (sortable, onTap, _) {
                final sortableData = sortable.data;
                return BasicTemplatePickField<BasicTimerData>(
                  sortable,
                  onTap,
                  null,
                  subtitleText: sortableData is BasicTimerDataItem
                      ? sortableData.duration.milliseconds().toHMSorMS()
                      : null,
                  trailing: sortable.data is BasicTimerDataItem
                      ? _StartBasicTimerButton(
                          key: TestKey.startBasicTimerButton,
                          onPressed: () {
                            if (sortableData is BasicTimerDataItem) {
                              context.read<EditTimerCubit>()
                                ..loadBasicTimer(sortableData)
                                ..start();
                            }
                          },
                        ).pad(layout.button.startBasicTimerPadding)
                      : null,
                );
              },
            ),
            bottomNavigationBar: BottomNavigation(
              backNavigationWidget: PreviousButton(
                onPressed: state.isAtRoot
                    ? Navigator.of(context).maybePop
                    : () => context
                        .read<SortableArchiveCubit<BasicTimerData>>()
                        .navigateUp(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StartBasicTimerButton extends StatelessWidget {
  const _StartBasicTimerButton({Key? key, this.onPressed}) : super(key: key);
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return IconAndTextButton(
      onPressed: onPressed,
      icon: AbiliaIcons.playSound,
      text: translate.start,
      style: iconTextButtonStyleGreen.copyWith(
        shape: MaterialStateProperty.all(darkShapeBorder),
        minimumSize: MaterialStateProperty.all(null),
        padding: MaterialStateProperty.all(
          layout.button.actionButtonIconTextPadding,
        ),
      ),
      padding: const EdgeInsets.all(0),
    );
  }
}
