import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class InfoItemTab extends StatelessWidget with EditActivityTab {
  final bool showNote, showChecklist;

  const InfoItemTab({
    required this.showNote,
    required this.showChecklist,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return Padding(
      padding: layout.templates.m3,
      child: BlocSelector<EditActivityCubit, EditActivityState, InfoItem>(
        selector: (state) => state.activity.infoItem,
        builder: (context, infoItem) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (showChecklist)
                InfoItemPickField(
                  text: translate.checklist,
                  iconData: AbiliaIcons.ok,
                  infoItem: infoItem is Checklist ? infoItem : null,
                  infoItemType: Checklist,
                  isClickable: infoItem is NoInfoItem || infoItem is Checklist,
                ),
              SizedBox(height: layout.formPadding.verticalItemDistance),
              if (showNote)
                InfoItemPickField(
                  text: translate.note,
                  iconData: AbiliaIcons.edit,
                  infoItem: infoItem is NoteInfoItem ? infoItem : null,
                  infoItemType: NoteInfoItem,
                  isClickable:
                      infoItem is NoInfoItem || infoItem is NoteInfoItem,
                ),
              if (infoItem is! NoInfoItem) ...[
                const Spacer(),
                ErrorMessage(
                  text: Text(Lt.of(context).onlyOneInfoItem),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class InfoItemPickField extends StatelessWidget {
  final InfoItem? infoItem;
  final Type infoItemType;
  final String text;
  final IconData iconData;
  final bool isClickable;

  const InfoItemPickField({
    required this.infoItem,
    required this.infoItemType,
    required this.text,
    required this.iconData,
    required this.isClickable,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final infoItem = this.infoItem;
    return Row(
      children: [
        Expanded(
          child: PickField(
            leading: Icon(iconData),
            text: Text(text),
            extras: infoItem != null
                ? InfoItemPickFieldExtras(infoItem: infoItem)
                : null,
            onTap: isClickable
                ? () async {
                    final editActivityCubit = context.read<EditActivityCubit>();
                    final providers = [
                      ...copiedAuthProviders(context),
                      BlocProvider.value(value: editActivityCubit)
                    ];
                    await Navigator.of(context).push<Type>(
                      PersistentMaterialPageRoute(
                        settings: (AddInfoTypePage).routeSetting(),
                        builder: (context) => MultiBlocProvider(
                          providers: providers,
                          child: AddInfoTypePage(
                            infoItemType: infoItemType,
                          ),
                        ),
                      ),
                    );
                  }
                : null,
          ),
        ),
        if (infoItem != null) ...[
          SizedBox(
            width: layout.formPadding.verticalItemDistance,
          ),
          IconActionButtonDark(
            onPressed: () async {
              context.read<EditActivityCubit>().removeInfoItem();
            },
            child: const Icon(AbiliaIcons.deleteAllClear),
          ),
        ]
      ],
    );
  }
}

class InfoItemPickFieldExtras extends StatelessWidget {
  final InfoItem infoItem;

  const InfoItemPickFieldExtras({
    required this.infoItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final infoItem = this.infoItem;
    if (infoItem is NoteInfoItem) {
      return NoteInfoItemPickFieldExtras(
        note: infoItem,
      );
    } else if (infoItem is Checklist) {
      return ChecklistPickFieldExtras(
        checklist: infoItem,
      );
    }
    return const SizedBox.shrink();
  }
}

class NoteInfoItemPickFieldExtras extends StatelessWidget {
  final NoteInfoItem note;

  const NoteInfoItemPickFieldExtras({
    required this.note,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: layout.formPadding.horizontalItemDistance),
      child: SizedBox(
        height: layout.note.previewExtrasHeight,
        child: Text(
          note.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: bodyMedium,
        ),
      ),
    );
  }
}

class ChecklistPickFieldExtras extends StatelessWidget {
  final Checklist checklist;

  const ChecklistPickFieldExtras({
    required this.checklist,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final questions = checklist.questions;
    final translate = Lt.of(context);
    final checklistLayout = layout.checklist;
    return Container(
      height: checklistLayout.previewExtrasHeight,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(checklistLayout.previewCornerRadius),
        color: AbiliaColors.white110,
      ),
      padding: checklistLayout.previewPadding,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: checklistLayout.previewTextPadding,
            child: Center(
              child: Text('${questions.length} ${translate.tasks}'),
            ),
          ),
          ...questions
              .map((question) =>
                  CheckListPickFieldExtrasItem(question: question))
              .toList()
        ],
      ),
    );
  }
}

class CheckListPickFieldExtrasItem extends StatelessWidget {
  final Question question;

  const CheckListPickFieldExtrasItem({
    required this.question,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final checklistLayout = layout.checklist;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: EdgeInsets.symmetric(
        horizontal: checklistLayout.previewItemSpacing,
      ),
      decoration: BoxDecoration(
        color: AbiliaColors.white,
        borderRadius: BorderRadius.circular(
          checklistLayout.previewItemCornerRadius,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (question.hasImage) ...[
            FadeInCalendarImage(
              imageFile: AbiliaFile.from(
                id: question.fileId,
                path: question.image,
              ),
              width: checklistLayout.previewImageSize,
              height: checklistLayout.previewImageSize,
              radius: BorderRadius.all(
                Radius.circular(checklistLayout.previewImageBorderRadius),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Text(question.name, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
