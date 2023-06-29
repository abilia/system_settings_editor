import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class BasicTimerPickerPage extends StatelessWidget {
  const BasicTimerPickerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
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
              title: translate.fromTemplate,
              breadcrumbs: !state.isAtRoot ? state.breadCrumbPath() : null,
            ),
            body: ListLibrary<BasicTimerData>(
              emptyLibraryMessage: translate.noTemplates,
              selectableItems: false,
              libraryItemGenerator: (sortable, onTap, _, __) {
                final sortableData = sortable.data;
                return BasicTemplatePickField<BasicTimerData>(
                  sortable,
                  onTap,
                  _StartBasicTimerButton(
                    onPressed: () async {
                      if (sortableData is BasicTimerDataItem) {
                        context
                            .read<EditTimerCubit>()
                            .loadTimerTemplate(sortableData);
                        await context.read<EditTimerCubit>().start();
                      }
                    },
                  ).pad(layout.button.startBasicTimerPadding),
                  false,
                  alwaysShowTrailing: sortableData is BasicTimerDataItem,
                );
              },
              useHeading: false,
            ),
            bottomNavigationBar: BottomNavigation(
              backNavigationWidget: LightButton(
                text: translate.back,
                icon: AbiliaIcons.navigationPrevious,
                onPressed: state.isAtRoot
                    ? Navigator.of(context).maybePop
                    : context
                        .read<SortableArchiveCubit<BasicTimerData>>()
                        .navigateUp,
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
    return IconAndTextButton(
      onPressed: onPressed,
      icon: AbiliaIcons.playSound,
      text: Lt.of(context).start,
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
