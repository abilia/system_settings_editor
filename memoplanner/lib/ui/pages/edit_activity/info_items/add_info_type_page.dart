import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memoplanner/bloc/activities/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class AddInfoTypePage<InfoItemType extends InfoItem> extends StatelessWidget {
  const AddInfoTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final editActivityCubit = context.watch<EditActivityCubit>();
    final infoItem = editActivityCubit.state.activity.infoItem;
    final data = _InfoItemData.fromType<InfoItemType>(translate);
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: data.iconData,
        title: data.title,
        label: translate.newActivity,
      ),
      body: Padding(
        padding: layout.templates.s1,
        child: Container(
          decoration: whiteBoxDecoration.copyWith(
            border: Border.fromBorderSide(
              BorderSide(
                color: AbiliaColors.white120,
                width: layout.borders.thin,
              ),
            ),
          ),
          child: Padding(
            padding: layout.templates.m6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (InfoItemType != infoItem.runtimeType) ...[
                  IconAndTextButton(
                    style:
                        actionButtonStyleBlack.copyWith(minimumSize: denseSize),
                    icon: AbiliaIcons.plus,
                    text: data.buttonText,
                    iconSize: layout.icon.smaller,
                    onPressed: () =>
                        editActivityCubit.createNewInfoItem(InfoItemType),
                  ),
                  SizedBox(height: layout.formPadding.verticalItemDistance),
                  IconAndTextButton(
                    style:
                        actionButtonStyleDark.copyWith(minimumSize: denseSize),
                    icon: AbiliaIcons.folder,
                    text: translate.fromTemplate,
                    iconSize: layout.icon.smaller,
                    onPressed: () async {
                      final editActivityCubit =
                          context.read<EditActivityCubit>();
                      final newInfoItem =
                          await Navigator.of(context).push<InfoItem>(
                        PersistentMaterialPageRoute(
                          settings: data.page.runtimeType.routeSetting(),
                          builder: (_) => MultiBlocProvider(
                            providers: copiedAuthProviders(context),
                            child: data.page,
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
        backNavigationWidget: BackButton(
          onPressed: () async {
            editActivityCubit.setInfoItem(infoItem);
            await Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }
}

class _InfoItemData {
  final IconData iconData;
  final String title, buttonText;
  final Widget page;
  _InfoItemData._({
    required this.title,
    required this.iconData,
    required this.buttonText,
    required this.page,
  });

  static _InfoItemData fromType<InfoItemType extends InfoItem>(Lt translate) {
    switch (InfoItemType) {
      case Checklist:
        return _InfoItemData._(
          title: translate.addChecklist,
          iconData: AbiliaIcons.ok,
          buttonText: translate.newChecklist,
          page: const ChecklistLibraryPage(),
        );
      case NoteInfoItem:
        return _InfoItemData._(
          title: translate.addNote,
          iconData: AbiliaIcons.edit,
          buttonText: translate.newNote,
          page: const NoteLibraryPage(),
        );
    }
    return _InfoItemData._(
      title: '',
      iconData: AbiliaIcons.about,
      buttonText: '',
      page: const SizedBox.shrink(),
    );
  }
}
