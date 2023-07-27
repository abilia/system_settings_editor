import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/bloc/activities/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class AddInfoTypePage extends StatelessWidget {
  final Type infoItemType;

  const AddInfoTypePage({
    required this.infoItemType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final editActivityCubit = context.watch<EditActivityCubit>();
    final infoItem = editActivityCubit.state.activity.infoItem;
    final isChecklist = infoItemType == Checklist;
    final showButtons = infoItemType != infoItem.runtimeType;
    final newInfoItemString =
        isChecklist ? translate.newChecklist : translate.newNote;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: isChecklist ? AbiliaIcons.ok : AbiliaIcons.edit,
        title: isChecklist ? translate.addChecklist : translate.addNote,
        label: translate.newActivity,
      ),
      body: Padding(
        padding: layout.templates.m6,
        child: Container(
          decoration: whiteBoxDecoration,
          child: Padding(
            padding: layout.templates.m6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (showButtons) ...[
                  IconAndTextButton(
                    style: actionButtonStyleBlack,
                    icon: AbiliaIcons.plus,
                    text: newInfoItemString,
                    onPressed: () =>
                        editActivityCubit.createNewInfoItem(infoItemType),
                  ),
                  SizedBox(height: layout.formPadding.verticalItemDistance),
                  IconAndTextButton(
                    style: actionButtonStyleDark,
                    icon: AbiliaIcons.folder,
                    text: translate.fromTemplate,
                    onPressed: () async {
                      final editActivityCubit =
                          context.read<EditActivityCubit>();
                      final newInfoItem =
                          await Navigator.of(context).push<InfoItem>(
                        PersistentMaterialPageRoute(
                          settings: (isChecklist
                                  ? ChecklistLibraryPage
                                  : NoteLibraryPage)
                              .routeSetting(),
                          builder: (_) => MultiBlocProvider(
                            providers: copiedAuthProviders(context),
                            child: isChecklist
                                ? const ChecklistLibraryPage()
                                : const NoteLibraryPage(),
                          ),
                        ),
                      );
                      if (newInfoItem != null && newInfoItem != infoItem) {
                        editActivityCubit.setInfoItem(newInfoItem);
                      }
                    },
                  ),
                ] else if (infoItem is Checklist)
                  const EditChecklistWidget()
                else if (infoItem is NoteInfoItem)
                  EditNoteWidget(infoItem: infoItem)
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: PreviousButton(
          onPressed: () async {
            editActivityCubit.setInfoItem(infoItem);
            await Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }
}
